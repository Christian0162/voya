import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/domain/interview/entities/interview_session.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';

/// SharedPreferences-backed implementation for the MVP.
///
/// This intentionally stores only text (transcripts, scores, metadata) —
/// never raw audio — per the privacy/retention guidance in spec section 25.
/// A future backend (Supabase/REST) implements the same
/// [InterviewRepository] interface and can replace this without touching the
/// bloc or any screen.
class InterviewRepositoryImpl implements InterviewRepository {
  InterviewRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _sessionsKey = 'interview_sessions_v1';
  static const _resultsKey = 'interview_results_v1';

  @override
  Future<void> saveSession(InterviewSession session) async {
    final all = await _readSessions();
    all.removeWhere((s) => s['id'] == session.id);
    all.insert(0, _sessionToJson(session));
    await _prefs.setString(_sessionsKey, jsonEncode(all.take(50).toList()));
  }

  @override
  Future<void> saveResult(InterviewResult result) async {
    final all = await _readResults();
    all[result.sessionId] = _resultToJson(result);
    await _prefs.setString(_resultsKey, jsonEncode(all));

    // Backfill the overall score onto the matching session summary so
    // history/home lists can show it without a second read.
    final sessions = await _readSessions();
    final idx = sessions.indexWhere((s) => s['id'] == result.sessionId);
    if (idx != -1) {
      sessions[idx]['overallScore'] = result.overallAverage;
      await _prefs.setString(_sessionsKey, jsonEncode(sessions));
    }
  }

  @override
  Future<List<InterviewHistoryEntry>> getRecentSessions({int limit = 20}) async {
    final all = await _readSessions();
    return all.take(limit).map(_historyEntryFromJson).toList();
  }

  @override
  Future<InterviewResult?> getResult(String sessionId) async {
    final all = await _readResults();
    final json = all[sessionId];
    if (json == null) return null;
    return _resultFromJson(sessionId, json as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> _readSessions() async {
    final raw = _prefs.getString(_sessionsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> _readResults() async {
    final raw = _prefs.getString(_resultsKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Map<String, dynamic> _sessionToJson(InterviewSession session) => {
    'id': session.id,
    'countryName': session.configuration.country.name,
    'countryFlag': session.configuration.country.flagEmoji,
    'purpose': session.configuration.purpose.name,
    'difficulty': session.configuration.difficulty.name,
    'durationMinutes': session.configuration.durationMinutes,
    'startedAt': session.startedAt.toIso8601String(),
    'turnCount': session.turns.length,
    'overallScore': null,
  };

  InterviewHistoryEntry _historyEntryFromJson(Map<String, dynamic> json) {
    return InterviewHistoryEntry(
      sessionId: json['id'] as String,
      countryName: json['countryName'] as String,
      countryFlag: json['countryFlag'] as String,
      purpose: InterviewPurpose.values.byName(json['purpose'] as String),
      difficulty: InterviewDifficulty.values.byName(json['difficulty'] as String),
      durationMinutes: json['durationMinutes'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      turnCount: json['turnCount'] as int,
      overallScore: (json['overallScore'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _resultToJson(InterviewResult result) => {
    'sessionId': result.sessionId,
    'completedAt': result.completedAt.toIso8601String(),
    'communication': result.communication,
    'clarity': result.clarity,
    'answerQuality': result.answerQuality,
    'speakingPace': result.speakingPace,
    'consistency': result.consistency,
    'strengths': result.strengths,
    'practiceAreas': result.practiceAreas,
    'questionsToPractice': result.questionsToPractice,
    'fillerWordCounts': result.fillerWordCounts,
  };

  InterviewResult _resultFromJson(String sessionId, Map<String, dynamic> json) {
    return InterviewResult(
      sessionId: sessionId,
      completedAt: DateTime.parse(json['completedAt'] as String),
      communication: (json['communication'] as num).toDouble(),
      clarity: (json['clarity'] as num).toDouble(),
      answerQuality: (json['answerQuality'] as num).toDouble(),
      speakingPace: (json['speakingPace'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      strengths: (json['strengths'] as List).cast<String>(),
      practiceAreas: (json['practiceAreas'] as List).cast<String>(),
      questionsToPractice: (json['questionsToPractice'] as List).cast<String>(),
      fillerWordCounts: Map<String, int>.from(json['fillerWordCounts'] as Map),
    );
  }
}
