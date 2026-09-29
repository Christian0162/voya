import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';

import 'fallback_answer_guidance_service.dart';
import 'gemini_answer_guidance_service.dart';
import 'gemini_config.dart';
import 'mock_answer_guidance_service.dart';

/// Picks the real Gemini-backed Answer Coach when a `GEMINI_API_KEY` is
/// supplied, and falls back to the local rule-based
/// [MockAnswerGuidanceService] otherwise — mirrors [AiServiceFactory].
///
/// See [GeminiConfig] for where the API key/model come from.
class AnswerGuidanceServiceFactory {
  const AnswerGuidanceServiceFactory._();

  static AnswerGuidanceService create() {
    if (GeminiConfig.apiKey.isEmpty) return MockAnswerGuidanceService();
    return FallbackAnswerGuidanceService(
      primary: GeminiAnswerGuidanceService(apiKey: GeminiConfig.apiKey, model: GeminiConfig.model),
      fallback: MockAnswerGuidanceService(),
    );
  }
}
