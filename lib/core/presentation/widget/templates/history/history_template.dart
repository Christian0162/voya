import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/presentation/widget/molecules/md_empty_state.dart';
import 'package:voya/core/presentation/widget/molecules/md_recent_practice_tile.dart';

class HistoryTemplate extends StatelessWidget {
  const HistoryTemplate({
    super.key,
    required this.isLoading,
    required this.entries,
    required this.onStartInterview,
  });

  final bool isLoading;
  final List<InterviewHistoryEntry> entries;
  final VoidCallback onStartInterview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (entries.isEmpty) {
      return Center(
        child: MdEmptyState(
          icon: Icons.history_rounded,
          iconColor: AppColors.primary,
          title: 'No interviews yet',
          message: 'Your completed practice sessions will show up here.',
          actionLabel: 'Start Interview',
          onAction: onStartInterview,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) => MdRecentPracticeTile(entry: entries[index]),
    );
  }
}
