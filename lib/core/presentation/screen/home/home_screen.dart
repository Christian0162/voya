import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/presentation/widget/molecules/md_progress_summary_card.dart';
import 'package:voya/core/presentation/widget/templates/home/home_template.dart';

/// Logic only: fetches recent sessions, derives the greeting/progress
/// numbers, and wires navigation. All rendering lives in [HomeTemplate].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final InterviewRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<InterviewHistoryEntry>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _recentFuture = widget.repository.getRecentSessions(limit: 5);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _refresh() async {
    setState(() => _recentFuture = widget.repository.getRecentSessions(limit: 5));
    await _recentFuture;
  }

  List<ProgressMetric> _progressMetrics(List<InterviewHistoryEntry> entries) {
    final scored = entries.where((e) => e.overallScore != null).map((e) => e.overallScore!);
    final avgScore = scored.isEmpty ? 0.7 : scored.reduce((a, b) => a + b) / scored.length;
    return [
      ProgressMetric(
        label: 'Speaking',
        value: avgScore,
        icon: Icons.mic_rounded,
        color: AppColors.primary,
      ),
      ProgressMetric(
        label: 'Confidence',
        value: (avgScore - 0.05).clamp(0.0, 1.0),
        icon: Icons.bolt_rounded,
        color: AppColors.warning,
      ),
      ProgressMetric(
        label: 'Clarity',
        value: (avgScore + 0.05).clamp(0.0, 1.0),
        icon: Icons.chat_bubble_rounded,
        color: AppColors.success,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InterviewHistoryEntry>>(
      future: _recentFuture,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const [];
        return HomeTemplate(
          greeting: _greeting(),
          isLoadingRecent: snapshot.connectionState != ConnectionState.done,
          recentEntries: entries,
          progressMetrics: _progressMetrics(entries),
          onStartInterview: () => context.push('/interview/setup'),
          onRefresh: _refresh,
        );
      },
    );
  }
}
