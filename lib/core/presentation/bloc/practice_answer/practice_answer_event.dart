import 'package:equatable/equatable.dart';

import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';

abstract class PracticeAnswerEvent extends Equatable {
  const PracticeAnswerEvent();

  @override
  List<Object?> get props => [];
}

class PracticeStarted extends PracticeAnswerEvent {
  const PracticeStarted({required this.question, required this.guide});
  final GuidanceQuestion question;
  final AnswerGuide guide;

  @override
  List<Object?> get props => [question, guide];
}

/// Internal: fired when the TTS finishes reading the question aloud.
class AiFinishedAsking extends PracticeAnswerEvent {
  const AiFinishedAsking();
}

/// Internal: fired on every partial/final STT result.
class UserSpeechUpdated extends PracticeAnswerEvent {
  const UserSpeechUpdated(this.transcript, this.isFinal);
  final String transcript;
  final bool isFinal;

  @override
  List<Object?> get props => [transcript, isFinal];
}

class AmplitudeChanged extends PracticeAnswerEvent {
  const AmplitudeChanged(this.amplitude);
  final double amplitude;

  @override
  List<Object?> get props => [amplitude];
}

class SpeechErrorOccurred extends PracticeAnswerEvent {
  const SpeechErrorOccurred(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class MicrophonePermissionDenied extends PracticeAnswerEvent {
  const MicrophonePermissionDenied();
}

/// Push-to-talk, same model as the mock interview.
class MicPressStarted extends PracticeAnswerEvent {
  const MicPressStarted();
}

class MicPressStopped extends PracticeAnswerEvent {
  const MicPressStopped();
}

/// Re-asks the same question and clears any previous feedback/transcript.
class RetryRequested extends PracticeAnswerEvent {
  const RetryRequested();
}
