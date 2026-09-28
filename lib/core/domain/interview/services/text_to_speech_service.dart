/// Abstraction over speech synthesis so the bloc never touches the
/// `flutter_tts` package directly.
abstract class TextToSpeechService {
  Future<void> initialize();

  /// Speaks [text] and completes when playback finishes. [onAmplitude] is a
  /// best-effort synthetic amplitude callback (device TTS engines rarely
  /// expose real amplitude) used to drive the "AI speaking" waveform.
  Future<void> speak(String text, {void Function(double amplitude)? onAmplitude});

  Future<void> stop();

  bool get isSpeaking;

  Future<void> dispose();
}
