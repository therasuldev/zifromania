class GameUpdateData {
  final String category;
  final int score;
  final int questionsAnswered;
  final int correctAnswers;
  final int gameTimeInSeconds;

  const GameUpdateData({
    required this.category,
    required this.score,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.gameTimeInSeconds,
  });
}
