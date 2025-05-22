part of 'game_bloc.dart';

class GameState {
  final int score;
  final int xpEarned;
  final int playerLevel;
  final int playerXp;
  final int playerXpTarget;
  final int secondsRemaining;
  final bool isGameActive;
  final int incorrectAnswersCount;
  final int? lastSelectedAnswer;
  final bool? isLastAnswerCorrect;
  final int? lastAnsweredQuestionIndex;
  final bool useQuestionTimer;
  final int questionTimeRemaining;

  final DateTime? gameStartTime; // 🆕 Track game start time
  final List<String> newlyEarnedTitles; // 🆕 Newly earned titles

  final List<MathQuestion> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? errorMessage;
  final GameDifficulty? difficulty;
  final bool? showResultDialog;
  final bool showSubscribeDialog;

  GameState({
    required this.score,
    this.xpEarned = 0,
    this.playerLevel = 1,
    this.playerXp = 0,
    this.playerXpTarget = 100,
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
    this.showResultDialog = false,
    this.showSubscribeDialog = false,
    this.useQuestionTimer = false,
    this.questionTimeRemaining = 0,
    this.gameStartTime,
    this.newlyEarnedTitles = const [],
  });

  factory GameState.initial() {
    return GameState(
      score: 0,
      playerLevel: 1,
      playerXp: 0,
      playerXpTarget: 100,
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
      showSubscribeDialog: false,
      useQuestionTimer: false,
      questionTimeRemaining: 0,
      xpEarned: 0,
      gameStartTime: null,
      newlyEarnedTitles: const [],
    );
  }

  GameState copyWith({
    int? score,
    int? playerLevel,
    int? playerXp,
    int? playerXpTarget,
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
    bool? showSubscribeDialog,
    bool? useQuestionTimer,
    int? questionTimeRemaining,
    int? xpEarned,
    DateTime? gameStartTime,
    List<String>? newlyEarnedTitles,
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
      showSubscribeDialog: showSubscribeDialog ?? this.showSubscribeDialog,
      useQuestionTimer: useQuestionTimer ?? this.useQuestionTimer,
      questionTimeRemaining: questionTimeRemaining ?? this.questionTimeRemaining,
      xpEarned: xpEarned ?? this.xpEarned,
      playerLevel: playerLevel ?? this.playerLevel,
      playerXp: playerXp ?? this.playerXp,
      playerXpTarget: playerXpTarget ?? this.playerXpTarget,
      gameStartTime: gameStartTime ?? this.gameStartTime,
      newlyEarnedTitles: newlyEarnedTitles ?? this.newlyEarnedTitles,
    );
  }

  MathQuestion? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }
}
