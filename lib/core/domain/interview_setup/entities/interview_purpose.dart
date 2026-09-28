/// Why the user is interviewing — drives the question bank and framing the
/// AI interviewer uses (see AIInterviewService.generateQuestion).
enum InterviewPurpose {
  work('Overseas Employment', 'Practice a job or work-visa interview.'),
  study('Student / Education', 'Practice a study permit or admissions interview.'),
  visitor('Visitor / Tourist Visa', 'Practice a short-stay visa interview.'),
  immigration('Immigration', 'Practice a permanent residency or citizenship interview.'),
  recruitment('Recruitment', 'Practice a general job recruitment interview.');

  const InterviewPurpose(this.label, this.description);

  final String label;
  final String description;
}
