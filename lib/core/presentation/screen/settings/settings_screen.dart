import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voya/core/data/services/microphone_permission.dart';
import 'package:voya/core/presentation/bloc/theme/theme_cubit.dart';
import 'package:voya/core/presentation/widget/templates/settings/settings_template.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    return SettingsTemplate(
      onOpenMicrophoneSettings: MicrophonePermission.openSettings,
      themeMode: themeMode,
      onThemeModeSelected: (mode) => context.read<ThemeCubit>().setMode(mode),
    );
  }
}
