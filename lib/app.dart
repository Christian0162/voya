import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:voya/config/constant/app_constants.dart';
import 'package:voya/config/constant/app_theme.dart';
import 'package:voya/config/routes/app_router.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/presentation/bloc/auth/auth_cubit.dart';
import 'package:voya/core/presentation/bloc/theme/theme_cubit.dart';

class VoyaApp extends StatelessWidget {
  const VoyaApp({
    super.key,
    required this.repository,
    required this.prefs,
    required this.authCubit,
  });

  final InterviewRepository repository;
  final SharedPreferences prefs;
  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(repository, authCubit).router;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefs)),
        BlocProvider.value(value: authCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
