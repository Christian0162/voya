import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';
import 'package:voya/core/presentation/types/interview_results/interview_result_args.dart';

import 'interview_result_template.dart';

class InterviewResultTemplatePreview extends StatelessWidget {
  const InterviewResultTemplatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final args = InterviewResultArgs(
      configuration: const InterviewConfiguration(
        country: Country(code: 'AU', name: 'Australia', flagEmoji: '🇦🇺'),
        purpose: InterviewPurpose.work,
        difficulty: InterviewDifficulty.professional,
        durationMinutes: 10,
      ),
      result: InterviewResult(
        sessionId: 'preview',
        completedAt: DateTime.now(),
        communication: 0.82,
        clarity: 0.88,
        answerQuality: 0.74,
        speakingPace: 0.81,
        consistency: 0.91,
        strengths: const [
          'Clear explanation of previous experience',
          'Strong knowledge of the role',
        ],
        practiceAreas: const ['Some answers were too short', 'A few filler words were detected'],
        questionsToPractice: const ['Why do you want to work abroad?'],
        fillerWordCounts: const {'um': 7, 'uh': 3, 'like': 2},
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: InterviewResultTemplate(
        args: args,
        hasTranscript: false,
        onShowTranscript: () {},
        onPracticeAgain: () {},
        onBackHome: () {},
      ),
    );
  }
}
