import 'dart:math';

import 'package:voya/core/domain/answer_guidance/entities/answer_feedback.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';

/// Local, templated Answer Coach.
///
/// Keeps the coaching feature fully usable offline with no API key to leak,
/// the same way [MockAIInterviewService] does for the mock interview —
/// conforming to the exact same [AnswerGuidanceService] contract a real
/// LLM-backed implementation uses, so swapping providers means writing one
/// new class, not touching the bloc or UI.
class MockAnswerGuidanceService implements AnswerGuidanceService {
  MockAnswerGuidanceService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _vaguePhrases = [
    'just because',
    'no reason',
    'good life',
    'better life',
    'not sure',
    "i don't know",
  ];

  @override
  Future<AnswerGuide> generateGuide(GuidanceQuestion question) async {
    await _thinkingDelay();
    return AnswerGuide(
      questionExplanation:
          'The interviewer wants to understand the real reason behind "${question.text}" — '
          'a clear, honest answer that matches your actual situation.',
      interviewerIntent: _intentFor(question.category),
      answerStructure: const [
        'Start with your main point — answer the question directly first.',
        'Add one or two relevant details that support it.',
        'Finish with any context that ties it back to the question.',
      ],
      exampleAnswer: _exampleFor(question.category),
      commonMistakes: const [
        'Giving a vague or confusing answer.',
        'Adding unnecessary information that distracts from the question.',
        'Memorizing a response that does not reflect your actual situation.',
        'Giving inconsistent or misleading information.',
      ],
      practiceTip:
          'Say your answer out loud once before practicing — it should sound like normal '
          'speech, not a written paragraph.',
    );
  }

  @override
  Future<AnswerFeedback> analyzeAnswer({
    required GuidanceQuestion question,
    required AnswerGuide guide,
    required String transcript,
  }) async {
    await _thinkingDelay();

    final trimmed = transcript.trim();
    final wordCount = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
    final lower = trimmed.toLowerCase();
    final hasVaguePhrase = _vaguePhrases.any(lower.contains);

    final completeness = _clamp01(wordCount / 30);
    final relevance = _clamp01(1 - (hasVaguePhrase ? 0.4 : 0.0) - (wordCount < 5 ? 0.4 : 0.0));
    final clarity = _clamp01(0.9 - (hasVaguePhrase ? 0.3 : 0.0));
    final naturalness = _clamp01(0.85 - (wordCount > 80 ? 0.2 : 0.0));
    const consistency = 0.9; // single-answer practice — nothing prior to contradict.

    final feedbackText = wordCount < 5
        ? "That's a good start, but try adding a bit more detail — one or two specifics "
              'about your actual situation would make this much stronger.'
        : hasVaguePhrase
        ? 'Good start! Your answer addresses the question, but a phrase or two reads as '
              'generic. Try replacing it with a specific detail from your real plans.'
        : "Nice work — that's a clear, relevant answer. Keep it this concise and specific "
              'when you practice again.';

    return AnswerFeedback(
      relevance: relevance,
      clarity: clarity,
      completeness: completeness,
      naturalness: naturalness,
      consistency: consistency,
      feedbackText: feedbackText,
      improvedExample: wordCount < 5 || hasVaguePhrase ? guide.exampleAnswer : null,
    );
  }

  String _intentFor(GuidanceCategory category) {
    switch (category) {
      case GuidanceCategory.travelPurpose:
        return 'A clear explanation of your purpose, relevant details about your plans, and '
            'an answer that is truthful and consistent with your situation.';
      case GuidanceCategory.personalBackground:
        return 'A concise, genuine sense of who you are and what you currently do.';
      case GuidanceCategory.employmentEducation:
        return 'Clarity on your current role or studies and why this next step makes sense '
            'for you.';
      case GuidanceCategory.financialArrangements:
        return 'Confidence that you can realistically support yourself during your stay.';
      case GuidanceCategory.accommodationAndTravelPlans:
        return 'A concrete, believable plan for where you will be and what you will be doing.';
      case GuidanceCategory.durationOfStay:
        return 'A specific timeframe that matches the rest of your stated plans.';
      case GuidanceCategory.familyConnections:
        return 'An honest picture of your ties, without over- or under-stating them.';
      case GuidanceCategory.followUpClarification:
        return 'A direct clarification that resolves the ambiguity, not a repeat of your '
            'first answer.';
      case GuidanceCategory.general:
        return 'A direct, honest answer that matches your actual situation.';
    }
  }

  String _exampleFor(GuidanceCategory category) {
    switch (category) {
      case GuidanceCategory.travelPurpose:
        return 'My purpose is to visit [country] for tourism. I plan to explore [places or '
            'activities] during my [duration]-day trip, staying at [accommodation] and '
            'returning home on [return date].';
      case GuidanceCategory.personalBackground:
        return "I'm currently [role/student] in [city], and in my free time I [activity]. "
            "This trip is part of [reason].";
      case GuidanceCategory.employmentEducation:
        return 'I currently work as [role] at [company], and I chose this [program/role] '
            'because [specific reason tied to your background].';
      case GuidanceCategory.financialArrangements:
        return 'I have saved [amount] specifically for this trip, and I will also be '
            'supported by [source] for [duration].';
      case GuidanceCategory.accommodationAndTravelPlans:
        return "I'll be staying at [accommodation] in [city] for [duration], and I already "
            'have my [itinerary detail] arranged.';
      case GuidanceCategory.durationOfStay:
        return "I plan to stay for [duration], arriving on [date] and returning on [date].";
      case GuidanceCategory.familyConnections:
        return 'My [relation] lives in [location], and I plan to [visit/stay in touch] '
            'during my time here.';
      case GuidanceCategory.followUpClarification:
        return "To clarify — [specific detail that directly resolves what was asked].";
      case GuidanceCategory.general:
        return 'My answer is [main point], because [one or two supporting details specific '
            'to your situation].';
    }
  }

  double _clamp01(double value) => value.isNaN ? 0 : value.clamp(0.0, 1.0);

  Future<void> _thinkingDelay() =>
      Future.delayed(Duration(milliseconds: 400 + _random.nextInt(400)));
}
