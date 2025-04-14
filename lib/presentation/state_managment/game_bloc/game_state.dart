part of 'game_bloc.dart';

class GameState {
  final int score;
  final int secondsRemaining;
  final bool isGameActive;
  final int incorrectAnswersCount;
  final int? lastSelectedAnswer;
  final bool? isLastAnswerCorrect;
  final int? lastAnsweredQuestionIndex;

  final List<MathQuestion> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? errorMessage;
  final GameDifficulty? difficulty;
  final bool? showResultDialog;

  GameState({
    required this.score,
    required this.secondsRemaining,
    required this.isGameActive,
    required this.incorrectAnswersCount,
    this.lastSelectedAnswer,
    this.isLastAnswerCorrect,
    required this.questions,
    required this.currentQuestionIndex,
    required this.isLoading,
    this.errorMessage,
    this.difficulty,
    this.lastAnsweredQuestionIndex,
    this.showResultDialog,
  });

  factory GameState.initial() {
    return GameState(
      score: 0,
      secondsRemaining: 60,
      isGameActive: false,
      incorrectAnswersCount: 0,
      lastSelectedAnswer: null,
      isLastAnswerCorrect: null,
      questions: [],
      currentQuestionIndex: 0,
      isLoading: false,
      errorMessage: null,
      difficulty: null,
      lastAnsweredQuestionIndex: null,
      showResultDialog: false,
    );
  }

  GameState copyWith({
    int? score,
    int? secondsRemaining,
    bool? isGameActive,
    int? incorrectAnswersCount,
    int? lastSelectedAnswer,
    bool? isLastAnswerCorrect,
    List<MathQuestion>? questions,
    int? currentQuestionIndex,
    bool? isLoading,
    String? errorMessage,
    GameDifficulty? difficulty,
    int? lastAnsweredQuestionIndex,
    bool? showResultDialog,
  }) {
    return GameState(
      score: score ?? this.score,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isGameActive: isGameActive ?? this.isGameActive,
      incorrectAnswersCount: incorrectAnswersCount ?? this.incorrectAnswersCount,
      lastSelectedAnswer: lastSelectedAnswer ?? this.lastSelectedAnswer,
      isLastAnswerCorrect: isLastAnswerCorrect ?? this.isLastAnswerCorrect,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      difficulty: difficulty ?? this.difficulty,
      lastAnsweredQuestionIndex: lastAnsweredQuestionIndex ?? this.lastAnsweredQuestionIndex,
      showResultDialog: showResultDialog ?? this.showResultDialog,
    );
  }

  MathQuestion? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }
}
