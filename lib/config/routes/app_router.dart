import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:voya/core/data/services/mock_ai_interview_service.dart';
import 'package:voya/core/data/services/speech_to_text_service_impl.dart';
import 'package:voya/core/data/services/text_to_speech_service_impl.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/presentation/bloc/interview/interview_bloc.dart';
import 'package:voya/core/presentation/bloc/interview/interview_event.dart';
import 'package:voya/core/presentation/screen/history/history_screen.dart';
import 'package:voya/core/presentation/screen/home/home_screen.dart';
import 'package:voya/core/presentation/screen/interview/interview_screen.dart';
import 'package:voya/core/presentation/screen/interview_results/interview_result_screen.dart';
import 'package:voya/core/presentation/screen/interview_setup/interview_setup_screen.dart';
import 'package:voya/core/presentation/screen/profile/profile_screen.dart';
import 'package:voya/core/presentation/screen/settings/settings_screen.dart';
import 'package:voya/core/presentation/types/interview_results/interview_result_args.dart';

import 'app_shell.dart';

/// All navigation lives here (spec section 24). Routes for the three
/// persistent tabs live inside a [StatefulShellRoute] so switching tabs
/// preserves each tab's scroll/future state; the interview flow is a plain
/// stack of full-screen routes with no bottom nav.
class AppRouter {
  AppRouter(this.repository);

  final InterviewRepository repository;

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => HomeScreen(repository: repository),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => HistoryScreen(repository: repository),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: '/interview/setup',
        builder: (context, state) => InterviewSetupScreen(
          onConfigured: (configuration) {
            final sessionId = const Uuid().v4();
            GoRouter.of(context)
                .pushReplacement('/interview/session/$sessionId', extra: configuration);
          },
        ),
      ),
      GoRoute(
        path: '/interview/session/:id',
        builder: (context, state) {
          final configuration = state.extra as InterviewConfiguration;
          return BlocProvider(
            create: (_) => InterviewBloc(
              aiService: MockAIInterviewService(),
              speechToTextService: SpeechToTextServiceImpl(),
              textToSpeechService: TextToSpeechServiceImpl(),
              repository: repository,
            )..add(StartInterviewRequested(configuration)),
            child: const InterviewScreen(),
          );
        },
      ),
      GoRoute(
        path: '/interview/result/:id',
        builder: (context, state) {
          final args = state.extra as InterviewResultArgs;
          return InterviewResultScreen(args: args);
        },
      ),
    ],
  );
}
