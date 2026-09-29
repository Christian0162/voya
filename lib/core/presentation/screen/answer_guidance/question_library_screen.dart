import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/data/services/guidance_question_library.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/presentation/widget/atoms/md_icon_badge.dart';
import 'package:voya/core/presentation/widget/molecules/guidance_category_visuals.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';

/// Browsable question library for the Answer Coach (spec section 4, Mode A
/// entry point) — categories, each expandable to its questions. Picking a
/// question opens its [AnswerGuideScreen].
class QuestionLibraryScreen extends StatelessWidget {
  const QuestionLibraryScreen({super.key});

  // GuidanceCategory.general is only used to wrap a question that came from
  // a live interview (Mode B) — it has no library entries and is never a
  // browsable section here.
  static final _categories = GuidanceCategory.values
      .where((c) => c != GuidanceCategory.general)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Answer Coach')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _categories.length + 1,
        separatorBuilder: (_, index) =>
            SizedBox(height: index == 0 ? AppSpacing.lg : AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Learn what interviewers are really asking, then practice your answer out loud.',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          }
          final category = _categories[index - 1];
          return _CategorySection(
            category: category,
            questions: GuidanceQuestionLibrary.forCategory(category),
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.questions});

  final GuidanceCategory category;
  final List<GuidanceQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final color = colorForGuidanceCategory(category);

    return MdCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: color,
          collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          leading: MdIconBadge(icon: iconForGuidanceCategory(category), color: color, size: 40),
          title: Text(category.label, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            '${category.description} · ${questions.length} question${questions.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
          children: [
            for (final question in questions)
              ListTile(
                key: ValueKey(question.id),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                minLeadingWidth: 0,
                leading: Icon(Icons.circle, size: 6, color: color.withValues(alpha: 0.6)),
                title: Text(question.text, style: Theme.of(context).textTheme.bodyMedium),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () => context.push('/answer-guidance/guide', extra: question),
              ),
          ],
        ),
      ),
    );
  }
}
