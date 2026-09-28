import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';

enum MdButtonVariant { primary, secondary, text }

/// Single button component used everywhere so loading/disabled states stay
/// consistent instead of being reimplemented per screen.
class MdPrimaryButton extends StatelessWidget {
  const MdPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MdButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final MdButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.sm)],
              Text(label),
            ],
          );

    final Widget button = switch (variant) {
      MdButtonVariant.primary => ElevatedButton(
        onPressed: disabled ? null : onPressed,
        child: child,
      ),
      MdButtonVariant.secondary => OutlinedButton(
        onPressed: disabled ? null : onPressed,
        child: child,
      ),
      MdButtonVariant.text => TextButton(onPressed: disabled ? null : onPressed, child: child),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
