import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';
import 'package:voya/core/presentation/widget/atoms/md_icon_badge.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';
import 'package:voya/core/presentation/widget/molecules/purpose_visuals.dart';

class MdPurposeSelector extends StatelessWidget {
  const MdPurposeSelector({super.key, required this.selected, required this.onSelected});

  final InterviewPurpose? selected;
  final ValueChanged<InterviewPurpose> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: InterviewPurpose.values.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final purpose = InterviewPurpose.values[index];
        final isSelected = purpose == selected;
        return MdCard(
          selected: isSelected,
          onTap: () => onSelected(purpose),
          child: Row(
            children: [
              MdIconBadge(icon: iconForPurpose(purpose), color: colorForPurpose(purpose)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purpose.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      purpose.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Always present (selected vs. unselected icon swapped, never
              // added/removed) so the trailing icon's width is reserved up
              // front — otherwise the Expanded label above regains/loses
              // that width the instant you tap a card, reflowing/wrapping
              // text that fit fine a moment ago. Matches the same pattern
              // already used in MdDifficultySelector.
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
