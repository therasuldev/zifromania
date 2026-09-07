import 'package:zifromania/features/user/domain/entities/category_stats_entity.dart';

class GameStatsEntity {
  final Map<String, int> categoriesPlayed;

  final Map<String, CategoryStatsEntity> categoryStats;

  final int totalGamesPlayed;

  final int totalQuestionsAnswered;

  final int totalCorrectAnswers;

  final double averageTimePerQuestion;

  const GameStatsEntity({
    required this.categoriesPlayed,
    required this.categoryStats,
    required this.totalGamesPlayed,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
    required this.averageTimePerQuestion,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoriesPlayed': categoriesPlayed,
      'categoryStats': categoryStats.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'totalGamesPlayed': totalGamesPlayed,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'averageTimePerQuestion': averageTimePerQuestion,
    };
  }

  double get overallAccuracy {
    if (totalQuestionsAnswered == 0) return 0;

    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }
}
