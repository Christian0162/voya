import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:voya/app.dart';
import 'package:voya/core/data/repositories/interview_repository_impl.dart';

void main() {
  testWidgets('App boots to the Home screen with the primary CTA visible', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(VoyaApp(repository: InterviewRepositoryImpl(prefs)));
    await tester.pumpAndSettle();

    expect(find.text('Start Interview'), findsOneWidget);
    expect(find.text('Ready for your next interview?'), findsOneWidget);
  });
}
