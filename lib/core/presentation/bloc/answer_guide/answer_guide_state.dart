import 'package:equatable/equatable.dart';

import 'package:voya/core/error/failure.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';

enum AnswerGuideStatus { initial, loading, loaded, error }

class AnswerGuideState extends Equatable {
  const AnswerGuideState({
    this.status = AnswerGuideStatus.initial,
    this.question,
    this.guide,
    this.failure,
  });

  final AnswerGuideStatus status;
  final GuidanceQuestion? question;
  final AnswerGuide? guide;
  final Failure? failure;

  AnswerGuideState copyWith({
    AnswerGuideStatus? status,
    GuidanceQuestion? question,
    AnswerGuide? guide,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AnswerGuideState(
      status: status ?? this.status,
      question: question ?? this.question,
      guide: guide ?? this.guide,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, question, guide, failure];
}
