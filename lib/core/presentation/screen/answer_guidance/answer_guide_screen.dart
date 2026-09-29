import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_bloc.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_event.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_state.dart';
import 'package:voya/core/presentation/types/answer_guidance/practice_args.dart';
import 'package:voya/core/presentation/widget/atoms/md_icon_badge.dart';
import 'package:voya/core/presentation/widget/atoms/md_primary_button.dart';
import 'package:voya/core/presentation/widget/molecules/guidance_category_visuals.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';
import 'package:voya/core/presentation/widget/molecules/md_error_state.dart';
import 'package:voya/core/presentation/widget/molecules/md_feedback_card.dart';

/// Shows the coaching guide for one [GuidanceQuestion] (spec section 7):
/// what it means, what the interviewer wants, how to structure a reply, a
/// sample answer, mistakes to avoid, and a practice tip — then a way to
/// practice it aloud.
class AnswerGuideScreen extends StatelessWidget {
  const AnswerGuideScreen({super.key, required this.question});

  final GuidanceQuestion question;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Answer Guide')),
      body: BlocBuilder<AnswerGuideBloc, AnswerGuideState>(
        builder: (context, state) {
          switch (state.status) {
            case AnswerGuideStatus.initial:
            case AnswerGuideStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AnswerGuideStatus.error:
              return MdErrorState(
                message: state.failure?.message ?? 'Something went wrong.',
                onRetry: () => context.read<AnswerGuideBloc>().add(GuideRequested(question)),
              );
            case AnswerGuideStatus.loaded:
              final guide = state.guide!;
              final categoryColor = colorForGuidanceCategory(question.category);
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (question.category != GuidanceCategory.general)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CategoryTag(category: question.category, color: categoryColor),
                    ),
                  Text(question.text, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xl),
                  _Section(
                    icon: Icons.psychology_outlined,
                    color: AppColors.info,
                    title: 'Understand the Question',
                    child: Text(guide.questionExplanation, style: _bodyStyle(context)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Section(
                    icon: Icons.visibility_outlined,
                    color: AppColors.primary,
                    title: 'What the Interviewer Is Looking For',
                    child: Text(guide.interviewerIntent, style: _bodyStyle(context)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Section(
                    icon: Icons.format_list_numbered_rounded,
                    color: AppColors.accent,
                    title: 'How to Structure Your Answer',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < guide.answerStructure.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == guide.answerStructure.length - 1 ? 0 : AppSpacing.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StepNumber(number: i + 1, color: AppColors.accent),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(guide.answerStructure[i], style: _bodyStyle(context)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Section(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppColors.success,
                    title: 'Example Answer',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.exampleAnswer,
                          style: _bodyStyle(context)
                              ?.copyWith(fontStyle: FontStyle.italic, height: 1.5),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'For learning the structure — not meant to be memorized word for word.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MdFeedbackCard(
                    title: 'Common Mistakes to Avoid',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.warning,
                    items: guide.commonMistakes,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TipCallout(tip: guide.practiceTip),
                  const SizedBox(height: AppSpacing.xxl),
                  MdPrimaryButton(
                    label: 'Practice This Question',
                    icon: Icons.mic_rounded,
                    onPressed: () => context.push(
                      '/answer-guidance/practice',
                      extra: PracticeArgs(question: question, guide: guide),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
          }
        },
      ),
    );
  }

  TextStyle? _bodyStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.category, required this.color});

  final GuidanceCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        category.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MdIconBadge(icon: icon, color: color, size: 32, iconSize: 16),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// The small circled step number used in "How to Structure Your Answer" —
/// keeps the ordering readable at a glance instead of a plain "1." prefix.
class _StepNumber extends StatelessWidget {
  const _StepNumber({required this.number, required this.color});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// A highlighted callout for [AnswerGuide.practiceTip] — visually distinct
/// (tinted background instead of a plain [MdCard]) so the one encouraging
/// tip reads differently from the informational sections above it.
class _TipCallout extends StatelessWidget {
  const _TipCallout({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.accent, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
