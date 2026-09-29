import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase project URL/anon key resolution — same source order as
/// [GeminiConfig]: a local `.env` file first, then `--dart-define`. Unlike
/// the Gemini key, these are required (the app is gated behind auth), so
/// there's no "missing means offline mock" fallback here — see
/// `main.dart`, which fails fast with a clear message if either is empty.
class SupabaseConfig {
  const SupabaseConfig._();

  static const _defineUrl = String.fromEnvironment('SUPABASE_URL');
  static const _defineAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String? _dotenvGet(String key) => dotenv.isInitialized ? dotenv.maybeGet(key) : null;

  static String get url => _firstNonEmpty([_dotenvGet('SUPABASE_URL'), _defineUrl]);

  static String get anonKey => _firstNonEmpty([_dotenvGet('SUPABASE_ANON_KEY'), _defineAnonKey]);

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }
}
