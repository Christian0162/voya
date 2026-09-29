import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_feedback.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_bloc.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_event.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_state.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_status.dart';
import 'package:voya/core/presentation/widget/atoms/md_primary_button.dart';
import 'package:voya/core/presentation/widget/molecules/md_card.dart';
import 'package:voya/core/presentation/widget/molecules/md_error_state.dart';
import 'package:voya/core/presentation/widget/molecules/md_result_metric.dart';
import 'package:voya/core/presentation/widget/molecules/md_voice_waveform.dart';
import 'package:voya/core/presentation/widget/organisms/md_push_to_talk_mic.dart';

/// Practice one guidance question aloud (spec section 2): the question is
/// read out, the user holds the mic to answer (push-to-talk, same model as
/// the live mock interview), then AI feedback is shown with a retry option.
class PracticeAnswerScreen extends StatelessWidget {
  const PracticeAnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: BlocBuilder<PracticeAnswerBloc, PracticeAnswerState>(
          builder: (context, state) {
            if (state.status == PracticeAnswerStatus.error && state.failure != null) {
              return MdErrorState(
                message: state.failure!.message,
                onRetry: () => context.read<PracticeAnswerBloc>().add(const RetryRequested()),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      const Text(
                        'PRACTICE',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      state.status == PracticeAnswerStatus.feedbackReady && state.feedback != null
                      ? _FeedbackView(feedback: state.feedback!)
                      : _AskingOrListeningView(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AskingOrListeningView extends StatelessWidget {
  const _AskingOrListeningView({required this.state});

  final PracticeAnswerState state;

  String _statusLabel() {
    switch (state.status) {
      case PracticeAnswerStatus.askingQuestion:
        return 'AI is asking the question';
      case PracticeAnswerStatus.listening:
        return 'Hold the mic to answer';
      case PracticeAnswerStatus.recording:
        return 'Listening…';
      case PracticeAnswerStatus.processingAnswer:
        return 'Analyzing your answer…';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final showWaveform =
        state.status == PracticeAnswerStatus.askingQuestion ||
        state.status == PracticeAnswerStatus.recording;
    final showSpinner = state.status == PracticeAnswerStatus.processingAnswer;
    final isReady = state.status == PracticeAnswerStatus.listening;
    final isRecording = state.status == PracticeAnswerStatus.recording;

    final showLiveTranscript = isRecording && state.liveTranscript.isNotEmpty;
    final text = showLiveTranscript ? state.liveTranscript : (state.question?.text ?? '');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Padding(
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
          ),
        ),
        if (showWaveform)
          MdVoiceWaveform(
            amplitude: state.amplitude,
            color: state.status == PracticeAnswerStatus.askingQuestion
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
        Text(_statusLabel(), style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: AppSpacing.xl),
        MdPushToTalkMic(
          isReady: isReady,
          isRecording: isRecording,
          onPressStart: () => context.read<PracticeAnswerBloc>().add(const MicPressStarted()),
          onPressEnd: () => context.read<PracticeAnswerBloc>().add(const MicPressStopped()),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _FeedbackView extends StatelessWidget {
  const _FeedbackView({required this.feedback});

  final AnswerFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Your Feedback',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: AppColors.textPrimaryDark),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        MdResultMetric(label: 'Relevance', value: feedback.relevance),
        MdResultMetric(label: 'Clarity', value: feedback.clarity),
        MdResultMetric(label: 'Completeness', value: feedback.completeness),
        MdResultMetric(label: 'Naturalness', value: feedback.naturalness),
        MdResultMetric(label: 'Consistency', value: feedback.consistency),
        const SizedBox(height: AppSpacing.sm),
        MdCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  feedback.feedbackText,
                  style: const TextStyle(color: AppColors.textPrimaryDark, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        if (feedback.improvedExample != null) ...[
          const SizedBox(height: AppSpacing.md),
          MdCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_fix_high_rounded, size: 18, color: AppColors.success),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Improved Example', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  feedback.improvedExample!,
                  style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        MdPrimaryButton(
          label: 'Retry This Question',
          icon: Icons.refresh_rounded,
          onPressed: () => context.read<PracticeAnswerBloc>().add(const RetryRequested()),
        ),
        const SizedBox(height: AppSpacing.md),
        MdPrimaryButton(
          label: 'Done',
          variant: MdButtonVariant.secondary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
