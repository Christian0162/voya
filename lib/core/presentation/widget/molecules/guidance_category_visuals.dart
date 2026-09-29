import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';

/// Shared icon/color mapping for [GuidanceCategory] — same role as
/// [iconForPurpose]/[colorForPurpose] for [InterviewPurpose]: one mapping so
/// a category reads as the same color everywhere it appears.
IconData iconForGuidanceCategory(GuidanceCategory category) {
  switch (category) {
    case GuidanceCategory.travelPurpose:
      return Icons.flight_takeoff_rounded;
    case GuidanceCategory.personalBackground:
      return Icons.person_outline_rounded;
    case GuidanceCategory.employmentEducation:
      return Icons.work_outline_rounded;
    case GuidanceCategory.financialArrangements:
      return Icons.account_balance_wallet_outlined;
    case GuidanceCategory.accommodationAndTravelPlans:
      return Icons.house_outlined;
    case GuidanceCategory.durationOfStay:
      return Icons.calendar_month_outlined;
    case GuidanceCategory.familyConnections:
      return Icons.groups_outlined;
    case GuidanceCategory.followUpClarification:
      return Icons.forum_outlined;
    case GuidanceCategory.general:
      return Icons.lightbulb_outline_rounded;
  }
}

Color colorForGuidanceCategory(GuidanceCategory category) {
  switch (category) {
    case GuidanceCategory.travelPurpose:
      return AppColors.primary;
    case GuidanceCategory.personalBackground:
      return AppColors.accent;
    case GuidanceCategory.employmentEducation:
      return AppColors.info;
    case GuidanceCategory.financialArrangements:
      return AppColors.success;
    case GuidanceCategory.accommodationAndTravelPlans:
      return AppColors.warning;
    case GuidanceCategory.durationOfStay:
      return const Color(0xFFEC4899); // pink-500, same rotating accent as MdCountryHat.
    case GuidanceCategory.familyConnections:
      return AppColors.info;
    case GuidanceCategory.followUpClarification:
      return AppColors.accent;
    case GuidanceCategory.general:
      return AppColors.primary;
  }
}
