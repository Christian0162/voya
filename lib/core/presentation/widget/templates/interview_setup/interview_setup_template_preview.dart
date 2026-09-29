import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';

import 'interview_setup_template.dart';

class InterviewSetupTemplatePreview extends StatefulWidget {
  const InterviewSetupTemplatePreview({super.key});

  @override
  State<InterviewSetupTemplatePreview> createState() => _InterviewSetupTemplatePreviewState();
}

class _InterviewSetupTemplatePreviewState extends State<InterviewSetupTemplatePreview> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: InterviewSetupTemplate(
        pageController: _pageController,
        step: 0,
        stepCount: 4,
        country: null,
        purpose: null,
        difficulty: null,
        duration: 10,
        canContinue: false,
        isStarting: false,
        onCountrySelected: (_) {},
        onPurposeSelected: (_) {},
        onDifficultySelected: (_) {},
        onDurationSelected: (_) {},
        onBack: () {},
        onNext: () {},
      ),
    );
  }
}
