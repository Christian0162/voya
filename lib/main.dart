import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:voya/app.dart';
import 'package:voya/core/data/repositories/supabase_auth_repository.dart';
import 'package:voya/core/data/repositories/supabase_interview_repository.dart';
import 'package:voya/core/data/services/supabase_config.dart';
import 'package:voya/core/presentation/bloc/auth/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional local secrets (GEMINI_API_KEY) — see AiServiceFactory. Missing
  // entirely is fine (a fresh clone with no .env yet); it just means the app
  // falls back to the offline mock interviewer.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Unlike GEMINI_API_KEY, Supabase isn't optional — the whole app is gated
  // behind sign-in, so fail with a clear message instead of a confusing
  // crash deep inside the auth flow.
  if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
    runApp(const _MissingSupabaseConfigApp());
    return;
  }

  // Required by the Rive 0.13.x runtime before loading any .riv file.
  await RiveFile.initialize();
  final prefs = await SharedPreferences.getInstance();
  await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.anonKey);

  final client = Supabase.instance.client;
  final authCubit = AuthCubit(SupabaseAuthRepository(client));

  runApp(
    VoyaApp(repository: SupabaseInterviewRepository(client), prefs: prefs, authCubit: authCubit),
  );
}

class _MissingSupabaseConfigApp extends StatelessWidget {
  const _MissingSupabaseConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Missing Supabase configuration.\n\n'
                'Add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file '
                '(see .env.example) and restart the app.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
