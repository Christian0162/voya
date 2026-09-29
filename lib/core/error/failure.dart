import 'package:equatable/equatable.dart';

/// Base type for recoverable failures surfaced to the UI.
///
/// Keeping these as data (not thrown strings) lets the presentation layer
/// render a specific recovery action per [InterviewErrorState] instead of a
/// generic "something went wrong" toast.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MicrophonePermissionFailure extends Failure {
  const MicrophonePermissionFailure() : super('Microphone access is needed to hear your answers.');
}

class NoMicrophoneFailure extends Failure {
  const NoMicrophoneFailure() : super('No microphone was found on this device.');
}

class SpeechRecognitionFailure extends Failure {
  const SpeechRecognitionFailure([String? reason])
    : super(reason ?? "We couldn't hear your answer clearly.");
}

class TextToSpeechFailure extends Failure {
  const TextToSpeechFailure() : super("The interviewer's voice couldn't be played.");
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Check your connection and try again.');
}

class AiProviderFailure extends Failure {
  const AiProviderFailure([String? reason])
    : super(reason ?? 'The AI interviewer is unavailable right now.');
}

class AuthFailure extends Failure {
  const AuthFailure([String? reason]) : super(reason ?? "We couldn't sign you in right now.");
}

class UnknownFailure extends Failure {
  const UnknownFailure([String? reason]) : super(reason ?? 'Something went wrong.');
}
