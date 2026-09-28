import 'package:equatable/equatable.dart';

/// Multi-dimensional post-interview scoring — deliberately not a single
/// number (spec section 17: "do not reduce everything to one arbitrary score").
class InterviewResult extends Equatable {
  const InterviewResult({
    required this.sessionId,
    required this.completedAt,
    required this.communication,
    required this.clarity,
    required this.answerQuality,
    required this.speakingPace,
    required this.consistency,
    required this.strengths,
    required this.practiceAreas,
    required this.questionsToPractice,
    required this.fillerWordCounts,
  });

  final String sessionId;
  final DateTime completedAt;

  /// 0.0–1.0 dimension scores, rendered as progress bars.
  final double communication;
  final double clarity;
  final double answerQuality;
  final double speakingPace;
  final double consistency;

  final List<String> strengths;
  final List<String> practiceAreas;
  final List<String> questionsToPractice;
  final Map<String, int> fillerWordCounts;

  double get overallAverage =>
      (communication + clarity + answerQuality + speakingPace + consistency) / 5;

  @override
  List<Object?> get props => [
    sessionId,
    completedAt,
    communication,
    clarity,
    answerQuality,
    speakingPace,
    consistency,
    strengths,
    practiceAreas,
    questionsToPractice,
    fillerWordCounts,
  ];
}
