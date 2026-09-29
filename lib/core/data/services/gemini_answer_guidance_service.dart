import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:voya/core/domain/answer_guidance/entities/answer_feedback.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';

/// Real LLM-backed Answer Coach, calling the Gemini API directly over REST —
/// same `generateContent` + JSON `responseSchema` approach as
/// [GeminiAIInterviewService], so every reply is already the exact shape the
/// domain entities need, with no free-text parsing.
///
/// The persona prompt bakes in every non-negotiable from spec section 9
/// directly: no guaranteed outcomes, no fabricated personal facts, never
/// telling the user to memorize an answer, no unsupported official/legal
/// claims, and never judging nationality, background, accent, or fluency.
class GeminiAnswerGuidanceService implements AnswerGuidanceService {
  GeminiAnswerGuidanceService({
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

  static const _coachPersona =
      'You are an experienced, patient, professional interview coach helping someone '
      'prepare to answer a real interview question truthfully and clearly. Explain things '
      'in simple, friendly, natural language, never judgmental or overly formal.\n\n'
      'Hard rules, never break these:\n'
      '- Never guarantee interview success or predict a real outcome.\n'
      '- Never invent the user\'s personal facts (travel history, finances, employment, '
      'intentions) — use bracketed placeholders like [country] or [duration] instead.\n'
      '- Never tell the user to memorize a response word for word.\n'
      '- Never state country-specific official/legal requirements as fact — frame advice '
      'as general practice guidance.\n'
      '- Never judge or reference the user\'s nationality, background, accent, or fluency.\n'
      '- Never suggest hiding information or giving a misleading answer.';

  @override
  Future<AnswerGuide> generateGuide(GuidanceQuestion question) async {
    final json = await _generate(
      prompt:
          '$_coachPersona\n\n'
          'The interview question to explain is:\n"${question.text}"\n\n'
          'Produce coaching guidance with these fields:\n'
          '- questionExplanation: what the interviewer is actually asking and why it matters, '
          'simple enough for someone who has never done a formal interview.\n'
          '- interviewerIntent: the main things a good answer should cover (do not imply a '
          'guaranteed "correct" answer exists).\n'
          '- answerStructure: 2-4 short steps for building a personal answer (do not force a '
          'template that would not fit this specific question).\n'
          '- exampleAnswer: one natural-sounding sample answer using [bracketed placeholders] '
          'for every personal detail.\n'
          '- commonMistakes: 3-5 practical, constructive mistakes to avoid for this question.\n'
          '- practiceTip: one short, encouraging tip for practicing this question aloud.',
      schema: _guideSchema,
    );

    return AnswerGuide(
      questionExplanation: json['questionExplanation'] as String? ?? '',
      interviewerIntent: json['interviewerIntent'] as String? ?? '',
      answerStructure: _stringList(json['answerStructure']),
      exampleAnswer: json['exampleAnswer'] as String? ?? '',
      commonMistakes: _stringList(json['commonMistakes']),
      practiceTip: json['practiceTip'] as String? ?? '',
    );
  }

  @override
  Future<AnswerFeedback> analyzeAnswer({
    required GuidanceQuestion question,
    required AnswerGuide guide,
    required String transcript,
  }) async {
    final json = await _generate(
      prompt:
          '$_coachPersona\n\n'
          'Interview question:\n"${question.text}"\n\n'
          'What a strong answer covers:\n${guide.interviewerIntent}\n\n'
          'The user\'s spoken answer (transcribed):\n"$transcript"\n\n'
          'Score this answer 0.0-1.0 on relevance (did it address the question), clarity '
          '(easy to understand), completeness (covers the important information), '
          'naturalness (sounds conversational, not rehearsed), and consistency (no '
          'self-contradiction within the answer itself). Write one short, supportive, '
          'specific feedbackText paragraph (like a coach, not a grader). If the answer is '
          'missing detail or is vague, also write an improvedExample: an improved version '
          'built ONLY from details the user actually gave, with [bracketed placeholders] for '
          'anything missing — otherwise leave improvedExample null.',
      schema: _feedbackSchema,
    );

    return AnswerFeedback(
      relevance: _clamp01(((json['relevance'] as num?) ?? 0).toDouble()),
      clarity: _clamp01(((json['clarity'] as num?) ?? 0).toDouble()),
      completeness: _clamp01(((json['completeness'] as num?) ?? 0).toDouble()),
      naturalness: _clamp01(((json['naturalness'] as num?) ?? 0).toDouble()),
      consistency: _clamp01(((json['consistency'] as num?) ?? 0).toDouble()),
      feedbackText: json['feedbackText'] as String? ?? '',
      improvedExample: json['improvedExample'] as String?,
    );
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
          'temperature': 0.7,
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

  static const _guideSchema = {
    'type': 'OBJECT',
    'properties': {
      'questionExplanation': {'type': 'STRING'},
      'interviewerIntent': {'type': 'STRING'},
      'answerStructure': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'exampleAnswer': {'type': 'STRING'},
      'commonMistakes': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'practiceTip': {'type': 'STRING'},
    },
    'required': [
      'questionExplanation',
      'interviewerIntent',
      'answerStructure',
      'exampleAnswer',
      'commonMistakes',
      'practiceTip',
    ],
  };

  static const _feedbackSchema = {
    'type': 'OBJECT',
    'properties': {
      'relevance': {'type': 'NUMBER'},
      'clarity': {'type': 'NUMBER'},
      'completeness': {'type': 'NUMBER'},
      'naturalness': {'type': 'NUMBER'},
      'consistency': {'type': 'NUMBER'},
      'feedbackText': {'type': 'STRING'},
      'improvedExample': {'type': 'STRING', 'nullable': true},
    },
    'required': [
      'relevance',
      'clarity',
      'completeness',
      'naturalness',
      'consistency',
      'feedbackText',
    ],
  };
}
