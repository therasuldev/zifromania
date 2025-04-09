part of 'question_bloc.dart';

class MathQuestionState {
  final List<MathQuestion> questions;
  final MathQuestionEvents? event;
  final int currentQuestionIndex;

  MathQuestionState({
    required this.questions,
    required this.event,
    required this.currentQuestionIndex,
  });

  // Initial state: no questions, no event, index at 0
  factory MathQuestionState.initial() {
    return MathQuestionState(
      questions: [],
      event: null,
      currentQuestionIndex: 0,
    );
  }
}
