import 'package:voya/core/domain/interview/services/ai_interview_service.dart';

import 'fallback_ai_interview_service.dart';
import 'gemini_ai_interview_service.dart';
import 'gemini_config.dart';
import 'mock_ai_interview_service.dart';

/// Picks the real Gemini-backed interviewer when a `GEMINI_API_KEY` is
/// supplied, and falls back to the local rule-based [MockAIInterviewService]
/// otherwise — the app stays fully usable offline with no key required.
/// When Gemini *is* configured, it's still wrapped in
/// [FallbackAIInterviewService] so a provider outage (rate limit, 503,
/// network blip) drops back to the offline interviewer mid-session instead
/// of ending the interview with an error screen.
///
/// See [GeminiConfig] for where the API key/model come from.
class AiServiceFactory {
  const AiServiceFactory._();

  static AIInterviewService create() {
    if (GeminiConfig.apiKey.isEmpty) return MockAIInterviewService();
    return FallbackAIInterviewService(
      primary: GeminiAIInterviewService(apiKey: GeminiConfig.apiKey, model: GeminiConfig.model),
      fallback: MockAIInterviewService(),
    );
  }
}
