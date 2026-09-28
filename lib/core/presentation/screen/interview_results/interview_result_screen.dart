import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/core/presentation/types/interview_results/interview_result_args.dart';
import 'package:voya/core/presentation/widget/organisms/md_interview_transcript_sheet.dart';
import 'package:voya/core/presentation/widget/templates/interview_results/interview_result_template.dart';

class InterviewResultScreen extends StatelessWidget {
  const InterviewResultScreen({super.key, required this.args});

  final InterviewResultArgs args;

  void _showTranscript(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      builder: (_) => MdInterviewTranscriptSheet(turns: args.turns),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InterviewResultTemplate(
      args: args,
      hasTranscript: args.turns.isNotEmpty,
      onShowTranscript: () => _showTranscript(context),
      onPracticeAgain: () => context.go('/interview/setup'),
      onBackHome: () => context.go('/home'),
    );
  }
}
