import 'dart:math';

import 'package:flutter/material.dart';

/// A subtle, premium audio-reactive waveform. Feed it a live 0.0–1.0
/// amplitude stream (from TTS synthetic amplitude or STT sound level) via
/// [amplitude] — it keeps a short rolling history internally so bars appear
/// to travel rather than jump, without needing an external buffer.
class MdVoiceWaveform extends StatefulWidget {
  const MdVoiceWaveform({
    super.key,
    required this.amplitude,
    required this.color,
    this.barCount = 24,
    this.height = 48,
  });

  final double amplitude;
  final Color color;
  final int barCount;
  final double height;

  @override
  State<MdVoiceWaveform> createState() => _MdVoiceWaveformState();
}

class _MdVoiceWaveformState extends State<MdVoiceWaveform> {
  late List<double> _levels;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _levels = List.filled(widget.barCount, 0.08);
  }

  @override
  void didUpdateWidget(covariant MdVoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amplitude != widget.amplitude) {
      final jitter = (_random.nextDouble() - 0.5) * 0.15;
      final next = (widget.amplitude + jitter).clamp(0.05, 1.0);
      _levels = [..._levels.sublist(1), next];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final level in _levels)
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: max(4, widget.height * level),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
