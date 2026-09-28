import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/presentation/bloc/interview/interview_state.dart';
import 'package:voya/core/presentation/bloc/interview/interview_status.dart';
import 'package:voya/core/presentation/widget/molecules/md_error_state.dart';
import 'package:voya/core/presentation/widget/molecules/md_voice_waveform.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/ai_avatar_controller.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/md_ai_avatar.dart';

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
  });

  final InterviewState state;
  final AiAvatarController avatarController;
  final bool hasTranscript;
  final VoidCallback onEndInterviewPressed;
  final VoidCallback onShowTranscript;
  final VoidCallback onRetryListening;

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
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MdAiAvatar(controller: avatarController, size: 200),
                          const SizedBox(height: AppSpacing.xxl),
                          _QuestionOrTranscript(state: state),
                          const SizedBox(height: AppSpacing.xl),
                          _StatusIndicator(state: state),
                        ],
                      ),
                    ),
                  ),
                  _BottomBar(state: state),
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
                style: const TextStyle(color: Colors.white70, fontVariations: [FontVariation('wght', 600)]),
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

  @override
  Widget build(BuildContext context) {
    final showWaveform = state.status == InterviewStatus.aiSpeaking ||
        state.status == InterviewStatus.listening ||
        state.status == InterviewStatus.userSpeaking;

    return Column(
      children: [
        if (showWaveform)
          MdVoiceWaveform(
            amplitude: state.amplitude,
            color: state.status == InterviewStatus.aiSpeaking
                ? AppColors.speaking
                : AppColors.listening,
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
        return 'Speak naturally';
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
  const _BottomBar({required this.state});
  final InterviewState state;

  @override
  Widget build(BuildContext context) {
    final isListening =
        state.status == InterviewStatus.listening || state.status == InterviewStatus.userSpeaking;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl, top: AppSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening ? AppColors.listening.withValues(alpha: 0.15) : Colors.white10,
        ),
        child: Icon(
          isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
          color: isListening ? AppColors.listening : Colors.white38,
          size: 26,
        ),
      ),
    );
  }
}
