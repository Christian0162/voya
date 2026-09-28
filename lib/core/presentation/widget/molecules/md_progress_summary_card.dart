import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/widget/atoms/md_icon_badge.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';

/// One row in [MdProgressSummaryCard] — a labeled, colored, icon-badged
/// metric rather than a plain text label, so the summary reads as more
/// alive than a flat list of bars.
class ProgressMetric {
  const ProgressMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;

  /// 0.0-1.0
  final double value;
  final IconData icon;
  final Color color;
}

class MdProgressSummaryCard extends StatelessWidget {
  const MdProgressSummaryCard({super.key, required this.metrics});

  final List<ProgressMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return MdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Progress', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          for (final metric in metrics)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  MdIconBadge(icon: metric.icon, color: metric.color, size: 32, iconSize: 16),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 88,
                    child: Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      child: LinearProgressIndicator(
                        value: metric.value,
                        minHeight: 6,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation(metric.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(metric.value * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
