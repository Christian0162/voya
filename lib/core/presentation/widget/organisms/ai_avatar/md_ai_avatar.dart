import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'package:voya/config/constant/app_colors.dart';

import 'ai_avatar_controller.dart';
import 'ai_avatar_state.dart';

/// The animated 2D AI interviewer — the real `voya-character.riv` rig
/// (artboard "Coach model", state machine "State Machine 1"). The rig's own
/// "idle" state already handles breathing/blinking, so this widget only
/// drives what our conversation needs on top of that: a lip-sync viseme
/// input while [AiAvatarState.speaking].
///
/// Input names ("lips sync id", "lips sync") were read from the raw file's
/// string table, not confirmed via a live state-machine inspection (Windows
/// desktop dev mode is disabled on the build machine, and the file can't be
/// inspected via `flutter test` because the native rive_common plugin isn't
/// bundled there). [StateMachineController.findInput] returns null for a
/// wrong/missing name rather than throwing, so a wrong guess here just means
/// the mouth won't animate while speaking — the character still renders and
/// nothing crashes. Once this runs on a real device/emulator, correct any
/// input names below against what's actually exposed.
class MdAiAvatar extends StatefulWidget {
  const MdAiAvatar({super.key, required this.controller, this.size = 220});

  final AiAvatarController controller;
  final double size;

  @override
  State<MdAiAvatar> createState() => _MdAiAvatarState();
}

class _MdAiAvatarState extends State<MdAiAvatar> {
  static const _assetPath = 'assets/rive/voya-character.riv';
  static const _stateMachineName = 'State Machine 1';

  /// Number input, 0–9: selects a mouth/viseme shape (best-effort name).
  static const _lipsSyncIdInput = 'lips sync id';

  /// Boolean input: switches the rig into lip-sync-driven mouth mode while
  /// speaking (best-effort name).
  static const _lipsSyncActiveInput = 'lips sync';

  SMIInput<double>? _lipsSyncId;
  SMIInput<bool>? _lipsSyncActive;
  Timer? _lipSyncTimer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, _stateMachineName) ??
        (artboard.stateMachines.isNotEmpty
            ? StateMachineController.fromArtboard(artboard, artboard.stateMachines.first.name)
            : null);
    if (controller == null) return;

    artboard.addController(controller);
    _lipsSyncId = controller.findInput<double>(_lipsSyncIdInput);
    _lipsSyncActive = controller.findInput<bool>(_lipsSyncActiveInput);
    _syncStateToRig();
  }

  void _onControllerChanged() => _syncStateToRig();

  void _syncStateToRig() {
    final isSpeaking = widget.controller.state == AiAvatarState.speaking;
    _lipsSyncActive?.value = isSpeaking;
    if (isSpeaking) {
      _startLipSyncLoop();
    } else {
      _stopLipSyncLoop();
      _lipsSyncId?.value = 0;
    }
  }

  void _startLipSyncLoop() {
    _lipSyncTimer ??= Timer.periodic(const Duration(milliseconds: 90), (_) {
      // Real viseme timing would come from the TTS engine's phoneme
      // callbacks, which flutter_tts doesn't expose — this approximates
      // mouth movement from the same synthetic amplitude that drives the
      // waveform, with a little jitter so it doesn't look mechanical.
      final amplitude = widget.controller.amplitude;
      final jitter = _random.nextDouble() * 0.15;
      final visemeId = ((amplitude + jitter) * 9).clamp(0, 9).roundToDouble();
      _lipsSyncId?.value = visemeId;
    });
  }

  void _stopLipSyncLoop() {
    _lipSyncTimer?.cancel();
    _lipSyncTimer = null;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _stopLipSyncLoop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    return Semantics(
      label: _semanticLabelFor(state),
      liveRegion: true,
      child: SizedBox(
        width: widget.size * 1.5,
        height: widget.size * 1.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (state == AiAvatarState.listening) _ListenRing(size: widget.size),
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: RiveAnimation.asset(
                _assetPath,
                fit: BoxFit.contain,
                onInit: _onRiveInit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _semanticLabelFor(AiAvatarState state) {
    switch (state) {
      case AiAvatarState.idle:
        return 'AI interviewer, waiting';
      case AiAvatarState.thinking:
        return 'AI interviewer is thinking';
      case AiAvatarState.speaking:
        return 'AI interviewer is speaking';
      case AiAvatarState.listening:
        return 'AI interviewer is listening to you';
      case AiAvatarState.processing:
        return 'AI interviewer is analyzing your answer';
    }
  }
}

/// Self-contained pulsing ring shown around the avatar while listening —
/// independent of the Rive rig entirely, since it's a UI affordance rather
/// than part of the character.
class _ListenRing extends StatefulWidget {
  const _ListenRing({required this.size});

  final double size;

  @override
  State<_ListenRing> createState() => _ListenRingState();
}

class _ListenRingState extends State<_ListenRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.size + t * 40,
          height: widget.size + t * 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.listening.withValues(alpha: (1 - t) * 0.6),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
