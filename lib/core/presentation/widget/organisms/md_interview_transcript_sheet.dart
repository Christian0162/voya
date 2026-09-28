import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/domain/interview/entities/interview_turn.dart';

/// Read-only transcript of the conversation so far (spec section 16) —
/// available on demand, never shown by default, so it doesn't compete with
/// the voice-first experience.
class MdInterviewTranscriptSheet extends StatelessWidget {
  const MdInterviewTranscriptSheet({super.key, required this.turns});

  final List<InterviewTurn> turns;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Transcript',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: turns.length,
                itemBuilder: (context, index) {
                  final turn = turns[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TranscriptBubble(
                          label: 'AI',
                          text: turn.question.text,
                          color: AppColors.primaryLight,
                        ),
                        if (turn.answer != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _TranscriptBubble(
                            label: 'YOU',
                            text: turn.answer!.transcript,
                            color: AppColors.listening,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  const _TranscriptBubble({required this.label, required this.text, required this.color});

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
      ],
    );
  }
}
