/// Abstraction over on-device speech recognition so the bloc never touches
/// the `speech_to_text` package directly.
abstract class SpeechToTextService {
  Future<bool> initialize();

  bool get isAvailable;

  /// Starts listening. [onPartialResult] fires repeatedly with the growing
  /// transcript; [onSoundLevelChange] drives the live waveform (0.0–1.0-ish,
  /// raw dB from the platform — the widget normalizes it).
  Future<void> startListening({
    required void Function(String transcript, bool isFinal) onResult,
    required void Function(double level) onSoundLevelChange,
    required void Function(String error) onError,
    Duration pauseFor = const Duration(milliseconds: 1600),
    Duration listenFor = const Duration(seconds: 90),
  });

  Future<void> stopListening();

  bool get isListening;

  Future<void> dispose();
}
