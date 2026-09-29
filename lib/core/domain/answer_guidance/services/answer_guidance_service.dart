import '../entities/answer_feedback.dart';
import '../entities/answer_guide.dart';
import '../entities/guidance_question.dart';

/// Everything the Answer Coach feature needs from "the AI" — mirrors
/// [AIInterviewService]'s role for the mock interview, so a real LLM-backed
/// implementation and an offline mock implementation can be swapped without
/// touching any bloc or UI code.
abstract class AnswerGuidanceService {
  /// Generates the full coaching guide for [question].
  Future<AnswerGuide> generateGuide(GuidanceQuestion question);

  /// Analyzes the user's spoken [transcript] against [question] and the
  /// [guide] they were shown, returning supportive, specific feedback.
  Future<AnswerFeedback> analyzeAnswer({
    required GuidanceQuestion question,
    required AnswerGuide guide,
    required String transcript,
  });
}
