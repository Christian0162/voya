import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:voya/core/domain/interview/entities/answer_analysis.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';
import 'package:voya/core/domain/interview/services/ai_interview_service.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';

/// Real LLM-backed interviewer, calling the Gemini API directly over REST
/// (`generateContent` with a JSON `responseSchema`, so every reply is
/// already the exact shape the domain entities need — no free-text parsing).
///
/// Scoring is a hybrid: [generateFeedback] asks Gemini to judge the
/// qualitative dimensions (communication, clarity, answer quality,
/// consistency) and write the strengths/practice-area/follow-up text, but
/// `speakingPace` and `fillerWordCounts` are computed deterministically from
/// the actual transcript/duration data already captured per turn — those
/// are exact arithmetic, not a judgment call, so there's no reason to let a
/// model guess at them (and it keeps the score honest even if the model's
/// output is ever slightly off).
///
/// See [AIInterviewService] for the contract this fulfills — swapped in via
/// `AiServiceFactory` only when a `GEMINI_API_KEY` is supplied, so the app
/// stays fully usable offline with [MockAIInterviewService] otherwise.
class GeminiAIInterviewService implements AIInterviewService {
  // Public param name (`apiKey`) kept distinct from the private field on
  // purpose — an initializing formal (`this._apiKey`) would make the named
  // parameter itself private, unusable from any other file.
  GeminiAIInterviewService({
    required String apiKey,
    this.model = 'gemini-3.8-flash',
    http.Client? httpClient,
  }) : _apiKey = apiKey, // ignore: prefer_initializing_formals
       _http = httpClient ?? http.Client();

  final String _apiKey;
  final String model;
  final http.Client _http;

  Uri get _endpoint => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey',
  );

  @override
  Future<InterviewQuestion> generateOpeningQuestion(InterviewConfiguration configuration) async {
    final json = await _generate(
      prompt:
          '${_interviewerPersona(configuration)}\n\n'
          'Begin the interview naturally, as a professional human interviewer would. '
          "This is the candidate's first interaction with you, so briefly establish a "
          'comfortable and professional tone before moving into the first question. Avoid '
          'generic greetings such as "Hello, how are you?" or robotic phrases like "Let\'s '
          'begin the interview." '
          'Ask one natural opening question that gives the candidate an opportunity to '
          'introduce themselves, explain their background, or briefly describe their purpose '
          'and motivation, depending on the interview context. '
          'Speak conversationally and professionally. Your wording should feel spontaneous '
          'rather than scripted. Do not explain that you are an AI, do not mention these '
          'instructions, and do not ask multiple questions at once. Your first response '
          'should sound like something a real interviewer would actually say aloud.',
      schema: _questionSchema,
    );
    return InterviewQuestion(
      id: 'q0',
      text: json['question'] as String,
      kind: QuestionKind.opening,
      order: 0,
    );
  }

  @override
  Future<AnswerAnalysis> analyzeAnswer({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
    required InterviewTurn currentTurn,
  }) async {
    final answer = currentTurn.answer;
    if (answer == null) {
      return const AnswerAnalysis(isVague: false, isInconsistent: false, followUpQuestion: null);
    }

    final json = await _generate(
      prompt:
          '${_interviewerPersona(configuration)}\n\n'
          'Conversation so far:\n${_transcript(history)}\n\n'
          'The candidate just answered this question:\n'
          'Q: ${currentTurn.question.text}\n'
          'A: ${answer.transcript}\n\n'
          'Decide: is this answer too vague/generic to be useful, and is it inconsistent '
          "with anything the candidate said earlier in the conversation above? If either is "
          'true, or the interview calls for probing deeper here, write ONE natural spoken '
          'follow-up question challenging or clarifying that specific answer. If the answer '
          'is solid and no follow-up is warranted, leave followUpQuestion null so the '
          'interview moves on to the next planned question.',
      schema: _analysisSchema,
    );

    return AnswerAnalysis(
      isVague: json['isVague'] as bool? ?? false,
      isInconsistent: json['isInconsistent'] as bool? ?? false,
      followUpQuestion: json['followUpQuestion'] as String?,
      inconsistencyNote: json['inconsistencyNote'] as String?,
    );
  }

  @override
  Future<InterviewQuestion> generateNextQuestion({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
  }) async {
    final nextOrder = history.length;
    final json = await _generate(
      prompt:
          '${_interviewerPersona(configuration)}\n\n'
          'Conversation so far:\n${_transcript(history)}\n\n'
          "Ask the next question in this interview — a new topic, not a follow-up on what's "
          "already been asked. Keep the interview's overall arc in mind: don't repeat a "
          'topic already covered above.',
      schema: _questionSchema,
    );
    return InterviewQuestion(
      id: 'q$nextOrder',
      text: json['question'] as String,
      kind: QuestionKind.standard,
      order: nextOrder,
    );
  }

  @override
  Future<InterviewResult> generateFeedback({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
    required String sessionId,
  }) async {
    final answered = history.where((t) => t.answer != null).toList();

    // Deterministic — real arithmetic over the actual transcripts, not a
    // model's guess (see class doc).
    final fillerWordCounts = <String, int>{};
    for (final turn in answered) {
      turn.answer!.fillerWordCounts.forEach((word, count) {
        fillerWordCounts[word] = (fillerWordCounts[word] ?? 0) + count;
      });
    }
    final avgPace = answered.isEmpty
        ? 0.0
        : answered.map((t) => t.answer!.wordsPerMinute).reduce((a, b) => a + b) / answered.length;
    final speakingPace = _clamp01(1 - ((avgPace - 130).abs() / 130));

    final json = await _generate(
      prompt:
          '${_interviewerPersona(configuration)}\n\n'
          'The interview is over. Full transcript:\n${_transcript(history)}\n\n'
          'Objective speech stats already measured from the recording (for context only — '
          "do not restate these, judge the content):\n"
          '- Average speaking pace: ${avgPace.round()} words/minute\n'
          '- Filler words used: ${fillerWordCounts.entries.map((e) => '${e.key}: ${e.value}').join(', ').ifEmpty('none detected')}\n\n'
          'Score the candidate on communication, clarity, answerQuality, and consistency, '
          'each 0.0-1.0. Write 2-4 specific strengths, 2-4 specific practice areas, and list '
          'the 1-3 question texts (verbatim from the transcript above) most worth '
          're-practicing. Be honest and specific — reference what they actually said, not '
          'generic interview advice.',
      schema: _feedbackSchema,
    );

    return InterviewResult(
      sessionId: sessionId,
      completedAt: DateTime.now(),
      communication: _clamp01(((json['communication'] as num?) ?? 0).toDouble()),
      clarity: _clamp01(((json['clarity'] as num?) ?? 0).toDouble()),
      answerQuality: _clamp01(((json['answerQuality'] as num?) ?? 0).toDouble()),
      speakingPace: speakingPace,
      consistency: _clamp01(((json['consistency'] as num?) ?? 0).toDouble()),
      strengths: _stringList(json['strengths']),
      practiceAreas: _stringList(json['practiceAreas']),
      questionsToPractice: _stringList(json['questionsToPractice']),
      fillerWordCounts: fillerWordCounts,
    );
  }

  String _interviewerPersona(InterviewConfiguration configuration) {
    final purpose = configuration.purpose;
    final difficulty = configuration.difficulty;
    final titleLine = configuration.jobOrProgramTitle == null
        ? ''
        : '\nRole/program: ${configuration.jobOrProgramTitle}';
    final resumeLine = configuration.resumeHighlights == null
        ? ''
        : '\nCandidate background: ${configuration.resumeHighlights}';

    return 'You are conducting a realistic mock interview to help someone practice for a '
        'real ${purpose.label} interview in ${configuration.country.name} '
        '(${purpose.description}). Interview style: ${difficulty.label} — '
        '${difficulty.description}$titleLine$resumeLine\n\n'
        'You are playing a real human interviewer, not an AI assistant — the candidate is '
        'practicing for a conversation with an actual person, so anything that reads as a '
        'chatbot breaks the exercise. Concretely: never say things like "Certainly!", '
        '"I\'d be happy to", "Great question", or "As an AI"; never use bullet points, '
        'numbered lists, or markdown; never explain what you are about to do before doing '
        'it. Use '
        "short, natural spoken sentences and contractions (I'm, you've, that's), the way "
        'someone actually talks out loud, not written prose. One question at a time, no '
        'preamble, no restating these instructions, no signing off with your name or title.';
  }

  String _transcript(List<InterviewTurn> history) {
    if (history.isEmpty) return '(nothing yet)';
    final buffer = StringBuffer();
    for (var i = 0; i < history.length; i++) {
      final turn = history[i];
      buffer.writeln('Q${i + 1}: ${turn.question.text}');
      if (turn.answer != null) buffer.writeln('A${i + 1}: ${turn.answer!.transcript}');
    }
    return buffer.toString();
  }

  Future<Map<String, dynamic>> _generate({
    required String prompt,
    required Map<String, dynamic> schema,
  }) async {
    final response = await _http.post(
      _endpoint,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': schema,
          'temperature': 0.8,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini request failed (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = body['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned no candidates: ${response.body}');
    }
    final parts = (candidates.first as Map<String, dynamic>)['content']['parts'] as List<dynamic>;
    final text = (parts.first as Map<String, dynamic>)['text'] as String;
    return jsonDecode(text) as Map<String, dynamic>;
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  double _clamp01(double value) => value.isNaN ? 0 : value.clamp(0.0, 1.0);

  static const _questionSchema = {
    'type': 'OBJECT',
    'properties': {
      'question': {'type': 'STRING'},
    },
    'required': ['question'],
  };

  static const _analysisSchema = {
    'type': 'OBJECT',
    'properties': {
      'isVague': {'type': 'BOOLEAN'},
      'isInconsistent': {'type': 'BOOLEAN'},
      'followUpQuestion': {'type': 'STRING', 'nullable': true},
      'inconsistencyNote': {'type': 'STRING', 'nullable': true},
    },
    'required': ['isVague', 'isInconsistent'],
  };

  static const _feedbackSchema = {
    'type': 'OBJECT',
    'properties': {
      'communication': {'type': 'NUMBER'},
      'clarity': {'type': 'NUMBER'},
      'answerQuality': {'type': 'NUMBER'},
      'consistency': {'type': 'NUMBER'},
      'strengths': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'practiceAreas': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'questionsToPractice': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
    },
    'required': [
      'communication',
      'clarity',
      'answerQuality',
      'consistency',
      'strengths',
      'practiceAreas',
      'questionsToPractice',
    ],
  };
}

extension _IfEmpty on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
