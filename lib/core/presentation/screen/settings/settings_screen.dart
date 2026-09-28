import 'package:flutter/material.dart';

import 'package:voya/core/data/services/microphone_permission.dart';
import 'package:voya/core/presentation/widget/templates/settings/settings_template.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTemplate(onOpenMicrophoneSettings: MicrophonePermission.openSettings);
  }
}
