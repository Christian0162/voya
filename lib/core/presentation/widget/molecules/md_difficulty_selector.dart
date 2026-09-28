import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/presentation/widget/atoms/md_icon_badge.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';

IconData _iconFor(InterviewDifficulty difficulty) {
  switch (difficulty) {
    case InterviewDifficulty.professional:
      return Icons.business_center_rounded;
    case InterviewDifficulty.friendly:
      return Icons.emoji_emotions_rounded;
    case InterviewDifficulty.strict:
      return Icons.rule_rounded;
    case InterviewDifficulty.pressure:
      return Icons.local_fire_department_rounded;
  }
}

Color _colorFor(InterviewDifficulty difficulty) {
  switch (difficulty) {
    case InterviewDifficulty.professional:
      return AppColors.primary;
    case InterviewDifficulty.friendly:
      return AppColors.success;
    case InterviewDifficulty.strict:
      return AppColors.info;
    case InterviewDifficulty.pressure:
      return AppColors.warning;
  }
}

class MdDifficultySelector extends StatelessWidget {
  const MdDifficultySelector({super.key, required this.selected, required this.onSelected});

  final InterviewDifficulty? selected;
  final ValueChanged<InterviewDifficulty> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: InterviewDifficulty.values.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final difficulty = InterviewDifficulty.values[index];
        final isSelected = difficulty == selected;
        return MdCard(
          selected: isSelected,
          onTap: () => onSelected(difficulty),
          child: Row(
            children: [
              MdIconBadge(icon: _iconFor(difficulty), color: _colorFor(difficulty)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(difficulty.label, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(difficulty.description, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
