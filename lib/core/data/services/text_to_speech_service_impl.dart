import 'dart:async';
import 'dart:math';

import 'package:flutter_tts/flutter_tts.dart';

import 'package:voya/core/domain/interview/services/text_to_speech_service.dart';

/// [flutter_tts] does not expose real playback amplitude on most platforms,
/// so while speaking we synthesize a plausible waveform via a periodic timer.
/// This is called out explicitly rather than pretending it's real audio
/// analysis (spec section 19 — don't overclaim what the analysis measures).
class TextToSpeechServiceImpl implements TextToSpeechService {
  TextToSpeechServiceImpl() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _isSpeaking = false;
  Timer? _amplitudeTimer;
  final _random = Random();

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize() async {
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  @override
  Future<void> speak(String text, {void Function(double amplitude)? onAmplitude}) async {
    _isSpeaking = true;
    _startSyntheticAmplitude(onAmplitude);
    try {
      await _tts.speak(text);
    } finally {
      _isSpeaking = false;
      _amplitudeTimer?.cancel();
      onAmplitude?.call(0);
    }
  }

  void _startSyntheticAmplitude(void Function(double amplitude)? onAmplitude) {
    if (onAmplitude == null) return;
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      onAmplitude(0.25 + _random.nextDouble() * 0.65);
    });
  }

  @override
  Future<void> stop() async {
    _amplitudeTimer?.cancel();
    _isSpeaking = false;
    await _tts.stop();
  }

  @override
  Future<void> dispose() async {
    _amplitudeTimer?.cancel();
    await _tts.stop();
  }
}
