import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:voya/core/domain/auth/entities/app_user.dart';
import 'package:voya/core/domain/auth/repositories/auth_repository.dart';
import 'package:voya/core/error/failure.dart';

/// Backs [AuthRepository] with Supabase Auth (credentials) + the `profiles`
/// table (username/avatar) — see the plan's schema for `profiles`,
/// `interview_sessions`, `interview_results` and their RLS policies.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  static const _oauthRedirect = 'io.supabase.voya://login-callback/';

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    // Synchronous — email/id only, no profile fields yet. `authStateChanges`
    // is the source of truth for a fully-populated user; this getter exists
    // for the one-shot "am I signed in at all" check the router needs.
    return AppUser(id: user.id, email: user.email ?? '');
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield await _resolveUser(_client.auth.currentUser);
    yield* _client.auth.onAuthStateChange.asyncMap((state) => _resolveUser(state.session?.user));
  }

  Future<AppUser?> _resolveUser(User? user) async {
    if (user == null) return null;
    try {
      final profile = await _client
          .from('profiles')
          .select('username, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      return AppUser(
        id: user.id,
        email: user.email ?? '',
        username: profile?['username'] as String?,
        avatarUrl: profile?['avatar_url'] as String?,
      );
    } on PostgrestException {
      // Profile row not readable yet (e.g. the new-user trigger hasn't run
      // this instant) — still report the user as signed in rather than
      // failing the whole auth state.
      return AppUser(id: user.id, email: user.email ?? '');
    }
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _client.auth.signUp(email: email, password: password, data: {'username': username});
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _oauthRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<AppUser> updateProfile({String? username, String? avatarUrl}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthFailure('You need to be signed in to do that.');

    final updates = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (username != null) updates['username'] = username;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    try {
      await _client.from('profiles').update(updates).eq('id', user.id);
    } on PostgrestException catch (e) {
      throw AuthFailure(
        e.code == '23505' ? 'That username is taken.' : (e.message.isEmpty ? null : e.message),
      );
    }

    return (await _resolveUser(user))!;
  }
}
