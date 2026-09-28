import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_colors.dart';

/// Shared color tiering for a 0.0-1.0 score — used by result metrics and
/// history/recent-practice tiles so the same score always reads as the same
/// color everywhere.
Color colorForScore(double value) {
  if (value >= 0.75) return AppColors.success;
  if (value >= 0.5) return AppColors.warning;
  return AppColors.error;
}
