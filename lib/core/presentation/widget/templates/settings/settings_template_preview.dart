import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';

import 'settings_template.dart';

class SettingsTemplatePreview extends StatefulWidget {
  const SettingsTemplatePreview({super.key});

  @override
  State<SettingsTemplatePreview> createState() => _SettingsTemplatePreviewState();
}

class _SettingsTemplatePreviewState extends State<SettingsTemplatePreview> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: SettingsTemplate(
        onOpenMicrophoneSettings: () {},
        themeMode: _themeMode,
        onThemeModeSelected: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}
