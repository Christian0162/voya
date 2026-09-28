import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_constants.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/presentation/widget/molecules/md_empty_state.dart';
import 'package:voya/core/presentation/widget/molecules/md_home_hero_card.dart';
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
    required this.progressMetrics,
    required this.onStartInterview,
    required this.onRefresh,
  });

  final String greeting;
  final bool isLoadingRecent;
  final List<InterviewHistoryEntry> recentEntries;
  final List<ProgressMetric> progressMetrics;
  final VoidCallback onStartInterview;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
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
              const SizedBox(height: AppSpacing.xl),
              MdProgressSummaryCard(metrics: progressMetrics),
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
