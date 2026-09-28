import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_theme.dart';

import 'profile_template.dart';

class ProfileTemplatePreview extends StatelessWidget {
  const ProfileTemplatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: ProfileTemplate(onOpenSettings: () {}),
    );
  }
}
