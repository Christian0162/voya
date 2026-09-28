import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';

/// Progress header shared by every setup step — a slim segmented bar rather
/// than a numeric "Step 2 of 4", which reads calmer at a glance.
class MdSetupStepHeader extends StatelessWidget {
  const MdSetupStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepIndex,
    required this.stepCount,
  });

  final String title;
  final String subtitle;
  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(stepCount, (i) {
            final active = i <= stepIndex;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == stepCount - 1 ? 0 : AppSpacing.xs),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
