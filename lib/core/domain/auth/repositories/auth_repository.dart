import '../entities/app_user.dart';

/// Persistence boundary for authentication/profile data — the domain and
/// presentation layers never know this is Supabase specifically (same role
/// [InterviewRepository] plays for interview data).
abstract class AuthRepository {
  /// Emits the current user (including profile fields) whenever auth state
  /// changes, and `null` when signed out. Emits once immediately with the
  /// current state on subscription.
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  });

  Future<void> signInWithEmail({required String email, required String password});

  Future<void> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword(String email);

  /// Returns the updated user so the caller can re-emit it directly instead
  /// of waiting on [authStateChanges] (a profile-only edit never fires a
  /// Supabase auth-state change, only [onAuthStateChange]'s session events do).
  Future<AppUser> updateProfile({String? username, String? avatarUrl});
}
