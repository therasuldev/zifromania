import 'package:zifromania/features/user/domain/entities/category_stats_entity.dart';

class CategoryStats extends CategoryStatsEntity {
  const CategoryStats({
    super.gamesPlayed = 0,
    super.questionsAnswered = 0,
    super.correctAnswers = 0,
    super.bestScore = 0,
    super.averageTimePerQuestion = 0.0,
    super.totalTimeSpent = 0,
  });

  factory CategoryStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CategoryStats();

    return CategoryStats(
      gamesPlayed: map['gamesPlayed'] as int? ?? 0,
      questionsAnswered: map['questionsAnswered'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      bestScore: map['bestScore'] as int? ?? 0,
      averageTimePerQuestion: (map['averageTimePerQuestion'] as double?) ?? 0.0,
      totalTimeSpent: map['totalTimeSpent'] as int? ?? 0,
    );
  }

  /// Entity -> Model
  factory CategoryStats.fromEntity(
    CategoryStatsEntity entity,
  ) {
    return CategoryStats(
      gamesPlayed: entity.gamesPlayed,
      questionsAnswered: entity.questionsAnswered,
      correctAnswers: entity.correctAnswers,
      bestScore: entity.bestScore,
      averageTimePerQuestion: entity.averageTimePerQuestion,
      totalTimeSpent: entity.totalTimeSpent,
    );
  }

  @override
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
