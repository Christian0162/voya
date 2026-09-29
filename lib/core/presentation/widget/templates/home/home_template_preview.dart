import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';
import 'package:voya/core/presentation/widget/molecules/md_progress_summary_card.dart';

import 'home_template.dart';

/// Standalone preview harness for [HomeTemplate] — renders it with fixture
/// data so it can be visually checked without a repository, router or bloc.
class HomeTemplatePreview extends StatelessWidget {
  const HomeTemplatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: HomeTemplate(
        greeting: 'Good morning',
        isLoadingRecent: false,
        recentEntries: [
          InterviewHistoryEntry(
            sessionId: '1',
            countryName: 'Australia',
            countryFlag: '🇦🇺',
            purpose: InterviewPurpose.work,
            difficulty: InterviewDifficulty.professional,
            durationMinutes: 10,
            startedAt: DateTime.now().subtract(const Duration(minutes: 18)),
            turnCount: 9,
            overallScore: 0.82,
          ),
        ],
        stats: const ProgressStats(totalPractices: 6, averageScore: 0.82, practicedThisWeek: 2),
        onStartInterview: () {},
        onRefresh: () async {},
        onAnswerCoachPressed: () {},
      ),
    );
  }
}
