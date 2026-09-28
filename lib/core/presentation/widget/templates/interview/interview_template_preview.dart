import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';
import 'package:voya/core/domain/interview/entities/interview_question.dart';
import 'package:voya/core/presentation/bloc/interview/interview_state.dart';
import 'package:voya/core/presentation/bloc/interview/interview_status.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/ai_avatar_controller.dart';
import 'package:voya/core/presentation/widget/organisms/ai_avatar/ai_avatar_state.dart';

import 'interview_template.dart';

class InterviewTemplatePreview extends StatelessWidget {
  const InterviewTemplatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final state = InterviewState(
      status: InterviewStatus.aiSpeaking,
      currentQuestion: const InterviewQuestion(
        id: 'q0',
        text: 'Tell me a little about yourself.',
        kind: QuestionKind.opening,
        order: 0,
      ),
      amplitude: 0.6,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      home: InterviewTemplate(
        state: state,
        avatarController: AiAvatarController()..setState(AiAvatarState.speaking),
        hasTranscript: false,
        onEndInterviewPressed: () {},
        onShowTranscript: () {},
        onRetryListening: () {},
      ),
    );
  }
}
