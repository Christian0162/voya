import 'package:flutter/material.dart';

import 'package:voya/core/domain/interview_setup/entities/country.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_difficulty.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';
import 'package:voya/core/presentation/widget/templates/interview_setup/interview_setup_template.dart';

/// The four-step setup wizard's logic (spec section 14). Local widget state
/// is enough here — this is a linear form, not a feature with its own
/// async/business logic, so a bloc would be pure ceremony (spec section 39:
/// don't overengineer the MVP).
class InterviewSetupScreen extends StatefulWidget {
  const InterviewSetupScreen({super.key, required this.onConfigured});

  final ValueChanged<InterviewConfiguration> onConfigured;

  @override
  State<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends State<InterviewSetupScreen> {
  final _pageController = PageController();
  int _step = 0;

  Country? _country;
  InterviewPurpose? _purpose;
  InterviewDifficulty? _difficulty;
  int _duration = 10;

  // True for the brief window between tapping "Start Interview" and the
  // route transition to the interview screen actually landing — without it,
  // that tap gave no feedback at all and felt like it hadn't registered.
  bool _isStarting = false;

  static const _stepCount = 4;

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _country != null;
      case 1:
        return _purpose != null;
      case 2:
        return _difficulty != null;
      default:
        return true;
    }
  }

  void _next() {
    if (_step == _stepCount - 1) {
      if (_isStarting) return; // ignore a double-tap while already starting
      setState(() => _isStarting = true);
      widget.onConfigured(
        InterviewConfiguration(
          country: _country!,
          purpose: _purpose!,
          difficulty: _difficulty!,
          durationMinutes: _duration,
        ),
      );
      return;
    }
    setState(() => _step += 1);
    _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step -= 1);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InterviewSetupTemplate(
      pageController: _pageController,
      step: _step,
      stepCount: _stepCount,
      country: _country,
      purpose: _purpose,
      difficulty: _difficulty,
      duration: _duration,
      canContinue: _canContinue,
      isStarting: _isStarting,
      onCountrySelected: (c) => setState(() => _country = c),
      onPurposeSelected: (p) => setState(() => _purpose = p),
      onDifficultySelected: (d) => setState(() => _difficulty = d),
      onDurationSelected: (d) => setState(() => _duration = d),
      onBack: _back,
      onNext: _next,
    );
  }
}
