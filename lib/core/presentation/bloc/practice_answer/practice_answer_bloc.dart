import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voya/core/error/failure.dart';
import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';
import 'package:voya/core/domain/interview/services/permission_service.dart';
import 'package:voya/core/domain/interview/services/speech_to_text_service.dart';
import 'package:voya/core/domain/interview/services/text_to_speech_service.dart';
import 'package:voya/core/data/services/permission_service_impl.dart';

import 'practice_answer_event.dart';
import 'practice_answer_state.dart';
import 'practice_answer_status.dart';

/// Orchestrates practicing a single answer-guidance question aloud: TTS
/// reads the question -> push-to-talk mic -> STT transcript -> AI feedback.
/// Reuses the exact same [SpeechToTextService]/[TextToSpeechService]
/// interfaces and push-to-talk flow as [InterviewBloc], simplified to one
/// question with no timer and no multi-turn follow-ups.
class PracticeAnswerBloc extends Bloc<PracticeAnswerEvent, PracticeAnswerState> {
  PracticeAnswerBloc({
    required AnswerGuidanceService guidanceService,
    required SpeechToTextService speechToTextService,
    required TextToSpeechService textToSpeechService,
    PermissionService? permissionService,
  }) : _guidance = guidanceService,
       _stt = speechToTextService,
       _tts = textToSpeechService,
       _permissions = permissionService ?? PermissionServiceImpl(),
       super(const PracticeAnswerState()) {
    on<PracticeStarted>(_onStarted);
    on<AiFinishedAsking>(_onAiFinishedAsking);
    on<UserSpeechUpdated>(_onUserSpeechUpdated);
    on<AmplitudeChanged>(_onAmplitudeChanged);
    on<SpeechErrorOccurred>(_onSpeechError);
    on<MicrophonePermissionDenied>(_onMicPermissionDenied);
    on<MicPressStarted>(_onMicPressStarted);
    on<MicPressStopped>(_onMicPressStopped);
    on<RetryRequested>(_onRetryRequested);
  }

  final AnswerGuidanceService _guidance;
  final SpeechToTextService _stt;
  final TextToSpeechService _tts;
  final PermissionService _permissions;

  static const _recoverableSpeechErrors = {'error_no_match', 'error_speech_timeout', 'error_retry'};

  Future<void> _onStarted(PracticeStarted event, Emitter<PracticeAnswerState> emit) async {
    emit(
      PracticeAnswerState(
        status: PracticeAnswerStatus.askingQuestion,
        question: event.question,
        guide: event.guide,
      ),
    );

    final hasMic = await _permissions.requestMicrophone();
    if (!hasMic) {
      add(const MicrophonePermissionDenied());
      return;
    }

    await _tts.initialize();
    await _stt.initialize();
    await _ask(event.question.text, emit);
  }

  Future<void> _ask(String text, Emitter<PracticeAnswerState> emit) async {
    emit(state.copyWith(status: PracticeAnswerStatus.askingQuestion, clearFailure: true));
    try {
      await _tts.speak(text, onAmplitude: (a) => add(AmplitudeChanged(a)));
      add(const AiFinishedAsking());
    } catch (_) {
      emit(
        state.copyWith(status: PracticeAnswerStatus.error, failure: const TextToSpeechFailure()),
      );
    }
  }

  Future<void> _onAiFinishedAsking(
    AiFinishedAsking event,
    Emitter<PracticeAnswerState> emit,
  ) async {
    emit(state.copyWith(status: PracticeAnswerStatus.listening, amplitude: 0, liveTranscript: ''));
  }

  Future<void> _onMicPressStarted(MicPressStarted event, Emitter<PracticeAnswerState> emit) async {
    if (state.status != PracticeAnswerStatus.listening) return;
    await _beginRecording(emit);
  }

  Future<void> _beginRecording(Emitter<PracticeAnswerState> emit) async {
    emit(state.copyWith(status: PracticeAnswerStatus.recording, amplitude: 0, liveTranscript: ''));
    await _stt.startListening(
      onResult: (transcript, isFinal) => add(UserSpeechUpdated(transcript, isFinal)),
      onSoundLevelChange: (level) {
        final normalized = ((level + 2) / 12).clamp(0.0, 1.0);
        add(AmplitudeChanged(normalized));
      },
      onError: (error) => add(SpeechErrorOccurred(error)),
    );
  }

  Future<void> _onMicPressStopped(MicPressStopped event, Emitter<PracticeAnswerState> emit) async {
    if (state.status != PracticeAnswerStatus.recording) return;
    await _stt.stopListening();
    await _finalizeAnswer(state.liveTranscript, emit);
  }

  Future<void> _onUserSpeechUpdated(
    UserSpeechUpdated event,
    Emitter<PracticeAnswerState> emit,
  ) async {
    if (!event.isFinal) {
      if (state.status != PracticeAnswerStatus.recording) return;
      emit(state.copyWith(liveTranscript: event.transcript));
      return;
    }

    if (state.status != PracticeAnswerStatus.recording) return;
    await _stt.stopListening();
    await _finalizeAnswer(event.transcript, emit);
  }

  Future<void> _finalizeAnswer(String transcript, Emitter<PracticeAnswerState> emit) async {
    final question = state.question;
    final guide = state.guide;
    if (question == null || guide == null) return;

    emit(
      state.copyWith(
        status: PracticeAnswerStatus.processingAnswer,
        liveTranscript: transcript,
        amplitude: 0,
      ),
    );

    try {
      final feedback = await _guidance.analyzeAnswer(
        question: question,
        guide: guide,
        transcript: transcript,
      );
      emit(state.copyWith(status: PracticeAnswerStatus.feedbackReady, feedback: feedback));
    } catch (e) {
      emit(
        state.copyWith(
          status: PracticeAnswerStatus.error,
          failure: AiProviderFailure(e.toString()),
        ),
      );
    }
  }

  void _onAmplitudeChanged(AmplitudeChanged event, Emitter<PracticeAnswerState> emit) {
    emit(state.copyWith(amplitude: event.amplitude));
  }

  Future<void> _onSpeechError(SpeechErrorOccurred event, Emitter<PracticeAnswerState> emit) async {
    final isRecoverable = _recoverableSpeechErrors.contains(event.message);
    final failure = isRecoverable
        ? const SpeechRecognitionFailure(
            "We still couldn't hear a clear answer. Check your microphone and try again.",
          )
        : SpeechRecognitionFailure(event.message);
    emit(state.copyWith(status: PracticeAnswerStatus.error, failure: failure));
  }

  void _onMicPermissionDenied(MicrophonePermissionDenied event, Emitter<PracticeAnswerState> emit) {
    emit(
      state.copyWith(
        status: PracticeAnswerStatus.error,
        failure: const MicrophonePermissionFailure(),
      ),
    );
  }

  Future<void> _onRetryRequested(RetryRequested event, Emitter<PracticeAnswerState> emit) async {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(clearFailure: true, clearFeedback: true, liveTranscript: ''));
    await _ask(question.text, emit);
  }

  @override
  Future<void> close() async {
    await _tts.dispose();
    await _stt.dispose();
    return super.close();
  }
}
