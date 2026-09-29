import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voya/app.dart';
import 'package:voya/core/domain/auth/entities/app_user.dart';
import 'package:voya/core/domain/auth/repositories/auth_repository.dart';
import 'package:voya/core/domain/interview/entities/interview_history_entry.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/presentation/bloc/auth/auth_cubit.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockInterviewRepository extends Mock implements InterviewRepository {}

void main() {
  testWidgets('App boots to the Home screen with the primary CTA visible', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final authRepository = _MockAuthRepository();
    const user = AppUser(id: 'u1', email: 'tester@example.com', username: 'tester');
    when(() => authRepository.authStateChanges()).thenAnswer((_) => Stream.value(user));

    final interviewRepository = _MockInterviewRepository();
    when(() => interviewRepository.getRecentSessions(limit: any(named: 'limit')))
        .thenAnswer((_) async => const <InterviewHistoryEntry>[]);

    await tester.pumpWidget(
      VoyaApp(repository: interviewRepository, prefs: prefs, authCubit: AuthCubit(authRepository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start Interview'), findsOneWidget);
    expect(find.text('Ready for your next interview?'), findsOneWidget);
  });
}
