import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';

class MdDurationSelector extends StatelessWidget {
  const MdDurationSelector({super.key, required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  static const _options = [5, 10, 15];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _options.map((minutes) {
      final isSelected = minutes == selected;
      final color = isSelected ? AppColors.primary : theme.dividerColor;

      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 92,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: color, width: isSelected ? 1.5 : 1),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              onTap: () => onSelected(minutes),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: '$minutes minutes',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$minutes',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'minutes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.md),
          items[i],
        ],
      ],
    );
  }
}
