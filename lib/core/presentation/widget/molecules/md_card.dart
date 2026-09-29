import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';

/// The base surface for grouped content. Prefer this over raw [Container]s
/// with ad-hoc decoration so borders/radii/elevation stay consistent.
class MdCard extends StatelessWidget {
  const MdCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: selected ? theme.colorScheme.primary : (theme.dividerColor),
          width: selected ? 1.5 : 1,
        ),
        // A soft, low-opacity shadow rather than a flat bordered box — gives
        // every card a touch of the "chunky, tactile" claymorphism cue
        // without going full 3D/thick-border, which would clash with the
        // rest of the app's calmer surfaces.
        boxShadow: [
          BoxShadow(
            color: (selected ? theme.colorScheme.primary : Colors.black).withValues(
              alpha: selected ? 0.18 : 0.10,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // A Material between this colored box and `child` so any descendant
      // ListTile/InkWell paints its ink splashes on top of the card's own
      // background instead of the one further up the tree (which the
      // colored decoration above would otherwise hide them behind).
      child: Material(color: Colors.transparent, child: child),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: card,
      ),
    );
  }
}
