import 'package:equatable/equatable.dart';

import 'interview_answer.dart';
import 'interview_question.dart';

/// One question/answer pair, in the order it happened — the backbone of the
/// transcript view.
class InterviewTurn extends Equatable {
  const InterviewTurn({required this.question, this.answer});

  final InterviewQuestion question;
  final InterviewAnswer? answer;

  InterviewTurn copyWithAnswer(InterviewAnswer answer) {
    return InterviewTurn(question: question, answer: answer);
  }

  @override
  List<Object?> get props => [question, answer];
}
