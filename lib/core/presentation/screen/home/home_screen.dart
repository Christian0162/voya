import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  // Fetched once and shared: the top 5 drive the "Recent Practice" tiles,
  // the full 50 drive the honest totals/streak in ProgressStats — fetching
  // more than the tile list needs (rather than a second, smaller call) keeps
  // both numbers accurate without a new repository method.
  static const _fetchLimit = 50;
  static const _recentTileCount = 5;

  @override
  void initState() {
    super.initState();
    _recentFuture = widget.repository.getRecentSessions(limit: _fetchLimit);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _refresh() async {
    setState(() => _recentFuture = widget.repository.getRecentSessions(limit: _fetchLimit));
    await _recentFuture;
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
          recentEntries: entries.take(_recentTileCount).toList(),
          stats: ProgressStats.fromEntries(entries),
          onStartInterview: () => context.push('/interview/setup'),
          onRefresh: _refresh,
          onAnswerCoachPressed: () => context.push('/answer-guidance'),
        );
      },
    );
  }
}
