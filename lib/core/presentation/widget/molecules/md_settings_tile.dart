import 'package:flutter/material.dart';

import 'package:voya/core/presentation/widget/atoms/md_icon_badge.dart';

/// A single settings row — colored icon badge, title, optional subtitle and
/// chevron — used instead of a plain monochrome [ListTile] so a settings
/// list reads as more alive and matches the icon-badge language used
/// elsewhere (purpose/difficulty selectors, progress stats).
class MdSettingsTile extends StatelessWidget {
  const MdSettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MdIconBadge(icon: icon, color: iconColor),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: showChevron ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: onTap,
    );
  }
}
