import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';

/// Seed question banks keyed by purpose. This is the *starting* material the
/// mock AI draws from and adapts — not a fixed script the interview plays
/// back verbatim (follow-ups and clarifications are generated dynamically in
/// [MockAIInterviewService]).
class QuestionBank {
  const QuestionBank._();

  static List<String> forPurpose(InterviewPurpose purpose) {
    switch (purpose) {
      case InterviewPurpose.work:
        return const [
          'Tell me a little about yourself and your professional background.',
          'Why do you want to work abroad?',
          'What specific opportunities are you hoping to find in this country?',
          'Tell me about your most recent job and your main responsibilities.',
          'Why should we choose you for this role over other candidates?',
          'How do you plan to support yourself when you first arrive?',
          'Do you have any family or contacts already in this country?',
          'What do you know about the company or industry you plan to join?',
        ];
      case InterviewPurpose.study:
        return const [
          'Tell me about your academic background.',
          'Why did you choose this particular program?',
          'Why did you choose this country to study in rather than your home country?',
          'How do you plan to fund your studies and living expenses?',
          'What are your plans after you complete this program?',
          'What do you know about the institution you applied to?',
        ];
      case InterviewPurpose.visitor:
        return const [
          "What is the main purpose of your visit?",
          'How long do you plan to stay, and what is your itinerary?',
          'Who will you be staying with, or where will you be staying?',
          'What ties do you have to your home country that ensure you will return?',
          'How are you funding this trip?',
        ];
      case InterviewPurpose.immigration:
        return const [
          'Why do you want to immigrate to this country?',
          'Tell me about your ties to your current country of residence.',
          'How do you plan to support yourself and any dependents?',
          'What steps have you already taken toward this application?',
          'How do you plan to integrate into the community here?',
        ];
      case InterviewPurpose.recruitment:
        return const [
          'Walk me through your resume.',
          'What interests you about this position?',
          'Tell me about a challenge you faced at work and how you handled it.',
          'Where do you see yourself in the next few years?',
          'Why should we hire you over other applicants?',
        ];
    }
  }
}
