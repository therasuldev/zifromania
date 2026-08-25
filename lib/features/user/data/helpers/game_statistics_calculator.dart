import '../models/category_stats.dart';
import '../models/game_stats.dart';
import '../models/game_update_data.dart';

class GameStatisticsCalculator {
  const GameStatisticsCalculator();

  GameStats update({required GameStats current, required GameUpdateData data}) {
    final currentCategory = current.categoryStats[data.category] ?? const CategoryStats();
    final updatedCategory = _updateCategory(current: currentCategory, data: data);

    final categoriesPlayed = Map<String, int>.from(current.categoriesPlayed);
    categoriesPlayed[data.category] = (categoriesPlayed[data.category] ?? 0) + 1;

    final categoryStats = Map<String, CategoryStats>.from(current.categoryStats);
    categoryStats[data.category] = updatedCategory;

    final totalQuestions = current.totalQuestionsAnswered + data.questionsAnswered;
    final totalCorrect = current.totalCorrectAnswers + data.correctAnswers;
    final totalGames = current.totalGamesPlayed + 1;
    final totalTime = categoryStats.values.fold<int>(0, (sum, item) => sum + item.totalTimeSpent);
    final averageTime = totalQuestions == 0 ? 0 : totalTime / totalQuestions;

    return current.copyWith(
      categoriesPlayed: categoriesPlayed,
      categoryStats: categoryStats,
      totalGamesPlayed: totalGames,
      totalQuestionsAnswered: totalQuestions,
      totalCorrectAnswers: totalCorrect,
      averageTimePerQuestion: averageTime.toDouble(),
    );
  }

  CategoryStats _updateCategory({
    required CategoryStats current,
    required GameUpdateData data,
  }) {
    final gamesPlayed = current.gamesPlayed + 1;
    final questionsAnswered = current.questionsAnswered + data.questionsAnswered;
    final correctAnswers = current.correctAnswers + data.correctAnswers;
    final totalTimeSpent = current.totalTimeSpent + data.gameTimeInSeconds;
    final averageTime = questionsAnswered == 0 ? 0 : totalTimeSpent / questionsAnswered;

    return current.copyWith(
      gamesPlayed: gamesPlayed,
      questionsAnswered: questionsAnswered,
      correctAnswers: correctAnswers,
      bestScore: data.score > current.bestScore ? data.score : current.bestScore,
      totalTimeSpent: totalTimeSpent,
      averageTimePerQuestion: averageTime.toDouble(),
    );
  }
}
