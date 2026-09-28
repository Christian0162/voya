import 'package:equatable/equatable.dart';

import 'package:voya/core/error/failure.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';

import 'interview_status.dart';

class InterviewState extends Equatable {
  const InterviewState({
    this.status = InterviewStatus.initial,
    this.configuration,
    this.sessionId,
    this.turns = const [],
    this.currentQuestion,
    this.liveTranscript = '',
    this.amplitude = 0,
    this.elapsed = Duration.zero,
    this.failure,
    this.result,
  });

  final InterviewStatus status;
  final InterviewConfiguration? configuration;
  final String? sessionId;
  final List<InterviewTurn> turns;
  final InterviewQuestion? currentQuestion;
  final String liveTranscript;
  final double amplitude;
  final Duration elapsed;
  final Failure? failure;
  final InterviewResult? result;

  int get questionNumber => turns.length + (currentQuestion == null ? 0 : 1);

  int get estimatedTotalQuestions {
    if (configuration == null) return 0;
    return (configuration!.durationMinutes * 0.9).round().clamp(4, 18);
  }

  Duration get remaining {
    if (configuration == null) return Duration.zero;
    final total = Duration(minutes: configuration!.durationMinutes);
    final left = total - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  InterviewState copyWith({
    InterviewStatus? status,
    InterviewConfiguration? configuration,
    String? sessionId,
    List<InterviewTurn>? turns,
    InterviewQuestion? currentQuestion,
    String? liveTranscript,
    double? amplitude,
    Duration? elapsed,
    Failure? failure,
    InterviewResult? result,
    bool clearFailure = false,
  }) {
    return InterviewState(
      status: status ?? this.status,
      configuration: configuration ?? this.configuration,
      sessionId: sessionId ?? this.sessionId,
      turns: turns ?? this.turns,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      amplitude: amplitude ?? this.amplitude,
      elapsed: elapsed ?? this.elapsed,
      failure: clearFailure ? null : (failure ?? this.failure),
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
    status,
    configuration,
    sessionId,
    turns,
    currentQuestion,
    liveTranscript,
    amplitude,
    elapsed,
    failure,
    result,
  ];
}
