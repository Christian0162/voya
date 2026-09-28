/// The interviewer personality/mode. Adding a new mode means adding a case
/// here and a matching prompt profile in the AI service — nothing in the UI
/// needs to branch on it beyond rendering [label]/[description].
enum InterviewDifficulty {
  professional(
    'Professional',
    'Formal but friendly. A balanced, realistic interview.',
  ),
  friendly(
    'Friendly',
    'Conversational and encouraging — great for first practice runs.',
  ),
  strict(
    'Strict',
    'Shorter questions, less conversational assistance.',
  ),
  pressure(
    'Pressure',
    'Challenges vague or inconsistent answers directly.',
  );

  const InterviewDifficulty(this.label, this.description);

  final String label;
  final String description;
}
