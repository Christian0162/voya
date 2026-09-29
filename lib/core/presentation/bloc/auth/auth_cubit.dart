import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voya/core/domain/auth/entities/app_user.dart';
import 'package:voya/core/domain/auth/repositories/auth_repository.dart';

import 'auth_state.dart';

/// The single source of truth for "who's signed in", subscribed to for the
/// whole app's lifetime (constructed once in `app.dart`). Drives both
/// [AppRouter]'s redirect guard and any screen showing the current user
/// (Profile). Sign-in/sign-up/edit-profile screens call its methods
/// directly and catch [AuthFailure] themselves for their own error UI —
/// same pattern as [InterviewBloc] callers use [Failure] elsewhere.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges().listen(_onUserChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  void _onUserChanged(AppUser? user) {
    emit(
      AuthState(
        status: user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) => _repository.signUpWithEmail(email: email, password: password, username: username);

  Future<void> signInWithEmail({required String email, required String password}) =>
      _repository.signInWithEmail(email: email, password: password);

  Future<void> signInWithGoogle() => _repository.signInWithGoogle();

  Future<void> signOut() => _repository.signOut();

  Future<void> resetPassword(String email) => _repository.resetPassword(email);

  Future<void> updateProfile({String? username, String? avatarUrl}) async {
    final updated = await _repository.updateProfile(username: username, avatarUrl: avatarUrl);
    emit(AuthState(status: AuthStatus.authenticated, user: updated));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
