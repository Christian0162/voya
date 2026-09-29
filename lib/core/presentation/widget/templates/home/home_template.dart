import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_constants.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/presentation/widget/atoms/md_primary_button.dart';
import 'package:voya/core/presentation/widget/molecules/md_empty_state.dart';
import 'package:voya/core/presentation/widget/molecules/md_home_hero_card.dart';
import 'package:voya/core/presentation/widget/molecules/md_mascot_face.dart';
import 'package:voya/core/presentation/widget/molecules/md_progress_summary_card.dart';
import 'package:voya/core/presentation/widget/molecules/md_recent_practice_tile.dart';

/// Pure layout for Home. No logic, no repository access — everything it
/// needs arrives as data or a callback (spec: templates are plain data +
/// callbacks in).
class HomeTemplate extends StatelessWidget {
  const HomeTemplate({
    super.key,
    required this.greeting,
    required this.isLoadingRecent,
    required this.recentEntries,
    required this.stats,
    required this.onStartInterview,
    required this.onRefresh,
    required this.onAnswerCoachPressed,
  });

  final String greeting;
  final bool isLoadingRecent;
  final List<InterviewHistoryEntry> recentEntries;
  final ProgressStats stats;
  final VoidCallback onStartInterview;
  final Future<void> Function() onRefresh;
  final VoidCallback onAnswerCoachPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MdMascotFace(size: 28),
            const SizedBox(width: AppSpacing.sm),
            Text(AppConstants.appName),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('Ready for your next interview?', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              MdHomeHeroCard(onStart: onStartInterview),
              const SizedBox(height: AppSpacing.md),
              MdPrimaryButton(
                label: 'Answer Coach',
                icon: Icons.lightbulb_outline_rounded,
                variant: MdButtonVariant.secondary,
                onPressed: onAnswerCoachPressed,
              ),
              const SizedBox(height: AppSpacing.xl),
              MdProgressSummaryCard(stats: stats),
              const SizedBox(height: AppSpacing.xl),
              Text('Recent Practice', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              if (!isLoadingRecent && recentEntries.isEmpty)
                const MdEmptyState(
                  icon: Icons.history_rounded,
                  iconColor: AppColors.primary,
                  title: 'No practice yet',
                  message: 'Your completed interviews will show up here.',
                )
              else
                for (final entry in recentEntries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: MdRecentPracticeTile(entry: entry),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
