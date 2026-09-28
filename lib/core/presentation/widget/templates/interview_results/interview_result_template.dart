import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/types/interview_results/interview_result_args.dart';
import 'package:voya/core/presentation/widget/atoms/md_primary_button.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';
import 'package:voya/core/presentation/widget/molecules/md_feedback_card.dart';
import 'package:voya/core/presentation/widget/molecules/md_result_metric.dart';

/// Post-interview analysis (spec section 17) — five separate dimensions
/// rather than one arbitrary score, plus concrete strengths/practice areas.
class InterviewResultTemplate extends StatelessWidget {
  const InterviewResultTemplate({
    super.key,
    required this.args,
    required this.hasTranscript,
    required this.onShowTranscript,
    required this.onPracticeAgain,
    required this.onBackHome,
  });

  final InterviewResultArgs args;
  final bool hasTranscript;
  final VoidCallback onShowTranscript;
  final VoidCallback onPracticeAgain;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final result = args.result;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Interview Complete'),
        actions: [
          if (hasTranscript)
            IconButton(
              icon: const Icon(Icons.description_rounded),
              tooltip: 'View transcript',
              onPressed: onShowTranscript,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(
              '${args.configuration.country.flagEmoji}  ${args.configuration.country.name} · ${args.configuration.purpose.label}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            MdCard(
              child: Column(
                children: [
                  MdResultMetric(label: 'Communication', value: result.communication),
                  MdResultMetric(label: 'Clarity', value: result.clarity),
                  MdResultMetric(label: 'Answer Quality', value: result.answerQuality),
                  MdResultMetric(label: 'Speaking Pace', value: result.speakingPace),
                  MdResultMetric(label: 'Consistency', value: result.consistency),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            MdFeedbackCard(
              title: 'Strengths',
              icon: Icons.thumb_up_rounded,
              iconColor: AppColors.success,
              items: result.strengths,
            ),
            const SizedBox(height: AppSpacing.lg),
            MdFeedbackCard(
              title: 'Practice Areas',
              icon: Icons.track_changes_rounded,
              iconColor: AppColors.warning,
              items: result.practiceAreas,
            ),
            if (result.fillerWordCounts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _FillerWordsCard(counts: result.fillerWordCounts),
            ],
            if (result.questionsToPractice.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              MdFeedbackCard(
                title: 'Questions to Practice',
                icon: Icons.repeat_rounded,
                iconColor: AppColors.info,
                items: result.questionsToPractice,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            MdPrimaryButton(
              label: 'Practice Again',
              icon: Icons.refresh_rounded,
              onPressed: onPracticeAgain,
            ),
            const SizedBox(height: AppSpacing.md),
            MdPrimaryButton(
              label: 'Back to Home',
              variant: MdButtonVariant.secondary,
              onPressed: onBackHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _FillerWordsCard extends StatelessWidget {
  const _FillerWordsCard({required this.counts});
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return MdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Filler Words', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: entries
                .map(
                  (e) => Chip(
                    label: Text('"${e.key}"  ${e.value}'),
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tip: try pausing silently instead of using filler words.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
