import 'package:voya/config/constant/app_constants.dart';
import 'package:voya/core/domain/interview/entities/interview_answer.dart';

/// Turns a raw transcript + timing into an [InterviewAnswer], counting filler
/// words locally (spec section 18). Pure function, easy to unit test.
class AnswerBuilder {
  const AnswerBuilder._();

  static InterviewAnswer build({
    required String questionId,
    required String transcript,
    required Duration spokenDuration,
  }) {
    final trimmed = transcript.trim();
    final words = trimmed.isEmpty ? <String>[] : trimmed.split(RegExp(r'\s+'));
    final lower = trimmed.toLowerCase();

    final fillerCounts = <String, int>{};
    for (final filler in AppConstants.fillerWords) {
      final pattern = RegExp(r'\b' + RegExp.escape(filler) + r'\b');
      final count = pattern.allMatches(lower).length;
      if (count > 0) fillerCounts[filler] = count;
    }

    return InterviewAnswer(
      questionId: questionId,
      transcript: trimmed,
      spokenDuration: spokenDuration,
      fillerWordCounts: fillerCounts,
      wordCount: words.length,
    );
  }
}
