import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';
import 'package:voya/core/presentation/widget/atoms/md_primary_button.dart';
import 'package:voya/core/presentation/widget/molecules/md_country_selector.dart';
import 'package:voya/core/presentation/widget/molecules/md_difficulty_selector.dart';
import 'package:voya/core/presentation/widget/molecules/md_duration_selector.dart';
import 'package:voya/core/presentation/widget/molecules/md_purpose_selector.dart';
import 'package:voya/core/presentation/widget/molecules/md_setup_step_header.dart';

/// Pure layout for the four-step setup wizard (spec section 14). All wizard
/// state (current step, selections) lives in the Screen; this widget only
/// renders what it's given and reports taps back through callbacks.
class InterviewSetupTemplate extends StatelessWidget {
  const InterviewSetupTemplate({
    super.key,
    required this.pageController,
    required this.step,
    required this.stepCount,
    required this.country,
    required this.purpose,
    required this.difficulty,
    required this.duration,
    required this.canContinue,
    required this.onCountrySelected,
    required this.onPurposeSelected,
    required this.onDifficultySelected,
    required this.onDurationSelected,
    required this.onBack,
    required this.onNext,
  });

  final PageController pageController;
  final int step;
  final int stepCount;
  final Country? country;
  final InterviewPurpose? purpose;
  final InterviewDifficulty? difficulty;
  final int duration;
  final bool canContinue;
  final ValueChanged<Country> onCountrySelected;
  final ValueChanged<InterviewPurpose> onPurposeSelected;
  final ValueChanged<InterviewDifficulty> onDifficultySelected;
  final ValueChanged<int> onDurationSelected;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLastStep = step == stepCount - 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep(
                    title: 'Choose your destination',
                    subtitle: 'Which country is this interview for?',
                    child: MdCountrySelector(selected: country, onSelected: onCountrySelected),
                  ),
                  _buildStep(
                    title: 'What is the purpose?',
                    subtitle: 'This shapes the questions you will practice.',
                    child: MdPurposeSelector(selected: purpose, onSelected: onPurposeSelected),
                  ),
                  _buildStep(
                    title: 'Choose a difficulty',
                    subtitle: 'You can change this any time in your next practice.',
                    child: MdDifficultySelector(
                      selected: difficulty,
                      onSelected: onDifficultySelected,
                    ),
                  ),
                  _buildStep(
                    title: 'How long should it be?',
                    subtitle: 'Longer interviews cover more follow-up questions.',
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: MdDurationSelector(selected: duration, onSelected: onDurationSelected),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: MdPrimaryButton(
                label: isLastStep ? 'Start Interview' : 'Continue',
                onPressed: canContinue ? onNext : null,
                icon: isLastStep ? Icons.mic_rounded : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required String title, required String subtitle, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MdSetupStepHeader(
            title: title,
            subtitle: subtitle,
            stepIndex: step,
            stepCount: stepCount,
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: child),
        ],
      ),
    );
  }
}
