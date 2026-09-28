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
                    Text(purpose.label, style: Theme.of(context).textTheme.titleMedium),
                    Text(purpose.description, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            ],
          ),
        );
      },
    );
  }
}
