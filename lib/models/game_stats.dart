// 🆕 Game statistics class
import 'category_stats.dart';

class GameStats {
  final Map<String, int> categoriesPlayed; // category -> games played
  final Map<String, CategoryStats> categoryStats; // detailed stats per category
  final int totalGamesPlayed;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final double averageTimePerQuestion; // in seconds

  const GameStats({
    this.categoriesPlayed = const {},
    this.categoryStats = const {},
    this.totalGamesPlayed = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.averageTimePerQuestion = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoriesPlayed': categoriesPlayed,
      'categoryStats': categoryStats.map((k, v) => MapEntry(k, v.toMap())),
      'totalGamesPlayed': totalGamesPlayed,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'averageTimePerQuestion': averageTimePerQuestion,
    };
  }

  static GameStats fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GameStats();

    return GameStats(
      categoriesPlayed: Map<String, int>.from(map['categoriesPlayed'] ?? {}),
      categoryStats: (map['categoryStats'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, CategoryStats.fromMap(v)),
          ) ??
          {},
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      totalQuestionsAnswered: map['totalQuestionsAnswered'] ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] ?? 0,
      averageTimePerQuestion: (map['averageTimePerQuestion'] ?? 0.0).toDouble(),
    );
  }

  GameStats copyWith({
    Map<String, int>? categoriesPlayed,
    Map<String, CategoryStats>? categoryStats,
    int? totalGamesPlayed,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    double? averageTimePerQuestion,
  }) {
    return GameStats(
      categoriesPlayed: categoriesPlayed ?? this.categoriesPlayed,
      categoryStats: categoryStats ?? this.categoryStats,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      averageTimePerQuestion: averageTimePerQuestion ?? this.averageTimePerQuestion,
    );
  }
}
