import 'package:zifromania/features/user/data/models/category_stats.dart';
import 'package:zifromania/features/user/domain/entities/game_stats_entity.dart';

class GameStats extends GameStatsEntity {
  const GameStats({
    super.categoriesPlayed = const {},
    super.categoryStats = const {},
    super.totalGamesPlayed = 0,
    super.totalQuestionsAnswered = 0,
    super.totalCorrectAnswers = 0,
    super.averageTimePerQuestion = 0.0,
  });

  @override
  Map<String, CategoryStats> get categoryStats => super.categoryStats.cast<String, CategoryStats>();

  factory GameStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const GameStats();
    }

    return GameStats(
      categoriesPlayed: Map<String, int>.from(map['categoriesPlayed'] as Map? ?? {}),
      categoryStats: (map['categoryStats'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, CategoryStats.fromMap(value as Map<String, dynamic>)),
          ) ??
          {},
      totalGamesPlayed: map['totalGamesPlayed'] as int? ?? 0,
      totalQuestionsAnswered: map['totalQuestionsAnswered'] as int? ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] as int? ?? 0,
      averageTimePerQuestion: (map['averageTimePerQuestion'] as double?) ?? 0.0,
    );
  }

  /// Entity -> Model
  factory GameStats.fromEntity(GameStatsEntity entity) {
    return GameStats(
      categoriesPlayed: entity.categoriesPlayed,
      categoryStats: entity.categoryStats.map(
        (key, value) => MapEntry(key, CategoryStats.fromEntity(value)),
      ),
      totalGamesPlayed: entity.totalGamesPlayed,
      totalQuestionsAnswered: entity.totalQuestionsAnswered,
      totalCorrectAnswers: entity.totalCorrectAnswers,
      averageTimePerQuestion: entity.averageTimePerQuestion,
    );
  }

  @override
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
