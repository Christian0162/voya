import 'package:equatable/equatable.dart';

import 'country.dart';
import 'interview_difficulty.dart';
import 'interview_purpose.dart';

/// Everything needed to start a session. Immutable and fully assembled
/// before the interview begins — the AI service and bloc never mutate
/// individual fields, they build a new configuration via [copyWith].
class InterviewConfiguration extends Equatable {
  const InterviewConfiguration({
    required this.country,
    required this.purpose,
    required this.difficulty,
    required this.durationMinutes,
    this.jobOrProgramTitle,
    this.resumeHighlights,
  });

  final Country country;
  final InterviewPurpose purpose;
  final InterviewDifficulty difficulty;
  final int durationMinutes;

  /// e.g. "Software Developer" or "MSc Data Science" — optional personalization.
  final String? jobOrProgramTitle;

  /// Optional free-text resume/CV highlights used to personalize questions
  /// (see spec section 20). Not required for the MVP flow.
  final String? resumeHighlights;

  InterviewConfiguration copyWith({
    Country? country,
    InterviewPurpose? purpose,
    InterviewDifficulty? difficulty,
    int? durationMinutes,
    String? jobOrProgramTitle,
    String? resumeHighlights,
  }) {
    return InterviewConfiguration(
      country: country ?? this.country,
      purpose: purpose ?? this.purpose,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      jobOrProgramTitle: jobOrProgramTitle ?? this.jobOrProgramTitle,
      resumeHighlights: resumeHighlights ?? this.resumeHighlights,
    );
  }

  @override
  List<Object?> get props =>
      [country, purpose, difficulty, durationMinutes, jobOrProgramTitle, resumeHighlights];
}
