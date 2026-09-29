import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_feedback.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';
import 'package:voya/core/domain/interview/services/permission_service.dart';
import 'package:voya/core/domain/interview/services/speech_to_text_service.dart';
import 'package:voya/core/domain/interview/services/text_to_speech_service.dart';
import 'package:voya/core/error/failure.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_bloc.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_event.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_status.dart';

class _MockAnswerGuidanceService extends Mock implements AnswerGuidanceService {}

class _MockSpeechToTextService extends Mock implements SpeechToTextService {}

class _MockTextToSpeechService extends Mock implements TextToSpeechService {}

class _MockPermissionService extends Mock implements PermissionService {}

void main() {
  late _MockAnswerGuidanceService guidance;
  late _MockSpeechToTextService stt;
  late _MockTextToSpeechService tts;
  late _MockPermissionService permissions;

  const question = GuidanceQuestion(
    id: 'travelPurpose_0',
    text: 'What is the purpose of your visit?',
    category: GuidanceCategory.travelPurpose,
  );

  const guide = AnswerGuide(
    questionExplanation: 'explanation',
    interviewerIntent: 'intent',
    answerStructure: ['step 1'],
    exampleAnswer: 'example',
    commonMistakes: ['mistake'],
    practiceTip: 'tip',
  );

  const feedback = AnswerFeedback(
    relevance: 0.8,
    clarity: 0.8,
    completeness: 0.8,
    naturalness: 0.8,
    consistency: 0.8,
    feedbackText: 'Nice work.',
  );

  setUpAll(() {
    registerFallbackValue(question);
    registerFallbackValue(guide);
  });

  setUp(() {
    guidance = _MockAnswerGuidanceService();
    stt = _MockSpeechToTextService();
    tts = _MockTextToSpeechService();
    permissions = _MockPermissionService();

    when(() => tts.initialize()).thenAnswer((_) async {});
    when(() => tts.dispose()).thenAnswer((_) async {});
    when(() => stt.initialize()).thenAnswer((_) async => true);
    when(() => stt.dispose()).thenAnswer((_) async {});
    when(() => stt.stopListening()).thenAnswer((_) async {});
    when(() => permissions.requestMicrophone()).thenAnswer((_) async => true);
    when(() => tts.speak(any(), onAmplitude: any(named: 'onAmplitude'))).thenAnswer((_) async {});
    when(
      () => stt.startListening(
        onResult: any(named: 'onResult'),
        onSoundLevelChange: any(named: 'onSoundLevelChange'),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((_) async {});
  });

  PracticeAnswerBloc buildBloc() => PracticeAnswerBloc(
    guidanceService: guidance,
    speechToTextService: stt,
    textToSpeechService: tts,
    permissionService: permissions,
  );

  blocTest<PracticeAnswerBloc, dynamic>(
    'emits an error state when microphone permission is denied',
    setUp: () {
      when(() => permissions.requestMicrophone()).thenAnswer((_) async => false);
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const PracticeStarted(question: question, guide: guide)),
    expect: () => [
      predicate<dynamic>((s) => s.status == PracticeAnswerStatus.askingQuestion),
      predicate<dynamic>(
        (s) => s.status == PracticeAnswerStatus.error && s.failure is MicrophonePermissionFailure,
      ),
    ],
  );

  blocTest<PracticeAnswerBloc, dynamic>(
    'asks the question aloud and waits for the mic once permission is granted',
    build: buildBloc,
    act: (bloc) => bloc.add(const PracticeStarted(question: question, guide: guide)),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.status, PracticeAnswerStatus.listening);
      verify(() => tts.speak(question.text, onAmplitude: any(named: 'onAmplitude'))).called(1);
    },
  );

  blocTest<PracticeAnswerBloc, dynamic>(
    'records an answer and surfaces feedback once the mic is released',
    setUp: () {
      when(
        () => guidance.analyzeAnswer(
          question: question,
          guide: guide,
          transcript: 'I am here for tourism',
        ),
      ).thenAnswer((_) async => feedback);
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const PracticeStarted(question: question, guide: guide));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const MicPressStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const UserSpeechUpdated('I am here for tourism', false));
      bloc.add(const MicPressStopped());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.status, PracticeAnswerStatus.feedbackReady);
      expect(bloc.state.feedback, feedback);
    },
  );

  blocTest<PracticeAnswerBloc, dynamic>(
    'retry re-asks the question and clears previous feedback',
    setUp: () {
      when(
        () => guidance.analyzeAnswer(
          question: question,
          guide: guide,
          transcript: 'I am here for tourism',
        ),
      ).thenAnswer((_) async => feedback);
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const PracticeStarted(question: question, guide: guide));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const MicPressStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const UserSpeechUpdated('I am here for tourism', false));
      bloc.add(const MicPressStopped());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const RetryRequested());
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.status, PracticeAnswerStatus.listening);
      expect(bloc.state.feedback, isNull);
      verify(() => tts.speak(question.text, onAmplitude: any(named: 'onAmplitude'))).called(2);
    },
  );
}
