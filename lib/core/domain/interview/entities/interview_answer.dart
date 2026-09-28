import 'package:equatable/equatable.dart';

/// A single analyzed answer from the user, tied to the question it responds to.
class InterviewAnswer extends Equatable {
  const InterviewAnswer({
    required this.questionId,
    required this.transcript,
    required this.spokenDuration,
    required this.fillerWordCounts,
    required this.wordCount,
    this.wasVague = false,
  });

  final String questionId;
  final String transcript;
  final Duration spokenDuration;

  /// e.g. {"um": 3, "like": 1}
  final Map<String, int> fillerWordCounts;
  final int wordCount;
  final bool wasVague;

  int get totalFillerWords => fillerWordCounts.values.fold(0, (a, b) => a + b);

  double get wordsPerMinute {
    final minutes = spokenDuration.inMilliseconds / 60000;
    if (minutes <= 0) return 0;
    return wordCount / minutes;
  }

  @override
  List<Object?> get props =>
      [questionId, transcript, spokenDuration, fillerWordCounts, wordCount, wasVague];
}
