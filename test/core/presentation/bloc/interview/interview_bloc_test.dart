import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voya/core/domain/interview/entities/answer_analysis.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/entities/interview_session.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/domain/interview/services/ai_interview_service.dart';
import 'package:voya/core/domain/interview/services/permission_service.dart';
import 'package:voya/core/domain/interview/services/speech_to_text_service.dart';
import 'package:voya/core/domain/interview/services/text_to_speech_service.dart';
import 'package:voya/core/domain/interview_results/entities/interview_result.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';
import 'package:voya/core/error/failure.dart';
import 'package:voya/core/presentation/bloc/interview/interview_bloc.dart';
import 'package:voya/core/presentation/bloc/interview/interview_event.dart';
import 'package:voya/core/presentation/bloc/interview/interview_status.dart';

class _MockAIInterviewService extends Mock implements AIInterviewService {}

class _MockSpeechToTextService extends Mock implements SpeechToTextService {}

class _MockTextToSpeechService extends Mock implements TextToSpeechService {}

class _MockInterviewRepository extends Mock implements InterviewRepository {}

class _MockPermissionService extends Mock implements PermissionService {}

void main() {
  late _MockAIInterviewService ai;
  late _MockSpeechToTextService stt;
  late _MockTextToSpeechService tts;
  late _MockInterviewRepository repository;
  late _MockPermissionService permissions;

  final configuration = const InterviewConfiguration(
    country: Country(code: 'AU', name: 'Australia', flagEmoji: '🇦🇺'),
    purpose: InterviewPurpose.work,
    difficulty: InterviewDifficulty.professional,
    durationMinutes: 5,
  );

  const openingQuestion = InterviewQuestion(
    id: 'q0',
    text: 'Tell me about yourself.',
    kind: QuestionKind.opening,
    order: 0,
  );

  setUpAll(() {
    registerFallbackValue(configuration);
    registerFallbackValue(<InterviewTurn>[]);
    registerFallbackValue(openingQuestion);
    registerFallbackValue(const InterviewTurn(question: openingQuestion));
    registerFallbackValue(
      InterviewSession(id: 'fallback', configuration: configuration, startedAt: DateTime(2026)),
    );
    registerFallbackValue(
      InterviewResult(
        sessionId: 'fallback',
        completedAt: DateTime(2026),
        communication: 0,
        clarity: 0,
        answerQuality: 0,
        speakingPace: 0,
        consistency: 0,
        strengths: const [],
        practiceAreas: const [],
        questionsToPractice: const [],
        fillerWordCounts: const {},
      ),
    );
  });

  setUp(() {
    ai = _MockAIInterviewService();
    stt = _MockSpeechToTextService();
    tts = _MockTextToSpeechService();
    repository = _MockInterviewRepository();
    permissions = _MockPermissionService();

    when(() => tts.initialize()).thenAnswer((_) async {});
    when(() => tts.dispose()).thenAnswer((_) async {});
    when(() => tts.stop()).thenAnswer((_) async {});
    when(() => stt.initialize()).thenAnswer((_) async => true);
    when(() => stt.dispose()).thenAnswer((_) async {});
    when(() => stt.stopListening()).thenAnswer((_) async {});
    when(() => repository.saveSession(any())).thenAnswer((_) async {});
    when(() => repository.saveResult(any())).thenAnswer((_) async {});
  });

  InterviewBloc buildBloc() => InterviewBloc(
    aiService: ai,
    speechToTextService: stt,
    textToSpeechService: tts,
    repository: repository,
    permissionService: permissions,
  );

  blocTest<InterviewBloc, dynamic>(
    'emits an error state when microphone permission is denied',
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => false);
    },
    build: buildBloc,
    act: (bloc) => bloc.add(StartInterviewRequested(configuration)),
    expect: () => [
      predicate<dynamic>((s) => s.status == InterviewStatus.preparing),
      predicate<dynamic>(
        (s) => s.status == InterviewStatus.error && s.failure is MicrophonePermissionFailure,
      ),
    ],
  );

  blocTest<InterviewBloc, dynamic>(
    'asks the opening question and starts speaking once permission is granted',
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => true);
      when(() => ai.generateOpeningQuestion(any())).thenAnswer((_) async => openingQuestion);
      when(() => tts.speak(any(), onAmplitude: any(named: 'onAmplitude'))).thenAnswer((_) async {});
      when(
        () => stt.startListening(
          onResult: any(named: 'onResult'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((_) async {});
    },
    build: buildBloc,
    act: (bloc) => bloc.add(StartInterviewRequested(configuration)),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.currentQuestion, openingQuestion);
      expect(bloc.state.status, InterviewStatus.listening);
      verify(() => tts.speak(openingQuestion.text, onAmplitude: any(named: 'onAmplitude')))
          .called(1);
    },
  );

  blocTest<InterviewBloc, dynamic>(
    'completes the interview and saves a result when ended early',
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => true);
      when(() => ai.generateOpeningQuestion(any())).thenAnswer((_) async => openingQuestion);
      when(() => tts.speak(any(), onAmplitude: any(named: 'onAmplitude'))).thenAnswer((_) async {});
      when(
        () => stt.startListening(
          onResult: any(named: 'onResult'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => ai.generateFeedback(
          configuration: any(named: 'configuration'),
          history: any(named: 'history'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenAnswer(
        (_) async => InterviewResult(
          sessionId: 'session-1',
          completedAt: DateTime(2026),
          communication: 0.5,
          clarity: 0.5,
          answerQuality: 0.5,
          speakingPace: 0.5,
          consistency: 0.5,
          strengths: const ['Good effort'],
          practiceAreas: const [],
          questionsToPractice: const [],
          fillerWordCounts: const {},
        ),
      );
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(StartInterviewRequested(configuration));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const EndInterviewRequested());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.status, InterviewStatus.completed);
      expect(bloc.state.result, isNotNull);
      verify(() => repository.saveResult(any())).called(1);
      verify(() => repository.saveSession(any())).called(1);
    },
  );

  blocTest<InterviewBloc, dynamic>(
    'quietly re-listens on error_no_match instead of failing the interview',
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => true);
      when(() => ai.generateOpeningQuestion(any())).thenAnswer((_) async => openingQuestion);
      when(() => tts.speak(any(), onAmplitude: any(named: 'onAmplitude'))).thenAnswer((_) async {});
      when(
        () => stt.startListening(
          onResult: any(named: 'onResult'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((_) async {});
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(StartInterviewRequested(configuration));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const MicPressStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const SpeechErrorOccurred('error_no_match'));
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      // Still recording — the mic quietly restarted rather than bouncing
      // back to idle or failing.
      expect(bloc.state.status, InterviewStatus.userSpeaking);
      expect(bloc.state.failure, isNull);
      // Once for the initial hold, once for the retry after the error.
      verify(
        () => stt.startListening(
          onResult: any(named: 'onResult'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          onError: any(named: 'onError'),
        ),
      ).called(2);
    },
  );

  blocTest<InterviewBloc, dynamic>(
    'gives up and shows an error after repeated error_no_match',
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => true);
      when(() => ai.generateOpeningQuestion(any())).thenAnswer((_) async => openingQuestion);
      when(() => tts.speak(any(), onAmplitude: any(named: 'onAmplitude'))).thenAnswer((_) async {});
      when(
        () => stt.startListening(
          onResult: any(named: 'onResult'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((_) async {});
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(StartInterviewRequested(configuration));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const MicPressStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const SpeechErrorOccurred('error_no_match'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const SpeechErrorOccurred('error_no_match'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const SpeechErrorOccurred('error_no_match'));
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.status, InterviewStatus.error);
      expect(bloc.state.failure, isA<SpeechRecognitionFailure>());
    },
  );

  blocTest<InterviewBloc, dynamic>(
    'records and submits an answer when the mic is pressed and released',
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => true);
      when(() => ai.generateOpeningQuestion(any())).thenAnswer((_) async => openingQuestion);
      when(() => tts.speak(any(), onAmplitude: any(named: 'onAmplitude'))).thenAnswer((_) async {});
      when(
        () => stt.startListening(
          onResult: any(named: 'onResult'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => ai.analyzeAnswer(
          configuration: any(named: 'configuration'),
          history: any(named: 'history'),
          currentTurn: any(named: 'currentTurn'),
        ),
      ).thenAnswer(
        (_) async =>
            const AnswerAnalysis(isVague: false, isInconsistent: false, followUpQuestion: null),
      );
      when(
        () => ai.generateNextQuestion(
          configuration: any(named: 'configuration'),
          history: any(named: 'history'),
        ),
      ).thenAnswer(
        (_) async => const InterviewQuestion(
          id: 'q1',
          text: 'What did you like about your last role?',
          kind: QuestionKind.followUp,
          order: 1,
        ),
      );
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(StartInterviewRequested(configuration));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const MicPressStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const UserSpeechUpdated('I led a small team', false));
      bloc.add(const MicPressStopped());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.turns, hasLength(1));
      expect(bloc.state.turns.first.answer?.transcript, 'I led a small team');
      verify(() => stt.stopListening()).called(greaterThanOrEqualTo(1));
    },
  );

  blocTest<InterviewBloc, dynamic>(
    "ignores a late final STT result after the mic was already released",
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => true);
      when(() => ai.generateOpeningQuestion(any())).thenAnswer((_) async => openingQuestion);
      when(() => tts.speak(any(), onAmplitude: any(named: 'onAmplitude'))).thenAnswer((_) async {});
      when(
        () => stt.startListening(
          onResult: any(named: 'onResult'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => ai.analyzeAnswer(
          configuration: any(named: 'configuration'),
          history: any(named: 'history'),
          currentTurn: any(named: 'currentTurn'),
        ),
      ).thenAnswer(
        (_) async =>
            const AnswerAnalysis(isVague: false, isInconsistent: false, followUpQuestion: null),
      );
      when(
        () => ai.generateNextQuestion(
          configuration: any(named: 'configuration'),
          history: any(named: 'history'),
        ),
      ).thenAnswer(
        (_) async => const InterviewQuestion(
          id: 'q1',
          text: 'What did you like about your last role?',
          kind: QuestionKind.followUp,
          order: 1,
        ),
      );
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(StartInterviewRequested(configuration));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const MicPressStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const UserSpeechUpdated('I led a small team', false));
      bloc.add(const MicPressStopped());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // A late final result the recognizer delivers after release should be
      // ignored, not recorded as a second turn.
      bloc.add(const UserSpeechUpdated('I led a small team', true));
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.turns, hasLength(1));
    },
  );

  test('needsFollowUp analysis is respected when deciding what to ask next', () {
    const analysis = AnswerAnalysis(
      isVague: true,
      isInconsistent: false,
      followUpQuestion: 'Could you be more specific?',
    );
    expect(analysis.needsFollowUp, isTrue);
  });
}
