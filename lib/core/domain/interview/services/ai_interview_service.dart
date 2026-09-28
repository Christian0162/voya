import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';

import '../entities/answer_analysis.dart';
import '../entities/interview_question.dart';
import '../entities/interview_turn.dart';

/// Everything the interview conversation needs from "the AI". Nothing in the
/// bloc or UI depends on which provider implements this — swap
/// [MockAIInterviewService] for a real LLM-backed implementation later
/// without touching presentation code.
abstract class AIInterviewService {
  /// The first question the interviewer opens with.
  Future<InterviewQuestion> generateOpeningQuestion(InterviewConfiguration configuration);

  /// Analyzes the user's latest answer in context and decides whether it
  /// needs a follow-up/clarification, is vague, or seems inconsistent with
  /// earlier answers.
  Future<AnswerAnalysis> analyzeAnswer({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
    required InterviewTurn currentTurn,
  });

  /// The next planned question when no follow-up is needed.
  Future<InterviewQuestion> generateNextQuestion({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
  });

  /// Full post-interview feedback across every completed turn.
  Future<InterviewResult> generateFeedback({
    required InterviewConfiguration configuration,
    required List<InterviewTurn> history,
    required String sessionId,
  });
}
