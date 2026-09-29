import 'package:equatable/equatable.dart';

import 'package:voya/core/error/failure.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_feedback.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';

import 'practice_answer_status.dart';

class PracticeAnswerState extends Equatable {
  const PracticeAnswerState({
    this.status = PracticeAnswerStatus.initial,
    this.question,
    this.guide,
    this.liveTranscript = '',
    this.amplitude = 0,
    this.feedback,
    this.failure,
  });

  final PracticeAnswerStatus status;
  final GuidanceQuestion? question;
  final AnswerGuide? guide;
  final String liveTranscript;
  final double amplitude;
  final AnswerFeedback? feedback;
  final Failure? failure;

  PracticeAnswerState copyWith({
    PracticeAnswerStatus? status,
    GuidanceQuestion? question,
    AnswerGuide? guide,
    String? liveTranscript,
    double? amplitude,
    AnswerFeedback? feedback,
    Failure? failure,
    bool clearFailure = false,
    bool clearFeedback = false,
  }) {
    return PracticeAnswerState(
      status: status ?? this.status,
      question: question ?? this.question,
      guide: guide ?? this.guide,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      amplitude: amplitude ?? this.amplitude,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    question,
    guide,
    liveTranscript,
    amplitude,
    feedback,
    failure,
  ];
}
