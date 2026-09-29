import 'package:equatable/equatable.dart';

import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';

abstract class AnswerGuideEvent extends Equatable {
  const AnswerGuideEvent();

  @override
  List<Object?> get props => [];
}

class GuideRequested extends AnswerGuideEvent {
  const GuideRequested(this.question);
  final GuidanceQuestion question;

  @override
  List<Object?> get props => [question];
}
