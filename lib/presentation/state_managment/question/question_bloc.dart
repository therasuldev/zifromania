import 'package:equation_quest/domain/entities/enums.dart';
import 'package:equation_quest/domain/entities/math_question.dart';
import 'package:equation_quest/services/open_ai_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'question_event.dart';
part 'question_state.dart';

class MathQuestionBloc extends Bloc<MathQuestionEvent, MathQuestionState> {
  final OpenAIService _openAIService = OpenAIService.instance; // Singleton service instance

  MathQuestionBloc() : super(MathQuestionState.initial()) {
    on<MathQuestionEvent>((event, emit) async {
      switch (event.type) {
        case MathQuestionEvents.generateQuestionsStart:
          await _onGenerateQuestions(event, emit);
          break;
        case MathQuestionEvents.showNextQuestion:
          _onShowNextQuestion(emit);
          break;
        default:
          // We don't expect generateQuestionsSuccess/Failure to be added from UI
          break;
      }
    });
  }

  /// Handle the generateQuestionsStart event: fetch questions from OpenAI
  Future<void> _onGenerateQuestions(
      MathQuestionEvent event, Emitter<MathQuestionState> emit) async {
    // Emit loading state (event indicates loading, no questions yet)
    emit(MathQuestionState(
      questions: [],
      event: MathQuestionEvents.generateQuestionsStart,
      currentQuestionIndex: 0,
    ));
    try {
      final difficulty = event.payload as GameDifficulty;
      // Fetch new questions from OpenAI based on the given difficulty
      List<MathQuestion> newQuestions = await _openAIService.generateQuestions(difficulty);
      // Ensure we only keep 3 questions as required
      if (newQuestions.length > 3) {
        newQuestions = newQuestions.sublist(0, 3);
      }
      // Emit success state with the fetched questions
      emit(MathQuestionState(
        questions: newQuestions,
        event: MathQuestionEvents.generateQuestionsSuccess,
        currentQuestionIndex: 0,  // start at the first question
      ));
    } catch (e) {
      // If fetching fails, emit a failure state (could include error details in payload if needed)
      emit(MathQuestionState(
        questions: [],
        event: MathQuestionEvents.generateQuestionsFailure,
        currentQuestionIndex: 0,
      ));
    }
  }

  /// Handle the showNextQuestion event: update the current question index
  void _onShowNextQuestion(Emitter<MathQuestionState> emit) {
    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex < state.questions.length) {
      emit(MathQuestionState(
        questions: state.questions, // reuse existing questions list
        event: MathQuestionEvents.generateQuestionsSuccess, // remain in success state
        currentQuestionIndex: nextIndex,
      ));
    }
    // If we've reached the end of the list, do nothing or handle accordingly (e.g., loop or finish)
  }
}
