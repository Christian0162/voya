import 'package:equatable/equatable.dart';

import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();

  @override
  List<Object?> get props => [];
}

class StartInterviewRequested extends InterviewEvent {
  const StartInterviewRequested(this.configuration);
  final InterviewConfiguration configuration;

  @override
  List<Object?> get props => [configuration];
}

/// Internal: fired when the TTS finishes reading the current question.
class AiFinishedSpeaking extends InterviewEvent {
  const AiFinishedSpeaking();
}

/// Internal: fired on every partial/final STT result.
class UserSpeechUpdated extends InterviewEvent {
  const UserSpeechUpdated(this.transcript, this.isFinal);
  final String transcript;
  final bool isFinal;

  @override
  List<Object?> get props => [transcript, isFinal];
}

/// Internal: fired by the TTS/STT amplitude callbacks to drive the waveform.
class AmplitudeChanged extends InterviewEvent {
  const AmplitudeChanged(this.amplitude);
  final double amplitude;

  @override
  List<Object?> get props => [amplitude];
}

class SpeechErrorOccurred extends InterviewEvent {
  const SpeechErrorOccurred(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class MicrophonePermissionDenied extends InterviewEvent {
  const MicrophonePermissionDenied();
}

/// Fired when the user presses and holds the mic button to start recording
/// their answer (push-to-talk).
class MicPressStarted extends InterviewEvent {
  const MicPressStarted();
}

/// Fired when the user releases the mic button, ending their answer.
class MicPressStopped extends InterviewEvent {
  const MicPressStopped();
}

class RetryListeningRequested extends InterviewEvent {
  const RetryListeningRequested();
}

class EndInterviewRequested extends InterviewEvent {
  const EndInterviewRequested();
}

class TimerTicked extends InterviewEvent {
  const TimerTicked(this.elapsed);
  final Duration elapsed;

  @override
  List<Object?> get props => [elapsed];
}
