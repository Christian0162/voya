import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/widget/molecules/score_visuals.dart';

/// One scored dimension rendered as a labeled progress bar — used instead of
/// a single overall score so users see *where* to focus (spec section 17).
class MdResultMetric extends StatelessWidget {
  const MdResultMetric({super.key, required this.label, required this.value});

  final String label;

  /// 0.0–1.0
  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    final color = colorForScore(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '$percent%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
