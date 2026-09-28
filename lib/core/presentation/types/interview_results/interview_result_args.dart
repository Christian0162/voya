import 'package:voya/core/domain/interview/entities/interview_turn.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';

/// Navigation payload passed from the just-finished interview screen to the
/// result screen so the freshly computed result and transcript don't need a
/// round trip through storage. When a result is opened later from History,
/// only [result] is available (transcript detail isn't persisted — see
/// InterviewRepositoryImpl) and [turns] is empty.
class InterviewResultArgs {
  const InterviewResultArgs({
    required this.result,
    required this.configuration,
    this.turns = const [],
  });

  final InterviewResult result;
  final InterviewConfiguration configuration;
  final List<InterviewTurn> turns;
}
