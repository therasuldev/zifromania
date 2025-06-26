part of 'game_bloc.dart';

enum GameEvents {
  startGame,
  endGame,
  timerTick,
  checkAnswer,
  resetGame,
  showNextQuestion,
  playAgain,
  autoAdvanceQuestion, // For True/False mode
}

class GameEvent {
  GameEvents? type;
  dynamic payload;

  GameEvent.startGame({required Map<String, dynamic> this.payload}) {
    type = GameEvents.startGame;
  }

  GameEvent.endGame() {
    type = GameEvents.endGame;
    payload = null;
  }

  GameEvent.timerTick() {
    type = GameEvents.timerTick;
    payload = null;
  }

  GameEvent.checkAnswer({
    required MathQuestion question,
    required int selectedAnswerIndex,
  }) {
    type = GameEvents.checkAnswer;
    payload = {
      'question': question,
      'selectedAnswerIndex': selectedAnswerIndex,
    };
  }

  GameEvent.resetGame() {
    type = GameEvents.resetGame;
    payload = null;
  }

  GameEvent.showNextQuestion() {
    type = GameEvents.showNextQuestion;
    payload = null;
  }

  GameEvent.playAgain({required Map<String, dynamic> this.payload}) {
    type = GameEvents.playAgain;
  }

  GameEvent.autoAdvanceQuestion() {
    type = GameEvents.autoAdvanceQuestion;
    payload = null;
  }
}
