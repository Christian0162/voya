/// Groups the answer-guidance question library into the topics interview
/// questions typically cover, independent of [InterviewPurpose] (which drives
/// the *mock interview*'s question bank, not the browsable coaching library).
enum GuidanceCategory {
  travelPurpose('Travel Purpose & Itinerary', 'Why you are traveling and what your plans are.'),
  personalBackground('Personal Background', 'Who you are and your general history.'),
  employmentEducation('Employment & Education', 'Your job, studies, or professional background.'),
  financialArrangements('Financial Arrangements', 'How you will fund your trip, studies, or stay.'),
  accommodationAndTravelPlans(
    'Accommodation & Travel Plans',
    'Where you will stay and how your trip is organized.',
  ),
  durationOfStay('Duration of Stay', 'How long you plan to stay and your return plans.'),
  familyConnections(
    'Family & Personal Connections',
    'Ties to people in your home country or destination.',
  ),
  followUpClarification(
    'Follow-up & Clarification',
    'Questions that probe deeper into an earlier answer.',
  ),

  /// Used when wrapping a question that came from a live mock interview
  /// (Mode B's "Need help?" button) rather than the browsable library, where
  /// the real category isn't known — never shown in the library browse
  /// screen itself.
  general('General Question', 'A question asked during your mock interview.');

  const GuidanceCategory(this.label, this.description);

  final String label;
  final String description;
}
