// lib/features/title/domain/services/title_evaluator.dart

abstract final class TitleEvaluator {
  /// İstifadəçinin statistikalarının titulun tələblərinə (requirements) cavab verib-vermədiyini yoxlayır.
  static bool doesUserMeetRequirements(
    Map<String, dynamic> requirements, {
    required int score,
    required int level,
    required int incorrectAnswers,
    required bool isPremium,
    required int averageTimePerQuestion,
    required int questionsAnswered,
    required String category,
    required Set<String> distinctCategoriesPlayed,
    required int dailyStreak,
  }) {
    for (final entry in requirements.entries) {
      final key = entry.key;
      final value = entry.value;

      switch (key) {
        case 'score':
          if (score < value) return false;
        case 'level':
          if (level < value) return false;
        case 'levelExact':
          if (level != value) return false;
        case 'incorrectAnswers':
          if (incorrectAnswers > value) return false;
        case 'isPremium':
          if (isPremium != value) return false;
        case 'averageTimePerQuestion':
          if (averageTimePerQuestion > value) return false;
        case 'questionsAnswered':
          if (questionsAnswered < value) return false;
        case 'category':
          if (category != value) return false;
        case 'distinctCategoriesPlayed':
          if (distinctCategoriesPlayed.length < value) return false;
        case 'dailyStreak':
          if (dailyStreak < value) return false;
        default:
          break;
      }
    }
    return true;
  }
}
