import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/bloc/interview/interview_state.dart';
import 'package:voya/core/presentation/bloc/interview/interview_status.dart';
import 'package:voya/core/presentation/widget/molecules/md_country_hat.dart';
import 'package:voya/core/presentation/widget/molecules/md_error_state.dart';
import 'package:voya/core/presentation/widget/molecules/md_voice_waveform.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/ai_avatar_controller.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/md_ai_avatar.dart';
import 'package:voya/core/presentation/widget/organisms/md_push_to_talk_mic.dart';

/// Pure layout for the most important screen in the product (spec section
/// 15/41). All conversation state comes from [InterviewBloc] via the Screen;
/// this widget never touches the bloc, the router, or shows dialogs/sheets
/// itself — those are reported upward through callbacks.
class InterviewTemplate extends StatelessWidget {
  const InterviewTemplate({
    super.key,
    required this.state,
    required this.avatarController,
    required this.hasTranscript,
    required this.onEndInterviewPressed,
    required this.onShowTranscript,
    required this.onRetryListening,
    required this.onMicPressStart,
    required this.onMicPressEnd,
    required this.onNeedHelpPressed,
  });

  final InterviewState state;
  final AiAvatarController avatarController;
  final bool hasTranscript;
  final VoidCallback onEndInterviewPressed;
  final VoidCallback onShowTranscript;
  final VoidCallback onRetryListening;
  final VoidCallback onMicPressStart;
  final VoidCallback onMicPressEnd;
  final VoidCallback onNeedHelpPressed;

  static const _avatarSize = 200.0;
  static const _hatSize = 80.0;

  /// MdAiAvatar centers its `_avatarSize x _avatarSize` character art inside
  /// a larger `_avatarSize * 1.5` bounding box (extra room for the pulsing
  /// listen ring), so the hat has to be anchored to that *inner* art box's
  /// top, not the outer one — anchoring to the outer box (as before) left it
  /// floating well above the actual head. `_headOverlap` is a best-effort
  /// estimate of how far down the rig's head starts within its own art box
  /// — nudge it if the hat looks off once seen against the real rig on a
  /// device (this repo can't render the `.riv` file to check pixel-exact
  /// placement).
  static const _headOverlap = _avatarSize * 0.50;
  static double get _innerArtTop => (_avatarSize * 1.5 - _avatarSize) / 2;
  static double get _hatTopOffset => _innerArtTop + _headOverlap - _hatSize * 0.85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: state.status == InterviewStatus.error && state.failure != null
            ? MdErrorState(message: state.failure!.message, onRetry: onRetryListening)
            : Column(
                children: [
                  _TopBar(
                    state: state,
                    hasTranscript: hasTranscript,
                    onEndInterviewPressed: onEndInterviewPressed,
                    onShowTranscript: onShowTranscript,
                  ),
                  Expanded(
                    // A LayoutBuilder + scroll view instead of a bare Center:
                    // this content's height (avatar + question text + status
                    // line) is fixed, but the space available for it isn't —
                    // a shorter screen, a longer question that wraps to more
                    // lines, or system font scaling can all push the total
                    // past what fits, which a bare Center silently overflows
                    // (the "overflowed by N pixels" banner). Centered when it
                    // fits, scrollable instead of clipped/erroring when it
                    // doesn't.
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.topCenter,
                                    clipBehavior: Clip.none,
                                    children: [
                                      MdAiAvatar(controller: avatarController, size: _avatarSize),
                                      if (state.configuration != null)
                                        Positioned(
                                          top: _hatTopOffset,
                                          child: MdCountryHat(
                                            country: state.configuration!.country,
                                            size: _hatSize,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),
                                  _QuestionOrTranscript(state: state),
                                  const SizedBox(height: AppSpacing.xl),
                                  _StatusIndicator(state: state),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _BottomBar(
                    state: state,
                    onMicPressStart: onMicPressStart,
                    onMicPressEnd: onMicPressEnd,
                    onNeedHelpPressed: onNeedHelpPressed,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.state,
    required this.hasTranscript,
    required this.onEndInterviewPressed,
    required this.onShowTranscript,
  });

  final InterviewState state;
  final bool hasTranscript;
  final VoidCallback onEndInterviewPressed;
  final VoidCallback onShowTranscript;

  @override
  Widget build(BuildContext context) {
    final minutes = state.remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (state.remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            tooltip: 'End interview',
            onPressed: onEndInterviewPressed,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: Colors.white54),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  color: Colors.white70,
                  fontVariations: [FontVariation('wght', 600)],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (hasTranscript)
            IconButton(
              icon: const Icon(Icons.description_rounded, color: Colors.white70),
              tooltip: 'Transcript',
              onPressed: onShowTranscript,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _QuestionOrTranscript extends StatelessWidget {
  const _QuestionOrTranscript({required this.state});
  final InterviewState state;

  @override
  Widget build(BuildContext context) {
    final showLiveTranscript =
        state.status == InterviewStatus.userSpeaking && state.liveTranscript.isNotEmpty;

    final text = showLiveTranscript ? state.liveTranscript : (state.currentQuestion?.text ?? '');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Padding(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: showLiveTranscript ? Colors.white70 : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.35,
            fontStyle: showLiveTranscript ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.state});
  final InterviewState state;

  static const _loadingStatuses = {
    InterviewStatus.preparing,
    InterviewStatus.aiThinking,
    InterviewStatus.processingAnswer,
    InterviewStatus.generatingFeedback,
  };

  @override
  Widget build(BuildContext context) {
    // Only animate while audio is actually happening (AI speaking or the
    // user actively recording) — not while idle and waiting for a press.
    final showWaveform =
        state.status == InterviewStatus.aiSpeaking || state.status == InterviewStatus.userSpeaking;
    // Everything else where the app is silently waiting on the AI (starting
    // up, thinking, scoring) gets a spinner instead of just static text —
    // otherwise those waits read as the screen being stuck rather than busy.
    final showSpinner = _loadingStatuses.contains(state.status);

    return Column(
      children: [
        if (showWaveform)
          MdVoiceWaveform(
            amplitude: state.amplitude,
            color: state.status == InterviewStatus.aiSpeaking
                ? AppColors.speaking
                : AppColors.listening,
          ),
        if (showSpinner)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryLight),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(_labelFor(state.status), style: const TextStyle(color: Colors.white54, fontSize: 13)),
        if (state.configuration != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Question ${state.questionNumber.clamp(1, 999)} of ~${state.estimatedTotalQuestions}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ],
    );
  }

  String _labelFor(InterviewStatus status) {
    switch (status) {
      case InterviewStatus.preparing:
        return 'Preparing your interview…';
      case InterviewStatus.aiThinking:
        return 'AI is thinking…';
      case InterviewStatus.aiSpeaking:
        return 'AI is speaking';
      case InterviewStatus.listening:
        return 'Hold the mic to answer';
      case InterviewStatus.userSpeaking:
        return 'Listening…';
      case InterviewStatus.processingAnswer:
        return 'Analyzing your answer…';
      case InterviewStatus.generatingFeedback:
        return 'Preparing your feedback…';
      default:
        return '';
    }
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.state,
    required this.onMicPressStart,
    required this.onMicPressEnd,
    required this.onNeedHelpPressed,
  });

  final InterviewState state;
  final VoidCallback onMicPressStart;
  final VoidCallback onMicPressEnd;
  final VoidCallback onNeedHelpPressed;

  @override
  Widget build(BuildContext context) {
    // Ready to record (waiting for a press) or actively recording (pressed).
    final isReady = state.status == InterviewStatus.listening;
    final isRecording = state.status == InterviewStatus.userSpeaking;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Only offered while the mic is idle waiting for a press (spec
          // section 4, Mode B) — never mid-answer, and never auto-shown.
          if (isReady)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: TextButton.icon(
                onPressed: onNeedHelpPressed,
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Colors.white70),
                label: const Text('I need help answering', style: TextStyle(color: Colors.white70)),
              ),
            ),
          MdPushToTalkMic(
            isReady: isReady,
            isRecording: isRecording,
            onPressStart: onMicPressStart,
            onPressEnd: onMicPressEnd,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
