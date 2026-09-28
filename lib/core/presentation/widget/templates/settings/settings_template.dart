import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_constants.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';
import 'package:voya/core/presentation/widget/molecules/md_settings_tile.dart';

class SettingsTemplate extends StatelessWidget {
  const SettingsTemplate({super.key, required this.onOpenMicrophoneSettings});

  final VoidCallback onOpenMicrophoneSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const _BrandHeader(),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('Preferences'),
            const SizedBox(height: AppSpacing.sm),
            MdCard(
              padding: EdgeInsets.zero,
              child: MdSettingsTile(
                icon: Icons.mic_rounded,
                iconColor: AppColors.primary,
                title: 'Microphone permission',
                subtitle: 'Manage in your device settings',
                onTap: onOpenMicrophoneSettings,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('Privacy & Data'),
            const SizedBox(height: AppSpacing.sm),
            MdCard(
              padding: EdgeInsets.zero,
              child: MdSettingsTile(
                icon: Icons.shield_rounded,
                iconColor: AppColors.success,
                title: 'Your data',
                subtitle:
                    'Only transcripts and scores are stored, on this device. No audio is kept.',
                showChevron: false,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('About'),
            const SizedBox(height: AppSpacing.sm),
            MdCard(
              padding: EdgeInsets.zero,
              child: MdSettingsTile(
                icon: Icons.info_rounded,
                iconColor: AppColors.accent,
                title: 'About ${AppConstants.appName}',
                subtitle: '${AppConstants.tagline} · v${AppConstants.appVersion}',
                showChevron: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small app-branding moment at the top of Settings — the same
/// gradient + mic mark as the app icon, drawn natively (so it stays crisp at
/// any density and doesn't depend on decoding a bitmap asset) — instead of
/// jumping straight into a plain list, so the screen still feels like part
/// of the same personable product.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return MdCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConstants.appName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(AppConstants.tagline, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 0.6),
      ),
    );
  }
}
