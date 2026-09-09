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
          if (score < (value as int)) return false;
        case 'level':
          if (level < (value as int)) return false;
        case 'levelExact':
          if (level != (value as int)) return false;
        case 'incorrectAnswers':
          if (incorrectAnswers > (value as int)) return false;
        case 'isPremium':
          if (isPremium != (value as bool)) return false;
        case 'averageTimePerQuestion':
          if (averageTimePerQuestion > (value as int)) return false;
        case 'questionsAnswered':
          if (questionsAnswered < (value as int)) return false;
        case 'category':
          if (category != (value as String)) return false;
        case 'distinctCategoriesPlayed':
          if (distinctCategoriesPlayed.length < (value as int)) return false;
        case 'dailyStreak':
          if (dailyStreak < (value as int)) return false;
        default:
          break;
      }
    }
    return true;
  }
}
