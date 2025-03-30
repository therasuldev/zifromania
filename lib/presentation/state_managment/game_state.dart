import 'dart:async';

class GameState {
  int score;
  int secondsRemaining;
  bool isGameActive;
  int incorrectAnswersCount;
  int? lastSelectedAnswer;
  bool? isLastAnswerCorrect;
  Timer? timer;

  GameState({
    required this.score,
    required this.secondsRemaining,
    required this.isGameActive,
    required this.incorrectAnswersCount,
    this.lastSelectedAnswer,
    this.isLastAnswerCorrect,
    this.timer,
  });
}