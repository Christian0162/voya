import 'package:flutter/foundation.dart';

import 'ai_avatar_state.dart';

/// Drives the avatar widget's animations without the widget needing to know
/// about the interview bloc. The interview screen sets [state] and, while
/// speaking, feeds live [amplitude] samples from the TTS/STT amplitude
/// callbacks to make the mouth/waveform reactive.
class AiAvatarController extends ChangeNotifier {
  AiAvatarState _state = AiAvatarState.idle;
  double _amplitude = 0;

  AiAvatarState get state => _state;
  double get amplitude => _amplitude;

  void setState(AiAvatarState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }

  void setAmplitude(double value) {
    _amplitude = value.clamp(0.0, 1.0);
    notifyListeners();
  }
}
