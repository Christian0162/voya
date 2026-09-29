import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voya/core/domain/auth/entities/app_user.dart';
import 'package:voya/core/domain/auth/repositories/auth_repository.dart';
import 'package:voya/core/presentation/bloc/auth/auth_cubit.dart';
import 'package:voya/core/presentation/bloc/auth/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  const user = AppUser(id: 'u1', email: 'test@example.com', username: 'tester');

  setUp(() {
    repository = _MockAuthRepository();
  });

  blocTest<AuthCubit, AuthState>(
    'emits unauthenticated when the repository reports no user',
    setUp: () {
      when(() => repository.authStateChanges()).thenAnswer((_) => Stream.value(null));
    },
    build: () => AuthCubit(repository),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'emits authenticated with the user when the repository reports one',
    setUp: () {
      when(() => repository.authStateChanges()).thenAnswer((_) => Stream.value(user));
    },
    build: () => AuthCubit(repository),
    expect: () => [const AuthState(status: AuthStatus.authenticated, user: user)],
  );

  blocTest<AuthCubit, AuthState>(
    'updateProfile emits the freshly updated user',
    setUp: () {
      when(() => repository.authStateChanges()).thenAnswer((_) => Stream.value(user));
      when(() => repository.updateProfile(username: 'newname', avatarUrl: null))
          .thenAnswer((_) async => user.copyWith(username: 'newname'));
    },
    build: () => AuthCubit(repository),
    act: (cubit) => cubit.updateProfile(username: 'newname'),
    skip: 1, // the initial authStateChanges emission
    expect: () => [
      AuthState(
        status: AuthStatus.authenticated,
        user: user.copyWith(username: 'newname'),
      ),
    ],
  );
}
