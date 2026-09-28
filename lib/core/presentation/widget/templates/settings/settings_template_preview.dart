import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';

import 'settings_template.dart';

class SettingsTemplatePreview extends StatelessWidget {
  const SettingsTemplatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: SettingsTemplate(onOpenMicrophoneSettings: () {}),
    );
  }
}
