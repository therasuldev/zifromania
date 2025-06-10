// 🆕 Category-specific statistics
class CategoryStats {
  final int gamesPlayed;
  final int questionsAnswered;
  final int correctAnswers;
  final int bestScore;
  final double averageTimePerQuestion;
  final int totalTimeSpent; // in seconds

  const CategoryStats({
    this.gamesPlayed = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.bestScore = 0,
    this.averageTimePerQuestion = 0.0,
    this.totalTimeSpent = 0,
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

  static CategoryStats fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CategoryStats();

    return CategoryStats(
      gamesPlayed: map['gamesPlayed'] ?? 0,
      questionsAnswered: map['questionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      bestScore: map['bestScore'] ?? 0,
      averageTimePerQuestion: (map['averageTimePerQuestion'] ?? 0.0).toDouble(),
      totalTimeSpent: map['totalTimeSpent'] ?? 0,
    );
  }

  CategoryStats copyWith({
    int? gamesPlayed,
    int? questionsAnswered,
    int? correctAnswers,
    int? bestScore,
    double? averageTimePerQuestion,
    int? totalTimeSpent,
  }) {
    return CategoryStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      bestScore: bestScore ?? this.bestScore,
      averageTimePerQuestion: averageTimePerQuestion ?? this.averageTimePerQuestion,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    );
  }
}