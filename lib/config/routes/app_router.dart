import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:voya/core/data/services/ai_service_factory.dart';
import 'package:voya/core/data/services/answer_guidance_service_factory.dart';
import 'package:voya/core/data/services/speech_to_text_service_impl.dart';
import 'package:voya/core/data/services/text_to_speech_service_impl.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/domain/interview/repositories/interview_repository.dart';
import 'package:voya/core/domain/interview_setup/entities/interview_configuration.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_bloc.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_event.dart';
import 'package:voya/core/presentation/bloc/auth/auth_cubit.dart';
import 'package:voya/core/presentation/bloc/auth/auth_state.dart';
import 'package:voya/core/presentation/bloc/interview/interview_bloc.dart';
import 'package:voya/core/presentation/bloc/interview/interview_event.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_bloc.dart';
import 'package:voya/core/presentation/bloc/practice_answer/practice_answer_event.dart';
import 'package:voya/core/presentation/screen/answer_guidance/answer_guide_screen.dart';
import 'package:voya/core/presentation/screen/answer_guidance/practice_answer_screen.dart';
import 'package:voya/core/presentation/screen/answer_guidance/question_library_screen.dart';
import 'package:voya/core/presentation/screen/auth/sign_in_screen.dart';
import 'package:voya/core/presentation/screen/auth/sign_up_screen.dart';
import 'package:voya/core/presentation/screen/history/history_screen.dart';
import 'package:voya/core/presentation/screen/home/home_screen.dart';
import 'package:voya/core/presentation/screen/interview/interview_screen.dart';
import 'package:voya/core/presentation/screen/interview_results/interview_result_screen.dart';
import 'package:voya/core/presentation/screen/interview_setup/interview_setup_screen.dart';
import 'package:voya/core/presentation/screen/profile/edit_profile_screen.dart';
import 'package:voya/core/presentation/screen/profile/profile_screen.dart';
import 'package:voya/core/presentation/screen/settings/settings_screen.dart';
import 'package:voya/core/presentation/types/answer_guidance/practice_args.dart';
import 'package:voya/core/presentation/types/interview_results/interview_result_args.dart';

import 'app_shell.dart';
import 'go_router_refresh_stream.dart';

/// All navigation lives here (spec section 24). Routes for the three
/// persistent tabs live inside a [StatefulShellRoute] so switching tabs
/// preserves each tab's scroll/future state; the interview flow is a plain
/// stack of full-screen routes with no bottom nav. Everything is gated
/// behind sign-in via [_redirect]/[GoRouterRefreshStream] — signing out from
/// anywhere bounces the whole app back to `/sign-in` automatically.
class AppRouter {
  AppRouter(this.repository, this.authCubit);

  final InterviewRepository repository;
  final AuthCubit authCubit;

  static const _authRoutes = {'/sign-in', '/sign-up'};

  String? _redirect(BuildContext context, GoRouterState state) {
    final status = authCubit.state.status;
    // Still waiting on the first auth event — don't redirect yet, or a
    // signed-in user would flash the sign-in screen on cold start.
    if (status == AuthStatus.unknown) return null;

    final isAuthRoute = _authRoutes.contains(state.matchedLocation);
    if (status == AuthStatus.unauthenticated && !isAuthRoute) return '/sign-in';
    if (status == AuthStatus.authenticated && isAuthRoute) return '/home';
    return null;
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: _redirect,
    routes: [
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
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
              aiService: AiServiceFactory.create(),
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
      GoRoute(path: '/answer-guidance', builder: (context, state) => const QuestionLibraryScreen()),
      GoRoute(
        path: '/answer-guidance/guide',
        builder: (context, state) {
          final question = state.extra as GuidanceQuestion;
          return BlocProvider(
            create: (_) =>
                AnswerGuideBloc(service: AnswerGuidanceServiceFactory.create())
                  ..add(GuideRequested(question)),
            child: AnswerGuideScreen(question: question),
          );
        },
      ),
      GoRoute(
        path: '/answer-guidance/practice',
        builder: (context, state) {
          final args = state.extra as PracticeArgs;
          return BlocProvider(
            create: (_) => PracticeAnswerBloc(
              guidanceService: AnswerGuidanceServiceFactory.create(),
              speechToTextService: SpeechToTextServiceImpl(),
              textToSpeechService: TextToSpeechServiceImpl(),
            )..add(PracticeStarted(question: args.question, guide: args.guide)),
            child: const PracticeAnswerScreen(),
          );
        },
      ),
    ],
  );
}
