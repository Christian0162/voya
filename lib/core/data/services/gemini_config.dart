import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Shared Gemini API key/model resolution, used by every factory that picks
/// between a Gemini-backed service and its offline mock fallback
/// ([AiServiceFactory], [AnswerGuidanceServiceFactory]).
///
/// The key can come from either source (checked in this order):
///
/// 1. A local `.env` file (copy `.env.example` to `.env` and fill it in —
///    `.env` is gitignored, loaded once in `main.dart` via `flutter_dotenv`).
///    The easiest option for day-to-day local testing.
/// 2. `--dart-define=GEMINI_API_KEY=...` at run/build time — never written
///    to disk, so nothing to accidentally commit; better for CI/sharing a
///    run command without a local file.
///
/// Model defaults to `gemini-3.8-flash`; override via `GEMINI_MODEL` in
/// either source the same way.
class GeminiConfig {
  const GeminiConfig._();

  static const _defineApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _defineModel = String.fromEnvironment('GEMINI_MODEL');

  // dotenv.maybeGet throws NotInitializedError if `.load()` was never
  // called (e.g. in tests, which never run main.dart) — isInitialized guards
  // that instead of leaving it to throw past this factory.
  static String? _dotenvGet(String key) => dotenv.isInitialized ? dotenv.maybeGet(key) : null;

  static String get apiKey => _firstNonEmpty([_dotenvGet('GEMINI_API_KEY'), _defineApiKey]);

  static String get model =>
      _firstNonEmpty([_dotenvGet('GEMINI_MODEL'), _defineModel, 'gemini-3.8-flash']);

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }
}
