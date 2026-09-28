import 'package:flutter/material.dart';

import 'package:voya/config/constant/app_constants.dart';
import 'package:voya/config/constant/app_theme.dart';
import 'package:voya/config/routes/app_router.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';

class VoyaApp extends StatelessWidget {
  const VoyaApp({super.key, required this.repository});

  final InterviewRepository repository;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(repository).router;
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
