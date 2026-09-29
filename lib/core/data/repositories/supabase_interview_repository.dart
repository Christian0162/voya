import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/domain/interview/entities/interview_session.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';

/// Backs [InterviewRepository] with the `interview_sessions`/
/// `interview_results` Postgres tables (see the plan's schema/RLS) instead of
/// on-device [SharedPreferences] — every row is tagged with the signed-in
/// user's id, and RLS means a query never sees another user's rows even if
/// this code got it wrong, so `user_id` here is defense in depth, not the
/// only thing keeping data private.
class SupabaseInterviewRepository implements InterviewRepository {
  SupabaseInterviewRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('SupabaseInterviewRepository used while signed out.');
    return id;
  }

  @override
  Future<void> saveSession(InterviewSession session) async {
    await _client.from('interview_sessions').upsert({
      'id': session.id,
      'user_id': _userId,
      'country_name': session.configuration.country.name,
      'country_flag': session.configuration.country.flagEmoji,
      'purpose': session.configuration.purpose.name,
      'difficulty': session.configuration.difficulty.name,
      'duration_minutes': session.configuration.durationMinutes,
      'started_at': session.startedAt.toIso8601String(),
      'turn_count': session.turns.length,
    });
  }

  @override
  Future<void> saveResult(InterviewResult result) async {
    await _client.from('interview_results').upsert({
      'session_id': result.sessionId,
      'user_id': _userId,
      'completed_at': result.completedAt.toIso8601String(),
      'communication': result.communication,
      'clarity': result.clarity,
      'answer_quality': result.answerQuality,
      'speaking_pace': result.speakingPace,
      'consistency': result.consistency,
      'strengths': result.strengths,
      'practice_areas': result.practiceAreas,
      'questions_to_practice': result.questionsToPractice,
      'filler_word_counts': result.fillerWordCounts,
    });

    // Backfill the overall score onto the session row, same as the local
    // implementation, so history/home lists can show it without a join.
    await _client
        .from('interview_sessions')
        .update({'overall_score': result.overallAverage})
        .eq('id', result.sessionId);
  }

  @override
  Future<List<InterviewHistoryEntry>> getRecentSessions({int limit = 20}) async {
    final rows = await _client
        .from('interview_sessions')
        .select()
        .eq('user_id', _userId)
        .order('started_at', ascending: false)
        .limit(limit);

    return (rows as List<dynamic>)
        .map((row) => _historyEntryFromRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InterviewResult?> getResult(String sessionId) async {
    final row = await _client
        .from('interview_results')
        .select()
        .eq('session_id', sessionId)
        .maybeSingle();
    if (row == null) return null;
    return _resultFromRow(row);
  }

  InterviewHistoryEntry _historyEntryFromRow(Map<String, dynamic> row) {
    return InterviewHistoryEntry(
      sessionId: row['id'] as String,
      countryName: row['country_name'] as String,
      countryFlag: row['country_flag'] as String,
      purpose: InterviewPurpose.values.byName(row['purpose'] as String),
      difficulty: InterviewDifficulty.values.byName(row['difficulty'] as String),
      durationMinutes: row['duration_minutes'] as int,
      startedAt: DateTime.parse(row['started_at'] as String),
      turnCount: row['turn_count'] as int,
      overallScore: (row['overall_score'] as num?)?.toDouble(),
    );
  }

  InterviewResult _resultFromRow(Map<String, dynamic> row) {
    return InterviewResult(
      sessionId: row['session_id'] as String,
      completedAt: DateTime.parse(row['completed_at'] as String),
      communication: (row['communication'] as num).toDouble(),
      clarity: (row['clarity'] as num).toDouble(),
      answerQuality: (row['answer_quality'] as num).toDouble(),
      speakingPace: (row['speaking_pace'] as num).toDouble(),
      consistency: (row['consistency'] as num).toDouble(),
      strengths: (row['strengths'] as List).cast<String>(),
      practiceAreas: (row['practice_areas'] as List).cast<String>(),
      questionsToPractice: (row['questions_to_practice'] as List).cast<String>(),
      fillerWordCounts: Map<String, int>.from(row['filler_word_counts'] as Map),
    );
  }
}
