import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';

/// A small colored, rounded icon badge — the "colorful icon in a tinted
/// circle" pattern used throughout the app (purpose cards, settings rows,
/// progress stats) instead of plain monochrome icons, so screens read as
/// more alive without introducing new colors outside the existing palette.
class MdIconBadge extends StatelessWidget {
  const MdIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
