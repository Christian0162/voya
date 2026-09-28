import 'package:voya/core/domain/interview_results/entities/interview_result.dart';

import '../entities/interview_history_entry.dart';
import '../entities/interview_session.dart';

/// Persistence boundary for interview sessions/results/history. The domain
/// and presentation layers never know whether this is backed by
/// SharedPreferences (MVP), a REST API, or Supabase/Firebase later.
abstract class InterviewRepository {
  Future<void> saveSession(InterviewSession session);

  Future<void> saveResult(InterviewResult result);

  Future<List<InterviewHistoryEntry>> getRecentSessions({int limit = 20});

  Future<InterviewResult?> getResult(String sessionId);
}
