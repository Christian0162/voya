import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voya/core/domain/answer_guidance/entities/answer_guide.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_category.dart';
import 'package:voya/core/domain/answer_guidance/entities/guidance_question.dart';
import 'package:voya/core/domain/answer_guidance/services/answer_guidance_service.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_bloc.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_event.dart';
import 'package:voya/core/presentation/bloc/answer_guide/answer_guide_state.dart';

class _MockAnswerGuidanceService extends Mock implements AnswerGuidanceService {}

void main() {
  late _MockAnswerGuidanceService service;

  const question = GuidanceQuestion(
    id: 'travelPurpose_0',
    text: 'What is the purpose of your visit?',
    category: GuidanceCategory.travelPurpose,
  );

  const guide = AnswerGuide(
    questionExplanation: 'explanation',
    interviewerIntent: 'intent',
    answerStructure: ['step 1', 'step 2'],
    exampleAnswer: 'example',
    commonMistakes: ['mistake 1'],
    practiceTip: 'tip',
  );

  setUpAll(() {
    registerFallbackValue(question);
  });

  setUp(() {
    service = _MockAnswerGuidanceService();
  });

  blocTest<AnswerGuideBloc, AnswerGuideState>(
    'emits loading then loaded when the guide is generated successfully',
    setUp: () {
      when(() => service.generateGuide(question)).thenAnswer((_) async => guide);
    },
    build: () => AnswerGuideBloc(service: service),
    act: (bloc) => bloc.add(const GuideRequested(question)),
    expect: () => [
      const AnswerGuideState(status: AnswerGuideStatus.loading, question: question),
      const AnswerGuideState(status: AnswerGuideStatus.loaded, question: question, guide: guide),
    ],
  );

  blocTest<AnswerGuideBloc, AnswerGuideState>(
    'emits an error state when the service throws',
    setUp: () {
      when(() => service.generateGuide(question)).thenThrow(Exception('network down'));
    },
    build: () => AnswerGuideBloc(service: service),
    act: (bloc) => bloc.add(const GuideRequested(question)),
    expect: () => [
      const AnswerGuideState(status: AnswerGuideStatus.loading, question: question),
      predicate<AnswerGuideState>((s) => s.status == AnswerGuideStatus.error && s.failure != null),
    ],
  );
}
