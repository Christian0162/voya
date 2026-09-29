import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';

/// The curated, browsable question library for the Answer Coach feature
/// (spec section 5) — a different taxonomy from [QuestionBank]'s
/// [InterviewPurpose] grouping, since this one is browsed directly by
/// category rather than drawn from for a live interview.
class GuidanceQuestionLibrary {
  const GuidanceQuestionLibrary._();

  static List<GuidanceQuestion> forCategory(GuidanceCategory category) {
    final texts = switch (category) {
      GuidanceCategory.travelPurpose => const [
        'What is the purpose of your visit?',
        'What do you plan to do during your trip?',
        'Why did you choose this particular destination?',
      ],
      GuidanceCategory.personalBackground => const [
        'Tell me a little about yourself.',
        'What do you currently do for work or study?',
      ],
      GuidanceCategory.employmentEducation => const [
        'Tell me about your current job or studies.',
        'Why did you choose this program or role?',
      ],
      GuidanceCategory.financialArrangements => const [
        'How are you funding this trip or your studies?',
        'Who is financially supporting you during your stay?',
      ],
      GuidanceCategory.accommodationAndTravelPlans => const [
        'Where will you be staying during your trip?',
        'Do you have your travel itinerary planned out?',
      ],
      GuidanceCategory.durationOfStay => const [
        'How long do you plan to stay?',
        'What date do you plan to return home?',
      ],
      GuidanceCategory.familyConnections => const [
        'Do you have family or friends in this country?',
        'What ties do you have to your home country?',
      ],
      GuidanceCategory.followUpClarification => const [
        'Can you clarify that answer in more detail?',
        'You mentioned something earlier — can you tell me more about it?',
      ],
      // Never browsed directly — see GuidanceCategory.general's doc comment.
      GuidanceCategory.general => const [],
    };

    return [
      for (var i = 0; i < texts.length; i++)
        GuidanceQuestion(id: '${category.name}_$i', text: texts[i], category: category),
    ];
  }
}
