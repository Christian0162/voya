import 'dart:math';

import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview/entities/answer_analysis.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';
import 'package:voya/core/domain/interview/services/ai_interview_service.dart';

import 'question_bank.dart';

/// Local, rule-based interview "AI".
///
/// This keeps the app fully functional offline with no API key to leak
/// (spec section 31), while conforming to the exact same [AIInterviewService]
/// contract a real LLM-backed implementation would use — swapping in a real
/// provider later means writing one new class, not touching the bloc or UI.
///
/// The heuristics are intentionally simple (vague-answer detection by length
/// and generic phrasing, not real NLU) but they produce genuinely different
/// follow-ups per answer, which is the behavior the product spec asks for.
class MockAIInterviewService implements AIInterviewService {
  MockAIInterviewService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _vaguePhrases = [
    'better opportunities',
    'good opportunities',
    'good life',
    'better life',
    'more money',
    'just because',
    'no reason',
    'i don\'t know',
    'not sure',
  ];

  @override
  Future<InterviewQuestion> generateOpeningQuestion(InterviewConfiguration configuration) async {
    await _thinkingDelay();
    final bank = QuestionBank.forPurpose(configuration.purpose);
    return InterviewQuestion(id: 'q0', text: bank.first, kind: QuestionKind.opening, order: 0);
  }

  @override
  Future<AnswerAnalysis> analyzeAnswer({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
    required InterviewTurn currentTurn,
  }) async {
    await _thinkingDelay();

    final answer = currentTurn.answer;
    if (answer == null) {
      return const AnswerAnalysis(isVague: false, isInconsistent: false, followUpQuestion: null);
    }

    final transcript = answer.transcript.trim();
    final lower = transcript.toLowerCase();
    final isTooShort = answer.wordCount < 8;
    final hasVaguePhrase = _vaguePhrases.any(lower.contains);
    final isVague = isTooShort || hasVaguePhrase;

    final inconsistencyNote = _detectInconsistency(history, transcript);
    final isInconsistent = inconsistencyNote != null;

    final shouldFollowUp = isVague || isInconsistent || _shouldProbeDeeper(configuration);
    if (!shouldFollowUp) {
      return const AnswerAnalysis(isVague: false, isInconsistent: false, followUpQuestion: null);
    }

    final followUp = _buildFollowUp(
      configuration: configuration,
      question: currentTurn.question.text,
      answer: transcript,
      isVague: isVague,
      inconsistencyNote: inconsistencyNote,
    );

    return AnswerAnalysis(
      isVague: isVague,
      isInconsistent: isInconsistent,
      followUpQuestion: followUp,
      inconsistencyNote: inconsistencyNote,
    );
  }

  @override
  Future<InterviewQuestion> generateNextQuestion({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
  }) async {
    await _thinkingDelay();
    final bank = QuestionBank.forPurpose(configuration.purpose);
    final askedTexts = history.map((t) => t.question.text).toSet();
    final remaining = bank.where((q) => !askedTexts.contains(q)).toList();

    final nextOrder = history.length;
    if (remaining.isEmpty) {
      return InterviewQuestion(
        id: 'q$nextOrder',
        text: 'Is there anything else you would like me to know before we finish?',
        kind: QuestionKind.closing,
        order: nextOrder,
      );
    }

    return InterviewQuestion(
      id: 'q$nextOrder',
      text: remaining.first,
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
    await _thinkingDelay();

    final answered = history.where((t) => t.answer != null).toList();
    final totalWords = answered.fold<int>(0, (sum, t) => sum + t.answer!.wordCount);
    final totalFillers = <String, int>{};
    for (final turn in answered) {
      turn.answer!.fillerWordCounts.forEach((word, count) {
        totalFillers[word] = (totalFillers[word] ?? 0) + count;
      });
    }
    final totalFillerCount = totalFillers.values.fold(0, (a, b) => a + b);
    final avgWordsPerAnswer = answered.isEmpty ? 0 : totalWords / answered.length;
    final avgPace = answered.isEmpty
        ? 0.0
        : answered.map((t) => t.answer!.wordsPerMinute).reduce((a, b) => a + b) / answered.length;

    final clarity = _clamp01(1 - (totalFillerCount / (totalWords == 0 ? 1 : totalWords)) * 6);
    final answerQuality = _clamp01(avgWordsPerAnswer / 40);
    final communication = _clamp01((clarity + answerQuality) / 2 + 0.05);
    final speakingPace = _clamp01(1 - ((avgPace - 130).abs() / 130));
    final vagueCount = answered.where((t) => t.answer!.wordCount < 8).length;
    final consistency = _clamp01(1 - (vagueCount / max(1, answered.length)) * 0.7);

    final strengths = <String>[];
    final practiceAreas = <String>[];

    if (answerQuality > 0.6) strengths.add('Answers were well structured and detailed.');
    if (clarity > 0.75) strengths.add('Very few filler words — clear, confident delivery.');
    if (consistency > 0.75) strengths.add('Consistent and specific across follow-up questions.');
    if (strengths.isEmpty) strengths.add('You completed the full interview — good practice rep.');

    if (totalFillerCount > 5) {
      practiceAreas.add(
        'Several filler words were detected ($totalFillerCount total). Try pausing silently instead.',
      );
    }
    if (vagueCount > 0) {
      practiceAreas.add('$vagueCount answer${vagueCount == 1 ? '' : 's'} could be more specific.');
    }
    if (avgPace > 170) {
      practiceAreas.add(
        'Your speaking pace increased on some answers — try slowing down slightly.',
      );
    }
    if (practiceAreas.isEmpty) {
      practiceAreas.add('Keep practicing to build even more consistency under pressure.');
    }

    final questionsToPractice = answered
        .where((t) => t.answer!.wordCount < 8 || t.answer!.totalFillerWords > 2)
        .map((t) => t.question.text)
        .take(3)
        .toList();
    if (questionsToPractice.isEmpty && history.isNotEmpty) {
      questionsToPractice.add(history.first.question.text);
    }

    return InterviewResult(
      sessionId: sessionId,
      completedAt: DateTime.now(),
      communication: communication,
      clarity: clarity,
      answerQuality: answerQuality,
      speakingPace: speakingPace,
      consistency: consistency,
      strengths: strengths,
      practiceAreas: practiceAreas,
      questionsToPractice: questionsToPractice,
      fillerWordCounts: totalFillers,
    );
  }

  String? _detectInconsistency(List<InterviewTurn> history, String newAnswer) {
    final yearsMatch = RegExp(r'(\d+)\s*(?:years?|yrs?)').firstMatch(newAnswer.toLowerCase());
    if (yearsMatch == null) return null;
    final newYears = int.tryParse(yearsMatch.group(1)!);
    if (newYears == null) return null;

    for (final turn in history) {
      final prevAnswer = turn.answer?.transcript.toLowerCase();
      if (prevAnswer == null) continue;
      final prevMatch = RegExp(r'(\d+)\s*(?:years?|yrs?)').firstMatch(prevAnswer);
      if (prevMatch == null) continue;
      final prevYears = int.tryParse(prevMatch.group(1)!);
      if (prevYears != null && (prevYears - newYears).abs() >= 2) {
        return 'Mentioned $prevYears years earlier, now $newYears years.';
      }
    }
    return null;
  }

  bool _shouldProbeDeeper(InterviewConfiguration configuration) {
    if (configuration.difficulty == InterviewDifficulty.pressure) {
      return _random.nextDouble() < 0.45;
    }
    if (configuration.difficulty == InterviewDifficulty.professional) {
      return _random.nextDouble() < 0.2;
    }
    return false;
  }

  String _buildFollowUp({
    required InterviewConfiguration configuration,
    required String question,
    required String answer,
    required bool isVague,
    String? inconsistencyNote,
  }) {
    if (inconsistencyNote != null) {
      return 'You mentioned "$inconsistencyNote" — could you clarify the exact timeframe?';
    }

    final topic = _extractTopic(answer) ?? _extractTopic(question) ?? 'that';

    switch (configuration.difficulty) {
      case InterviewDifficulty.pressure:
        return isVague
            ? 'That was quite general — give me one concrete, specific example about $topic.'
            : 'You mentioned $topic. Walk me through a specific situation that demonstrates it.';
      case InterviewDifficulty.strict:
        return 'Be more specific about $topic.';
      case InterviewDifficulty.friendly:
        return "That's a good start — could you tell me a bit more about $topic?";
      case InterviewDifficulty.professional:
        return 'Could you elaborate on $topic with a specific example?';
    }
  }

  String? _extractTopic(String text) {
    final words = text
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 4)
        .toList();
    if (words.isEmpty) return null;
    words.sort((a, b) => b.length.compareTo(a.length));
    return words.first.toLowerCase();
  }

  double _clamp01(double value) => value.isNaN ? 0 : value.clamp(0.0, 1.0);

  Future<void> _thinkingDelay() =>
      Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
}
