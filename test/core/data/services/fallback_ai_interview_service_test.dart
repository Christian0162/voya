import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voya/core/data/services/fallback_ai_interview_service.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/services/ai_interview_service.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';

class _MockAIInterviewService extends Mock implements AIInterviewService {}

void main() {
  final configuration = const InterviewConfiguration(
    country: Country(code: 'AU', name: 'Australia', flagEmoji: '🇦🇺'),
    purpose: InterviewPurpose.work,
    difficulty: InterviewDifficulty.professional,
    durationMinutes: 5,
  );

  const primaryQuestion = InterviewQuestion(
    id: 'primary',
    text: 'From the primary provider',
    kind: QuestionKind.opening,
    order: 0,
  );
  const fallbackQuestion = InterviewQuestion(
    id: 'fallback',
    text: 'From the fallback provider',
    kind: QuestionKind.opening,
    order: 0,
  );

  setUpAll(() {
    registerFallbackValue(configuration);
  });

  test('uses the primary provider while it keeps succeeding', () async {
    final primary = _MockAIInterviewService();
    final fallback = _MockAIInterviewService();
    when(() => primary.generateOpeningQuestion(any())).thenAnswer((_) async => primaryQuestion);

    final service = FallbackAIInterviewService(primary: primary, fallback: fallback);

    final result = await service.generateOpeningQuestion(configuration);

    expect(result, primaryQuestion);
    verifyNever(() => fallback.generateOpeningQuestion(any()));
  });

  test('falls back once the primary throws, and stays on the fallback after that', () async {
    final primary = _MockAIInterviewService();
    final fallback = _MockAIInterviewService();
    when(() => primary.generateOpeningQuestion(any())).thenThrow(Exception('503 unavailable'));
    when(() => fallback.generateOpeningQuestion(any())).thenAnswer((_) async => fallbackQuestion);

    final service = FallbackAIInterviewService(primary: primary, fallback: fallback);

    final first = await service.generateOpeningQuestion(configuration);
    expect(first, fallbackQuestion);

    // A second call shouldn't re-try the already-failed primary.
    final second = await service.generateOpeningQuestion(configuration);
    expect(second, fallbackQuestion);

    verify(() => primary.generateOpeningQuestion(any())).called(1);
    verify(() => fallback.generateOpeningQuestion(any())).called(2);
  });
}
