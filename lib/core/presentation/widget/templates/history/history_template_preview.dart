import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';

import 'history_template.dart';

class HistoryTemplatePreview extends StatelessWidget {
  const HistoryTemplatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: HistoryTemplate(
        isLoading: false,
        entries: [
          InterviewHistoryEntry(
            sessionId: '1',
            countryName: 'Canada',
            countryFlag: '🇨🇦',
            purpose: InterviewPurpose.study,
            difficulty: InterviewDifficulty.friendly,
            durationMinutes: 15,
            startedAt: DateTime.now().subtract(const Duration(days: 1)),
            turnCount: 12,
            overallScore: 0.74,
          ),
        ],
        onStartInterview: () {},
      ),
    );
  }
}
