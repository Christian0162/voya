/// App-wide, non-visual constants.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Voya';
  static const String tagline = 'Practice the interview before the real one.';

  /// Keep in sync with the `version:` field in pubspec.yaml.
  static const String appVersion = '1.0.0';

  /// Filler words the local speaking-analysis heuristic looks for.
  /// Kept lowercase; matching is case-insensitive.
  static const List<String> fillerWords = [
    'um',
    'uh',
    'like',
    'you know',
    'basically',
    'actually',
    'literally',
    'kind of',
    'sort of',
  ];

  static const int defaultInterviewLengthMinutes = 10;
  static const List<int> selectableLengthsMinutes = [5, 10, 15];

  /// Silence gap (ms) after speech that ends a user turn.
  static const int endOfSpeechSilenceMs = 1600;
}
