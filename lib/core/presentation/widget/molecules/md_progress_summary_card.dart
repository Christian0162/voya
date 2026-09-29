import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';

/// Real, directly-measured numbers only — deliberately not three separate
/// "metrics" derived from the same single average score (the previous
/// Speaking/Confidence/Clarity card computed all three from one
/// `overallScore`, which read as more insight than the data actually gives).
class ProgressStats {
  const ProgressStats({
    required this.totalPractices,
    required this.averageScore,
    required this.practicedThisWeek,
  });

  /// Shared by Home (last 5 sessions) and History (last 50) — both screens
  /// already fetch [InterviewHistoryEntry] lists, so these stats are derived
  /// client-side from whatever list is passed rather than a separate
  /// repository call.
  factory ProgressStats.fromEntries(List<InterviewHistoryEntry> entries) {
    final scored = entries.where((e) => e.overallScore != null);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return ProgressStats(
      totalPractices: entries.length,
      averageScore: scored.isEmpty
          ? null
          : scored.map((e) => e.overallScore!).reduce((a, b) => a + b) / scored.length,
      practicedThisWeek: entries.where((e) => e.startedAt.isAfter(weekAgo)).length,
    );
  }

  final int totalPractices;

  /// 0.0-1.0, or null when no session has been scored yet.
  final double? averageScore;
  final int practicedThisWeek;

  bool get hasHistory => totalPractices > 0;
}

class MdProgressSummaryCard extends StatelessWidget {
  const MdProgressSummaryCard({super.key, required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    return MdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Progress', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          if (!stats.hasHistory)
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Complete your first interview to see your progress here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                _StatTile(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.primary,
                  value: '${stats.totalPractices}',
                  label: stats.totalPractices == 1 ? 'Practice' : 'Practices',
                ),
                _StatTile(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.success,
                  value: stats.averageScore == null
                      ? '—'
                      : '${(stats.averageScore! * 100).round()}%',
                  label: 'Avg. Score',
                ),
                _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  value: '${stats.practicedThisWeek}',
                  label: 'This Week',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
