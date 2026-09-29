import 'package:equatable/equatable.dart';

/// Structured coaching guidance for one [GuidanceQuestion] — the six fields
/// asked of the AI coach (spec section 9): what the question means, what the
/// interviewer wants, how to structure a reply, a sample answer, mistakes to
/// avoid, and one practice tip.
class AnswerGuide extends Equatable {
  const AnswerGuide({
    required this.questionExplanation,
    required this.interviewerIntent,
    required this.answerStructure,
    required this.exampleAnswer,
    required this.commonMistakes,
    required this.practiceTip,
  });

  final String questionExplanation;
  final String interviewerIntent;
  final List<String> answerStructure;
  final String exampleAnswer;
  final List<String> commonMistakes;
  final String practiceTip;

  @override
  List<Object?> get props => [
    questionExplanation,
    interviewerIntent,
    answerStructure,
    exampleAnswer,
    commonMistakes,
    practiceTip,
  ];
}
