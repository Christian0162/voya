import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voya/core/data/services/answer_builder.dart';
import 'package:voya/core/data/services/gemini_ai_interview_service.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';

void main() {
  final configuration = const InterviewConfiguration(
    country: Country(code: 'AU', name: 'Australia', flagEmoji: '🇦🇺'),
    purpose: InterviewPurpose.work,
    difficulty: InterviewDifficulty.professional,
    durationMinutes: 5,
  );

  /// Wraps a decoded JSON object the way Gemini's `generateContent` response
  /// shape does: the actual payload lives as a JSON *string* inside
  /// candidates[0].content.parts[0].text (this is what `responseSchema`
  /// produces — a JSON-parseable string, not a nested JSON object).
  http.Response geminiResponse(Map<String, dynamic> payload) {
    return http.Response(
      jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': jsonEncode(payload)},
              ],
            },
          },
        ],
      }),
      200,
    );
  }

  GeminiAIInterviewService buildService(http.Response Function(http.Request request) handler) {
    return GeminiAIInterviewService(
      apiKey: 'test-key',
      httpClient: MockClient((request) async => handler(request)),
    );
  }

  test('generateOpeningQuestion returns the question from the response', () async {
    final service = buildService((_) => geminiResponse({'question': 'Tell me about yourself.'}));

    final question = await service.generateOpeningQuestion(configuration);

    expect(question.text, 'Tell me about yourself.');
    expect(question.kind, QuestionKind.opening);
    expect(question.order, 0);
  });

  test('analyzeAnswer parses vague/inconsistent flags and the follow-up question', () async {
    final service = buildService(
      (_) => geminiResponse({
        'isVague': true,
        'isInconsistent': false,
        'followUpQuestion': 'Can you give a concrete example?',
        'inconsistencyNote': null,
      }),
    );

    const question = InterviewQuestion(
      id: 'q0',
      text: 'Why do you want this role?',
      kind: QuestionKind.opening,
      order: 0,
    );
    final answer = AnswerBuilder.build(
      questionId: 'q0',
      transcript: 'For better opportunities.',
      spokenDuration: const Duration(seconds: 5),
    );
    final turn = InterviewTurn(question: question, answer: answer);

    final analysis = await service.analyzeAnswer(
      configuration: configuration,
      history: const [],
      currentTurn: turn,
    );

    expect(analysis.isVague, isTrue);
    expect(analysis.isInconsistent, isFalse);
    expect(analysis.followUpQuestion, 'Can you give a concrete example?');
    expect(analysis.needsFollowUp, isTrue);
  });

  test('analyzeAnswer never calls the network when the turn has no answer yet', () async {
    var called = false;
    final service = buildService((_) {
      called = true;
      return geminiResponse({'isVague': false, 'isInconsistent': false});
    });

    const question = InterviewQuestion(
      id: 'q0',
      text: 'Why do you want this role?',
      kind: QuestionKind.opening,
      order: 0,
    );

    final analysis = await service.analyzeAnswer(
      configuration: configuration,
      history: const [],
      currentTurn: const InterviewTurn(question: question),
    );

    expect(called, isFalse);
    expect(analysis.isVague, isFalse);
    expect(analysis.needsFollowUp, isFalse);
  });

  test('generateFeedback combines the model scores with deterministic pace/filler stats', () async {
    final service = buildService(
      (_) => geminiResponse({
        'communication': 0.8,
        'clarity': 0.7,
        'answerQuality': 0.75,
        'consistency': 0.9,
        'strengths': ['Clear structure'],
        'practiceAreas': ['Reduce filler words'],
        'questionsToPractice': ['Why do you want this role?'],
      }),
    );

    const question = InterviewQuestion(
      id: 'q0',
      text: 'Why do you want this role?',
      kind: QuestionKind.opening,
      order: 0,
    );
    final answer = AnswerBuilder.build(
      questionId: 'q0',
      transcript: 'Um, I really like the, like, the team and the mission honestly.',
      spokenDuration: const Duration(seconds: 6),
    );
    final turn = InterviewTurn(question: question, answer: answer);

    final result = await service.generateFeedback(
      configuration: configuration,
      history: [turn],
      sessionId: 'session-1',
    );

    // From the model, verbatim.
    expect(result.communication, 0.8);
    expect(result.clarity, 0.7);
    expect(result.answerQuality, 0.75);
    expect(result.consistency, 0.9);
    expect(result.strengths, ['Clear structure']);
    expect(result.practiceAreas, ['Reduce filler words']);
    expect(result.questionsToPractice, ['Why do you want this role?']);

    // Computed locally, not from the model.
    expect(result.fillerWordCounts, answer.fillerWordCounts);
    expect(result.speakingPace, inInclusiveRange(0.0, 1.0));
  });

  test('throws when Gemini returns a non-200 response', () async {
    final service = buildService((_) => http.Response('server error', 500));

    expect(() => service.generateOpeningQuestion(configuration), throwsException);
  });
}
