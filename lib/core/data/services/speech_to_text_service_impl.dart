import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:voya/core/domain/interview/services/speech_to_text_service.dart';

class SpeechToTextServiceImpl implements SpeechToTextService {
  SpeechToTextServiceImpl() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _available = false;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize() async {
    _available = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _available;
  }

  @override
  Future<void> startListening({
    required void Function(String transcript, bool isFinal) onResult,
    required void Function(double level) onSoundLevelChange,
    required void Function(String error) onError,
    Duration pauseFor = const Duration(milliseconds: 1600),
    Duration listenFor = const Duration(seconds: 90),
  }) async {
    if (!_available) {
      final ok = await initialize();
      if (!ok) {
        onError('unavailable');
        return;
      }
    }

    // Attached before starting, not after — otherwise an error fired the
    // instant listening starts (a common case for "error_no_match") could
    // fire before this listener was assigned and get silently dropped.
    _speech.errorListener = (SpeechRecognitionError e) => onError(e.errorMsg);

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      onSoundLevelChange: onSoundLevelChange,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
      // ignore: deprecated_member_use
      pauseFor: pauseFor,
      // ignore: deprecated_member_use
      listenFor: listenFor,
    );
  }

  @override
  Future<void> stopListening() => _speech.stop();

  @override
  Future<void> dispose() async {
    await _speech.cancel();
  }
}
