/// The practice-a-single-answer state machine — simpler than
/// [InterviewStatus] since there's one question, no timer, and no
/// multi-turn follow-ups.
enum PracticeAnswerStatus {
  initial,
  askingQuestion,
  listening,
  recording,
  processingAnswer,
  feedbackReady,
  error,
}
