import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voya/core/error/failure.dart';
import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';

import 'answer_guide_event.dart';
import 'answer_guide_state.dart';

/// Loads the [AnswerGuide] for a single [GuidanceQuestion]. Deliberately
/// simple — one request, no multi-turn state — unlike [InterviewBloc].
class AnswerGuideBloc extends Bloc<AnswerGuideEvent, AnswerGuideState> {
  AnswerGuideBloc({required AnswerGuidanceService service})
    : _service = service, // ignore: prefer_initializing_formals
      super(const AnswerGuideState()) {
    on<GuideRequested>(_onGuideRequested);
  }

  final AnswerGuidanceService _service;

  Future<void> _onGuideRequested(GuideRequested event, Emitter<AnswerGuideState> emit) async {
    emit(
      state.copyWith(
        status: AnswerGuideStatus.loading,
        question: event.question,
        clearFailure: true,
      ),
    );
    try {
      final guide = await _service.generateGuide(event.question);
      emit(state.copyWith(status: AnswerGuideStatus.loaded, guide: guide));
    } catch (e) {
      emit(
        state.copyWith(status: AnswerGuideStatus.error, failure: AiProviderFailure(e.toString())),
      );
    }
  }
}
