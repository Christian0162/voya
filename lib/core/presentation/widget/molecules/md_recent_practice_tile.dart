import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/presentation/widget/atoms/md_icon_badge.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';
import 'package:voya/core/presentation/widget/molecules/purpose_visuals.dart';
import 'package:voya/core/presentation/widget/molecules/score_visuals.dart';

class MdRecentPracticeTile extends StatelessWidget {
  const MdRecentPracticeTile({super.key, required this.entry});

  final InterviewHistoryEntry entry;

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    return MdCard(
      child: Row(
        children: [
          MdIconBadge(icon: iconForPurpose(entry.purpose), color: colorForPurpose(entry.purpose)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.countryFlag} ${entry.countryName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${entry.purpose.label} · ${_timeAgo(entry.startedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (entry.overallScore != null) _ScorePill(score: entry.overallScore!),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final color = colorForScore(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            '${(score * 100).round()}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
