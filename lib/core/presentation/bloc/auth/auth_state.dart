import 'package:equatable/equatable.dart';

import 'package:voya/core/domain/auth/entities/app_user.dart';

enum AuthStatus {
  /// Still waiting on the first event from `AuthRepository.authStateChanges`
  /// — the router treats this as "don't redirect yet" so a signed-in user
  /// doesn't flash the sign-in screen on cold start.
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;
  final AppUser? user;

  @override
  List<Object?> get props => [status, user];
}
