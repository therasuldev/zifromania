import 'package:zifromania/features/user/data/models/category_stats.dart';
import 'package:zifromania/features/user/domain/entities/game_stats_entity.dart';

class GameStats {
  final Map<String, int> categoriesPlayed;
  final Map<String, CategoryStats> categoryStats;
  final int totalGamesPlayed;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final double averageTimePerQuestion;

  const GameStats({
    this.categoriesPlayed = const {},
    this.categoryStats = const {},
    this.totalGamesPlayed = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.averageTimePerQuestion = 0.0,
  });

  factory GameStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const GameStats();
    }

    return GameStats(
      categoriesPlayed: Map<String, int>.from(map['categoriesPlayed'] ?? {}),
      categoryStats: (map['categoryStats'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              CategoryStats.fromMap(
                value as Map<String, dynamic>,
              ),
            ),
          ) ??
          {},
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      totalQuestionsAnswered: map['totalQuestionsAnswered'] ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] ?? 0,
      averageTimePerQuestion: (map['averageTimePerQuestion'] ?? 0.0).toDouble(),
    );
  }

  /// Entity -> Model
  factory GameStats.fromEntity(
    GameStatsEntity entity,
  ) {
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

  /// Model -> Entity
  GameStatsEntity toEntity() {
    return GameStatsEntity(
      categoriesPlayed: categoriesPlayed,
      categoryStats: categoryStats.map(
        (key, value) => MapEntry(
          key,
          value.toEntity(),
        ),
      ),
      totalGamesPlayed: totalGamesPlayed,
      totalQuestionsAnswered: totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers,
      averageTimePerQuestion: averageTimePerQuestion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoriesPlayed': categoriesPlayed,
      'categoryStats': categoryStats.map(
        (key, value) => MapEntry(
          key,
          value.toMap(),
        ),
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
