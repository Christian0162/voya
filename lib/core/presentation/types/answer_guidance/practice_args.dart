import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';

/// Navigation payload from the Answer Guide screen to the Practice screen —
/// the guide is already generated, so it's carried along rather than
/// re-fetched.
class PracticeArgs {
  const PracticeArgs({required this.question, required this.guide});

  final GuidanceQuestion question;
  final AnswerGuide guide;
}
