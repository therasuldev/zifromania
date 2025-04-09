part of 'question_bloc.dart';

enum MathQuestionEvents {
  generateQuestionsStart,
  generateQuestionsSuccess,
  generateQuestionsFailure,
  showNextQuestion,
}

class MathQuestionEvent {
  MathQuestionEvents? type;
  dynamic payload;

  // Event to start generating questions (with difficulty as payload)
  MathQuestionEvent.generateQuestionsStart({required this.payload}) {
    type = MathQuestionEvents.generateQuestionsStart;
  }

  // Event to advance to the next question (no payload)
  MathQuestionEvent.showNextQuestion() {
    type = MathQuestionEvents.showNextQuestion;
    payload = null;
  }

  // (Optional) You could add constructors for success/failure if needed.
  // These are usually not dispatched by the UI, but used internally for state.
}
