import 'package:equatable/equatable.dart';

import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';

import 'interview_turn.dart';

/// The live/completed record of one interview run. Distinct from
/// [InterviewConfiguration] (the setup) and [InterviewResult] (the scoring) —
/// this is the conversation itself.
class InterviewSession extends Equatable {
  const InterviewSession({
    required this.id,
    required this.configuration,
    required this.startedAt,
    this.turns = const [],
    this.endedAt,
  });

  final String id;
  final InterviewConfiguration configuration;
  final DateTime startedAt;
  final List<InterviewTurn> turns;
  final DateTime? endedAt;

  bool get isComplete => endedAt != null;

  InterviewSession copyWith({
    List<InterviewTurn>? turns,
    DateTime? endedAt,
  }) {
    return InterviewSession(
      id: id,
      configuration: configuration,
      startedAt: startedAt,
      turns: turns ?? this.turns,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  List<Object?> get props => [id, configuration, startedAt, turns, endedAt];
}
