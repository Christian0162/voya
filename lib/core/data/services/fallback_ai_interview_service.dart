import 'package:flutter/foundation.dart';

import 'package:voya/core/domain/interview/entities/answer_analysis.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';
import 'package:voya/core/domain/interview/services/ai_interview_service.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';

import 'gemini_ai_interview_service.dart';

/// Wraps a real AI provider (e.g. [GeminiAIInterviewService]) with a local
/// [fallback] so a provider outage (rate limit, 503, network blip — the kind
/// of thing that isn't a configuration mistake and can't be fixed mid
/// interview) doesn't stop the interview cold.
///
/// The switch is sticky for the lifetime of this instance: once [primary]
/// fails once, every subsequent call goes straight to [fallback] instead of
/// re-trying (and re-waiting on) a provider that's already down. Since
/// `AiServiceFactory` builds a fresh instance per interview session, this
/// naturally resets — a later session tries the real provider again.
class FallbackAIInterviewService implements AIInterviewService {
  FallbackAIInterviewService({required this.primary, required this.fallback});

  final AIInterviewService primary;
  final AIInterviewService fallback;

  bool _primaryFailed = false;

  Future<T> _call<T>(Future<T> Function(AIInterviewService service) invoke) async {
    if (!_primaryFailed) {
      try {
        return await invoke(primary);
      } catch (e) {
        _primaryFailed = true;
        debugPrint(
          'AI provider failed ($e) — falling back to the offline interviewer for the rest of this session.',
        );
      }
    }
    return invoke(fallback);
  }

  @override
  Future<InterviewQuestion> generateOpeningQuestion(InterviewConfiguration configuration) =>
      _call((service) => service.generateOpeningQuestion(configuration));

  @override
  Future<AnswerAnalysis> analyzeAnswer({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
    required InterviewTurn currentTurn,
  }) => _call(
    (service) => service.analyzeAnswer(
      configuration: configuration,
      history: history,
      currentTurn: currentTurn,
    ),
  );

  @override
  Future<InterviewQuestion> generateNextQuestion({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
  }) => _call(
    (service) => service.generateNextQuestion(configuration: configuration, history: history),
  );

  @override
  Future<InterviewResult> generateFeedback({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
    required String sessionId,
  }) => _call(
    (service) => service.generateFeedback(
      configuration: configuration,
      history: history,
      sessionId: sessionId,
    ),
  );
}
