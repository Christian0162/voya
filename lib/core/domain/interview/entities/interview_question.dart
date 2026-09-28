import 'package:equatable/equatable.dart';

enum QuestionKind { opening, standard, followUp, clarification, closing }

class InterviewQuestion extends Equatable {
  const InterviewQuestion({
    required this.id,
    required this.text,
    required this.kind,
    required this.order,
  });

  final String id;
  final String text;
  final QuestionKind kind;
  final int order;

  @override
  List<Object?> get props => [id, text, kind, order];
}
