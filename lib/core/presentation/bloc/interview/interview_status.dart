/// The explicit interview conversation state machine (spec section 7/23).
/// Every screen decision (what to show, whether the mic is live) is driven
/// by this enum rather than scattered booleans.
enum InterviewStatus {
  initial,
  preparing,
  aiThinking,
  aiSpeaking,
  listening,
  userSpeaking,
  processingAnswer,
  generatingFeedback,
  completed,
  error,
}
