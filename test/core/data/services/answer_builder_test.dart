import 'package:flutter_test/flutter_test.dart';
import 'package:voya/core/data/services/answer_builder.dart';

void main() {
  group('AnswerBuilder', () {
    test('counts filler words case-insensitively and word-bounded', () {
      final answer = AnswerBuilder.build(
        questionId: 'q1',
        transcript: 'Um, I think, like, I have, um, five years of experience.',
        spokenDuration: const Duration(seconds: 10),
      );

      expect(answer.fillerWordCounts['um'], 2);
      expect(answer.fillerWordCounts['like'], 1);
      expect(answer.wordCount, 11);
    });

    test('does not match filler words inside other words', () {
      final answer = AnswerBuilder.build(
        questionId: 'q1',
        transcript: 'I actually like actuality and likeable things.',
        spokenDuration: const Duration(seconds: 5),
      );

      // "actually" and "like" are real standalone words here, but
      // "actuality" and "likeable" must not be double-counted.
      expect(answer.fillerWordCounts['actually'], 1);
      expect(answer.fillerWordCounts['like'], 1);
    });

    test('empty transcript produces zero word count and no fillers', () {
      final answer = AnswerBuilder.build(
        questionId: 'q1',
        transcript: '   ',
        spokenDuration: Duration.zero,
      );

      expect(answer.wordCount, 0);
      expect(answer.fillerWordCounts, isEmpty);
      expect(answer.wordsPerMinute, 0);
    });
  });
}
