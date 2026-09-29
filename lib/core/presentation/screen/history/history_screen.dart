import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/presentation/widget/molecules/md_progress_summary_card.dart';
import 'package:voya/core/presentation/widget/templates/history/history_template.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.repository});

  final InterviewRepository repository;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<InterviewHistoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getRecentSessions(limit: 50);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InterviewHistoryEntry>>(
      future: _future,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const [];
        return HistoryTemplate(
          isLoading: snapshot.connectionState != ConnectionState.done,
          entries: entries,
          stats: ProgressStats.fromEntries(entries),
          onStartInterview: () => context.push('/interview/setup'),
        );
      },
    );
  }
}
