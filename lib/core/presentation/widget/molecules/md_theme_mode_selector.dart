import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';

/// System/Light/Dark appearance picker — one card, three equal segments,
/// rather than three stacked [MdCard]s (as `MdDifficultySelector` uses for
/// 4 longer options) since these are three short, mutually exclusive
/// choices better scanned side by side.
class MdThemeModeSelector extends StatelessWidget {
  const MdThemeModeSelector({super.key, required this.selected, required this.onSelected});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  static const _options = [
    (mode: ThemeMode.system, icon: Icons.brightness_auto_rounded, label: 'System'),
    (mode: ThemeMode.light, icon: Icons.light_mode_rounded, label: 'Light'),
    (mode: ThemeMode.dark, icon: Icons.dark_mode_rounded, label: 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    return MdCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          for (final option in _options)
            Expanded(
              child: _Segment(
                icon: option.icon,
                label: option.label,
                isSelected: option.mode == selected,
                onTap: () => onSelected(option.mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
