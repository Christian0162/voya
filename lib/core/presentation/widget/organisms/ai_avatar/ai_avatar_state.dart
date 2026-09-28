/// Visual states of the AI avatar. Kept separate from [InterviewState]
/// (the bloc's conversation state machine) so the avatar widget can be
/// reused anywhere without depending on interview business logic — it only
/// needs to know how to *look*, not why.
enum AiAvatarState { idle, thinking, speaking, listening, processing }
