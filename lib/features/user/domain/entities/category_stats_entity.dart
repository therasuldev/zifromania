class CategoryStatsEntity {
  final int gamesPlayed;
  final int questionsAnswered;
  final int correctAnswers;
  final int bestScore;
  final int totalTimeSpent;
  final double averageTimePerQuestion;

  const CategoryStatsEntity({
    required this.gamesPlayed,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.bestScore,
    required this.totalTimeSpent,
    required this.averageTimePerQuestion,
  });

  Map<String, dynamic> toMap() {
    return {
      'gamesPlayed': gamesPlayed,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'bestScore': bestScore,
      'averageTimePerQuestion': averageTimePerQuestion,
      'totalTimeSpent': totalTimeSpent,
    };
  }

  double get accuracy {
    if (questionsAnswered == 0) return 0;
    return (correctAnswers / questionsAnswered) * 100;
  }
}
