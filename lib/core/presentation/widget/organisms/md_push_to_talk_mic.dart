import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';

/// The push-to-talk mic control shared by the mock interview and the Answer
/// Coach practice screen — hold to record, release to submit. Extracted once
/// both screens needed the exact same button, so the gesture and visual
/// states stay in one place instead of drifting between two copies.
class MdPushToTalkMic extends StatelessWidget {
  const MdPushToTalkMic({
    super.key,
    required this.isReady,
    required this.isRecording,
    required this.onPressStart,
    required this.onPressEnd,
  });

  /// True once the AI has finished speaking and is waiting for a press.
  final bool isReady;

  /// True while the user is actively holding the mic.
  final bool isRecording;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;

  @override
  Widget build(BuildContext context) {
    final canPress = isReady || isRecording;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPressStart: canPress ? (_) => onPressStart() : null,
          onLongPressEnd: canPress ? (_) => onPressEnd() : null,
          onLongPressCancel: canPress ? onPressEnd : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording ? AppColors.listening.withValues(alpha: 0.15) : Colors.white10,
              border: isReady
                  ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5)
                  : null,
            ),
            child: Icon(
              isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: isRecording
                  ? AppColors.listening
                  : (isReady ? Colors.white70 : Colors.white38),
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // This is the single most important instruction in the app — the
        // whole recording flow hinges on the user noticing it — so it's kept
        // large, bold, and near-full-white rather than the small gray
        // caption text it used to be.
        if (canPress)
          Text(
            isRecording ? 'Release to finish' : 'Hold the button to answer',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}
