import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';

class ProfileTemplate extends StatelessWidget {
  const ProfileTemplate({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            MdCard(
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person_rounded, size: 28)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guest Practicer', style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          'Local practice history only',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            MdCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: onOpenSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
