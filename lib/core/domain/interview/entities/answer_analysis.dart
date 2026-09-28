import 'package:equatable/equatable.dart';

/// Result of analyzing a single answer — used by the bloc to decide whether
/// to ask a follow-up/clarification question or move on.
class AnswerAnalysis extends Equatable {
  const AnswerAnalysis({
    required this.isVague,
    required this.isInconsistent,
    required this.followUpQuestion,
    this.inconsistencyNote,
  });

  final bool isVague;
  final bool isInconsistent;

  /// Null when the AI decides to move to the next planned question instead
  /// of following up on this answer.
  final String? followUpQuestion;
  final String? inconsistencyNote;

  bool get needsFollowUp => followUpQuestion != null;

  @override
  List<Object?> get props => [isVague, isInconsistent, followUpQuestion, inconsistencyNote];
}
