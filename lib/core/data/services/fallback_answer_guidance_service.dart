import 'package:flutter/foundation.dart';

import 'package:voya/core/domain/answer_guidance/entities/answer_feedback.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';

import 'gemini_answer_guidance_service.dart';

/// Wraps a real AI provider (e.g. [GeminiAnswerGuidanceService]) with a local
/// [fallback] so a provider outage doesn't stop the coaching flow — same
/// sticky-switch behavior as [FallbackAIInterviewService].
class FallbackAnswerGuidanceService implements AnswerGuidanceService {
  FallbackAnswerGuidanceService({required this.primary, required this.fallback});

  final AnswerGuidanceService primary;
  final AnswerGuidanceService fallback;

  bool _primaryFailed = false;

  Future<T> _call<T>(Future<T> Function(AnswerGuidanceService service) invoke) async {
    if (!_primaryFailed) {
      try {
        return await invoke(primary);
      } catch (e) {
        _primaryFailed = true;
        debugPrint(
          'AI provider failed ($e) — falling back to the offline answer coach for the rest of this session.',
        );
      }
    }
    return invoke(fallback);
  }

  @override
  Future<AnswerGuide> generateGuide(GuidanceQuestion question) =>
      _call((service) => service.generateGuide(question));

  @override
  Future<AnswerFeedback> analyzeAnswer({
    required GuidanceQuestion question,
    required AnswerGuide guide,
    required String transcript,
  }) => _call(
    (service) => service.analyzeAnswer(question: question, guide: guide, transcript: transcript),
  );
}
