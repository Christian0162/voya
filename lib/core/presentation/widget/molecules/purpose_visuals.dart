import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_purpose.dart';

/// Shared icon/color mapping for [InterviewPurpose] — used by the purpose
/// selector and by anywhere else a purpose needs a visual (recent-practice
/// tiles, history), so the same purpose always reads as the same color
/// throughout the app instead of each screen inventing its own mapping.
IconData iconForPurpose(InterviewPurpose purpose) {
  switch (purpose) {
    case InterviewPurpose.work:
      return Icons.work_rounded;
    case InterviewPurpose.study:
      return Icons.school_rounded;
    case InterviewPurpose.visitor:
      return Icons.flight_rounded;
    case InterviewPurpose.immigration:
      return Icons.verified_rounded;
    case InterviewPurpose.recruitment:
      return Icons.groups_rounded;
  }
}

Color colorForPurpose(InterviewPurpose purpose) {
  switch (purpose) {
    case InterviewPurpose.work:
      return AppColors.primary;
    case InterviewPurpose.study:
      return AppColors.accent;
    case InterviewPurpose.visitor:
      return AppColors.info;
    case InterviewPurpose.immigration:
      return AppColors.success;
    case InterviewPurpose.recruitment:
      return AppColors.warning;
  }
}
