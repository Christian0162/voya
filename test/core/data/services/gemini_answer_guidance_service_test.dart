import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voya/core/data/services/gemini_answer_guidance_service.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';

void main() {
  const question = GuidanceQuestion(
    id: 'travelPurpose_0',
    text: 'What is the purpose of your visit?',
    category: GuidanceCategory.travelPurpose,
  );

  /// Same Gemini `generateContent` response shape as the interview service
  /// test: the real payload is a JSON string inside
  /// candidates[0].content.parts[0].text.
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

  GeminiAnswerGuidanceService buildService(http.Response Function(http.Request request) handler) {
    return GeminiAnswerGuidanceService(
      apiKey: 'test-key',
      httpClient: MockClient((request) async => handler(request)),
    );
  }

  test('generateGuide parses all six guidance fields from the response', () async {
    final service = buildService(
      (_) => geminiResponse({
        'questionExplanation': 'They want to know why you are traveling.',
        'interviewerIntent': 'A clear, honest purpose.',
        'answerStructure': ['State your purpose', 'Add details', 'Wrap up'],
        'exampleAnswer': 'My purpose is [reason].',
        'commonMistakes': ['Being vague', 'Sounding rehearsed'],
        'practiceTip': 'Say it out loud once first.',
      }),
    );

    final guide = await service.generateGuide(question);

    expect(guide.questionExplanation, 'They want to know why you are traveling.');
    expect(guide.interviewerIntent, 'A clear, honest purpose.');
    expect(guide.answerStructure, ['State your purpose', 'Add details', 'Wrap up']);
    expect(guide.exampleAnswer, 'My purpose is [reason].');
    expect(guide.commonMistakes, ['Being vague', 'Sounding rehearsed']);
    expect(guide.practiceTip, 'Say it out loud once first.');
  });

  test('analyzeAnswer parses scores, feedback text, and improved example', () async {
    final service = buildService(
      (_) => geminiResponse({
        'relevance': 0.6,
        'clarity': 0.8,
        'completeness': 0.5,
        'naturalness': 0.7,
        'consistency': 0.9,
        'feedbackText': 'Good start! Add one more detail.',
        'improvedExample': 'My purpose is tourism, to see [places].',
      }),
    );

    const guide = AnswerGuide(
      questionExplanation: 'x',
      interviewerIntent: 'x',
      answerStructure: ['x'],
      exampleAnswer: 'x',
      commonMistakes: ['x'],
      practiceTip: 'x',
    );

    final feedback = await service.analyzeAnswer(
      question: question,
      guide: guide,
      transcript: 'My purpose is tourism.',
    );

    expect(feedback.relevance, 0.6);
    expect(feedback.clarity, 0.8);
    expect(feedback.completeness, 0.5);
    expect(feedback.naturalness, 0.7);
    expect(feedback.consistency, 0.9);
    expect(feedback.feedbackText, 'Good start! Add one more detail.');
    expect(feedback.improvedExample, 'My purpose is tourism, to see [places].');
  });

  test('analyzeAnswer leaves improvedExample null when the response omits it', () async {
    final service = buildService(
      (_) => geminiResponse({
        'relevance': 0.9,
        'clarity': 0.9,
        'completeness': 0.9,
        'naturalness': 0.9,
        'consistency': 0.9,
        'feedbackText': 'Great answer.',
      }),
    );

    const guide = AnswerGuide(
      questionExplanation: 'x',
      interviewerIntent: 'x',
      answerStructure: ['x'],
      exampleAnswer: 'x',
      commonMistakes: ['x'],
      practiceTip: 'x',
    );

    final feedback = await service.analyzeAnswer(
      question: question,
      guide: guide,
      transcript: 'A solid, specific answer.',
    );

    expect(feedback.improvedExample, isNull);
  });

  test('throws when Gemini returns a non-200 response', () async {
    final service = buildService((_) => http.Response('server error', 500));

    expect(() => service.generateGuide(question), throwsException);
  });
}
