import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/core/presentation/bloc/interview/interview_bloc.dart';
import 'package:voya/core/presentation/bloc/interview/interview_event.dart';
import 'package:voya/core/presentation/bloc/interview/interview_state.dart';
import 'package:voya/core/presentation/bloc/interview/interview_status.dart';
import 'package:voya/core/presentation/types/interview_results/interview_result_args.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/ai_avatar_controller.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/ai_avatar_state.dart';
import 'package:voya/core/presentation/widget/organisms/md_interview_transcript_sheet.dart';
import 'package:voya/core/presentation/widget/templates/interview/interview_template.dart';

/// The most important screen in the product (spec section 15/41): the AI
/// speaks, the avatar animates, then the app listens — the user should
/// rarely need to touch the screen at all during a healthy conversation.
///
/// Logic only: watches [InterviewBloc], drives the avatar controller,
/// navigates on completion, and owns the dialog/sheet interactions the
/// template itself never touches. All rendering lives in [InterviewTemplate].
class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final _avatarController = AiAvatarController();

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  AiAvatarState _avatarStateFor(InterviewStatus status) {
    switch (status) {
      case InterviewStatus.initial:
      case InterviewStatus.preparing:
        return AiAvatarState.idle;
      case InterviewStatus.aiThinking:
      case InterviewStatus.generatingFeedback:
        return AiAvatarState.thinking;
      case InterviewStatus.aiSpeaking:
        return AiAvatarState.speaking;
      case InterviewStatus.listening:
      case InterviewStatus.userSpeaking:
        return AiAvatarState.listening;
      case InterviewStatus.processingAnswer:
        return AiAvatarState.processing;
      case InterviewStatus.completed:
      case InterviewStatus.error:
        return AiAvatarState.idle;
    }
  }

  void _confirmEnd(BuildContext context) {
    final bloc = context.read<InterviewBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End this interview?'),
        content: const Text("You'll get feedback based on the questions you've already answered."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(const EndInterviewRequested());
            },
            child: const Text('End Interview'),
          ),
        ],
      ),
    );
  }

  void _showTranscript(BuildContext context, InterviewState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      builder: (_) => MdInterviewTranscriptSheet(turns: state.turns),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InterviewBloc, InterviewState>(
      listener: (context, state) {
        _avatarController.setState(_avatarStateFor(state.status));
        if (state.status == InterviewStatus.aiSpeaking ||
            state.status == InterviewStatus.listening ||
            state.status == InterviewStatus.userSpeaking) {
          _avatarController.setAmplitude(state.amplitude);
        }
        if (state.status == InterviewStatus.completed && state.result != null) {
          context.pushReplacement(
            '/interview/result/${state.sessionId}',
            extra: InterviewResultArgs(
              result: state.result!,
              configuration: state.configuration!,
              turns: state.turns,
            ),
          );
        }
      },
      builder: (context, state) {
        return InterviewTemplate(
          state: state,
          avatarController: _avatarController,
          hasTranscript: state.turns.isNotEmpty,
          onEndInterviewPressed: () => _confirmEnd(context),
          onShowTranscript: () => _showTranscript(context, state),
          onRetryListening: () => context.read<InterviewBloc>().add(const RetryListeningRequested()),
        );
      },
    );
  }
}
