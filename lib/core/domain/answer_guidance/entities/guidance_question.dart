import 'package:equatable/equatable.dart';

import 'guidance_category.dart';

/// A question in the browsable answer-guidance library (as opposed to
/// [InterviewQuestion], which is a question actually asked during a live
/// mock-interview turn).
class GuidanceQuestion extends Equatable {
  const GuidanceQuestion({required this.id, required this.text, required this.category});

  final String id;
  final String text;
  final GuidanceCategory category;

  @override
  List<Object?> get props => [id, text, category];
}
