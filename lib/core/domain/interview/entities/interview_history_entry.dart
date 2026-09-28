import 'package:equatable/equatable.dart';

import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';

/// A lightweight summary of a past session for list/history UIs (Home's
/// "Recent Practice" and the History screen). Deliberately not the full
/// [InterviewSession] — the transcript and turn-by-turn detail aren't needed
/// until the user opens a specific result, at which point
/// [InterviewRepository.getResult] has the full scoring breakdown.
class InterviewHistoryEntry extends Equatable {
  const InterviewHistoryEntry({
    required this.sessionId,
    required this.countryName,
    required this.countryFlag,
    required this.purpose,
    required this.difficulty,
    required this.durationMinutes,
    required this.startedAt,
    required this.turnCount,
    this.overallScore,
  });

  final String sessionId;
  final String countryName;
  final String countryFlag;
  final InterviewPurpose purpose;
  final InterviewDifficulty difficulty;
  final int durationMinutes;
  final DateTime startedAt;
  final int turnCount;
  final double? overallScore;

  @override
  List<Object?> get props => [
        sessionId,
        countryName,
        countryFlag,
        purpose,
        difficulty,
        durationMinutes,
        startedAt,
        turnCount,
        overallScore,
      ];
}
