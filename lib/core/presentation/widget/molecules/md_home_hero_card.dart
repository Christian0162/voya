import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/widget/molecules/md_mascot_face.dart';

/// The obvious, unmissable primary CTA on Home (spec section 13). Leads with
/// the mascot's face rather than a plain mic glyph, so the first thing a
/// user sees on Home is "a character", not "a utility" — the same instinct
/// behind putting the same face on the launcher icon.
class MdHomeHeroCard extends StatelessWidget {
  const MdHomeHeroCard({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const MdMascotFace(size: 56),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'Meet your AI interviewer',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Practice your answers out loud before the real thing.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.mic_rounded, size: 20),
              label: const Text('Start Interview'),
            ),
          ),
        ],
      ),
    );
  }
}
