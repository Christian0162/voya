import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:voya/core/error/failure.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/domain/interview/entities/interview_session.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/domain/interview/services/ai_interview_service.dart';
import 'package:voya/core/domain/interview/services/permission_service.dart';
import 'package:voya/core/domain/interview/services/speech_to_text_service.dart';
import 'package:voya/core/domain/interview/services/text_to_speech_service.dart';
import 'package:voya/core/data/services/answer_builder.dart';
import 'package:voya/core/data/services/permission_service_impl.dart';

import 'interview_event.dart';
import 'interview_state.dart';
import 'interview_status.dart';

/// Orchestrates the full voice conversation loop described in the spec:
/// AI speaks -> avatar talks -> AI finishes -> app listens -> user speaks ->
/// speech processed -> AI analyzes -> follow-up or next question -> repeat.
///
/// The bloc never touches `speech_to_text`/`flutter_tts` directly — it only
/// depends on the [SpeechToTextService]/[TextToSpeechService]/
/// [AIInterviewService] interfaces, so those can be swapped independently.
class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  InterviewBloc({
    required AIInterviewService aiService,
    required SpeechToTextService speechToTextService,
    required TextToSpeechService textToSpeechService,
    required InterviewRepository repository,
    PermissionService? permissionService,
    Uuid? uuid,
  }) : _ai = aiService,
       _stt = speechToTextService,
       _tts = textToSpeechService,
       _repository = repository,
       _permissions = permissionService ?? PermissionServiceImpl(),
       _uuid = uuid ?? const Uuid(),
       super(const InterviewState()) {
    on<StartInterviewRequested>(_onStart);
    on<AiFinishedSpeaking>(_onAiFinishedSpeaking);
    on<UserSpeechUpdated>(_onUserSpeechUpdated);
    on<AmplitudeChanged>(_onAmplitudeChanged);
    on<SpeechErrorOccurred>(_onSpeechError);
    on<MicrophonePermissionDenied>(_onMicPermissionDenied);
    on<RetryListeningRequested>(_onRetryListening);
    on<EndInterviewRequested>(_onEndInterview);
    on<TimerTicked>(_onTimerTicked);
  }

  final AIInterviewService _ai;
  final SpeechToTextService _stt;
  final TextToSpeechService _tts;
  final InterviewRepository _repository;
  final PermissionService _permissions;
  final Uuid _uuid;

  /// STT errors that just mean "didn't catch that" (silence, a pause that ran
  /// past the recognizer's timeout, or — on iOS — a transient retry signal)
  /// rather than a real failure. See speech_to_text's [SpeechErrorListener]
  /// docs for the full list Android/iOS can report.
  static const _recoverableSpeechErrors = {'error_no_match', 'error_speech_timeout', 'error_retry'};
  static const _maxAutoRetries = 2;

  Timer? _clock;
  DateTime? _listenStartedAt;
  DateTime? _sessionStartedAt;
  int _questionCounter = 0;
  int _consecutiveNoMatchCount = 0;

  Future<void> _onStart(StartInterviewRequested event, Emitter<InterviewState> emit) async {
    emit(
      InterviewState(
        status: InterviewStatus.preparing,
        configuration: event.configuration,
        sessionId: _uuid.v4(),
      ),
    );

    final hasMic = await _permissions.requestMicrophone();
    if (!hasMic) {
      add(const MicrophonePermissionDenied());
      return;
    }

    await _tts.initialize();
    await _stt.initialize();

    _sessionStartedAt = DateTime.now();
    _startClock();

    try {
      final question = await _ai.generateOpeningQuestion(event.configuration);
      _questionCounter = 1;
      emit(state.copyWith(currentQuestion: question, clearFailure: true));
      await _speak(question, emit);
    } catch (_) {
      emit(state.copyWith(status: InterviewStatus.error, failure: const AiProviderFailure()));
    }
  }

  Future<void> _speak(InterviewQuestion question, Emitter<InterviewState> emit) async {
    _consecutiveNoMatchCount = 0;
    emit(state.copyWith(status: InterviewStatus.aiSpeaking, currentQuestion: question));
    try {
      await _tts.speak(question.text, onAmplitude: (a) => add(AmplitudeChanged(a)));
      add(const AiFinishedSpeaking());
    } catch (_) {
      emit(state.copyWith(status: InterviewStatus.error, failure: const TextToSpeechFailure()));
    }
  }

  Future<void> _onAiFinishedSpeaking(AiFinishedSpeaking event, Emitter<InterviewState> emit) async {
    await _startListening(emit);
  }

  Future<void> _startListening(Emitter<InterviewState> emit) async {
    emit(state.copyWith(status: InterviewStatus.listening, amplitude: 0, liveTranscript: ''));
    _listenStartedAt = DateTime.now();
    await _stt.startListening(
      onResult: (transcript, isFinal) => add(UserSpeechUpdated(transcript, isFinal)),
      onSoundLevelChange: (level) {
        // speech_to_text reports raw dB (roughly -2..10). Normalize to 0-1.
        final normalized = ((level + 2) / 12).clamp(0.0, 1.0);
        add(AmplitudeChanged(normalized));
      },
      onError: (error) => add(SpeechErrorOccurred(error)),
    );
  }

  Future<void> _onUserSpeechUpdated(UserSpeechUpdated event, Emitter<InterviewState> emit) async {
    if (!event.isFinal) {
      emit(state.copyWith(status: InterviewStatus.userSpeaking, liveTranscript: event.transcript));
      return;
    }

    await _stt.stopListening();
    _consecutiveNoMatchCount = 0;
    final duration = _listenStartedAt == null
        ? Duration.zero
        : DateTime.now().difference(_listenStartedAt!);

    final question = state.currentQuestion;
    if (question == null) return;

    final answer = AnswerBuilder.build(
      questionId: question.id,
      transcript: event.transcript,
      spokenDuration: duration,
    );

    final updatedTurns = [...state.turns, InterviewTurn(question: question, answer: answer)];
    emit(
      state.copyWith(
        status: InterviewStatus.processingAnswer,
        turns: updatedTurns,
        liveTranscript: '',
        amplitude: 0,
      ),
    );

    unawaited(_processAnswer(updatedTurns.last, updatedTurns, emit));
  }

  Future<void> _processAnswer(
    InterviewTurn turn,
    List<InterviewTurn> history,
    Emitter<InterviewState> emit,
  ) async {
    final configuration = state.configuration;
    if (configuration == null) return;

    try {
      final reachedLimit = history.length >= state.estimatedTotalQuestions;
      final timeUp = state.elapsed >= Duration(minutes: configuration.durationMinutes);

      if (reachedLimit || timeUp) {
        await _completeInterview(history, emit);
        return;
      }

      final analysis = await _ai.analyzeAnswer(
        configuration: configuration,
        history: history.sublist(0, history.length - 1),
        currentTurn: turn,
      );

      emit(state.copyWith(status: InterviewStatus.aiThinking));

      _questionCounter += 1;
      final next = analysis.needsFollowUp
          ? InterviewQuestion(
              id: 'q$_questionCounter-followup',
              text: analysis.followUpQuestion!,
              kind: QuestionKind.followUp,
              order: _questionCounter,
            )
          : await _ai.generateNextQuestion(configuration: configuration, history: history);

      await _speak(next, emit);
    } catch (_) {
      emit(state.copyWith(status: InterviewStatus.error, failure: const AiProviderFailure()));
    }
  }

  Future<void> _completeInterview(List<InterviewTurn> history, Emitter<InterviewState> emit) async {
    final configuration = state.configuration;
    final sessionId = state.sessionId;
    if (configuration == null || sessionId == null) return;

    emit(state.copyWith(status: InterviewStatus.generatingFeedback));
    _stopClock();
    await _tts.stop();
    await _stt.stopListening();

    final result = await _ai.generateFeedback(
      configuration: configuration,
      history: history,
      sessionId: sessionId,
    );

    final session = InterviewSession(
      id: sessionId,
      configuration: configuration,
      startedAt: _sessionStartedAt ?? DateTime.now(),
      turns: history,
      endedAt: DateTime.now(),
    );

    await _repository.saveSession(session);
    await _repository.saveResult(result);

    emit(state.copyWith(status: InterviewStatus.completed, result: result, turns: history));
  }

  void _onAmplitudeChanged(AmplitudeChanged event, Emitter<InterviewState> emit) {
    emit(state.copyWith(amplitude: event.amplitude));
  }

  Future<void> _onSpeechError(SpeechErrorOccurred event, Emitter<InterviewState> emit) async {
    final isListeningPhase =
        state.status == InterviewStatus.listening || state.status == InterviewStatus.userSpeaking;
    final isRecoverable = _recoverableSpeechErrors.contains(event.message);

    if (isListeningPhase && isRecoverable && _consecutiveNoMatchCount < _maxAutoRetries) {
      // The user just didn't say anything (or a pause ran past the
      // recognizer's timeout) — not a real failure, so quietly listen again
      // instead of dropping the whole interview into an error screen.
      _consecutiveNoMatchCount += 1;
      await _stt.stopListening();
      await _startListening(emit);
      return;
    }

    _consecutiveNoMatchCount = 0;
    final failure = isRecoverable
        ? const SpeechRecognitionFailure(
            "We still couldn't hear a clear answer. Check your microphone and try again.",
          )
        : SpeechRecognitionFailure(event.message);

    emit(state.copyWith(status: InterviewStatus.error, failure: failure));
  }

  void _onMicPermissionDenied(MicrophonePermissionDenied event, Emitter<InterviewState> emit) {
    emit(
      state.copyWith(status: InterviewStatus.error, failure: const MicrophonePermissionFailure()),
    );
  }

  Future<void> _onRetryListening(
    RetryListeningRequested event,
    Emitter<InterviewState> emit,
  ) async {
    final hasMic = await _permissions.requestMicrophone();
    if (!hasMic) {
      add(const MicrophonePermissionDenied());
      return;
    }
    emit(state.copyWith(clearFailure: true));
    if (state.currentQuestion != null && state.turns.length < state.estimatedTotalQuestions) {
      add(const AiFinishedSpeaking());
    }
  }

  Future<void> _onEndInterview(EndInterviewRequested event, Emitter<InterviewState> emit) async {
    await _completeInterview(state.turns, emit);
  }

  void _onTimerTicked(TimerTicked event, Emitter<InterviewState> emit) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  void _startClock() {
    _clock?.cancel();
    final startedAt = DateTime.now();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTicked(DateTime.now().difference(startedAt)));
    });
  }

  void _stopClock() {
    _clock?.cancel();
    _clock = null;
  }

  @override
  Future<void> close() async {
    _stopClock();
    await _tts.dispose();
    await _stt.dispose();
    return super.close();
  }
}
