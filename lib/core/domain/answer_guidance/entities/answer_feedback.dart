import 'package:equatable/equatable.dart';

/// Feedback on one practiced answer, scored the same way [InterviewResult]
/// scores a full interview (multiple 0.0-1.0 dimensions rather than one
/// number) plus the supportive narrative text and optional improved example
/// shown to the user (spec section 3).
class AnswerFeedback extends Equatable {
  const AnswerFeedback({
    required this.relevance,
    required this.clarity,
    required this.completeness,
    required this.naturalness,
    required this.consistency,
    required this.feedbackText,
    this.improvedExample,
  });

  /// 0.0-1.0 dimension scores.
  final double relevance;
  final double clarity;
  final double completeness;
  final double naturalness;
  final double consistency;

  /// Supportive, specific narrative feedback (e.g. "Good start! ...").
  final String feedbackText;

  /// An optional improved version of the user's own answer, built only from
  /// details they actually gave, with placeholders for anything missing.
  final String? improvedExample;

  @override
  List<Object?> get props => [
    relevance,
    clarity,
    completeness,
    naturalness,
    consistency,
    feedbackText,
    improvedExample,
  ];
}
