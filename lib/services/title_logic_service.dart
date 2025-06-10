class TitleLogicService {
  static bool doesUserMeetRequirements(
    Map<String, dynamic> req, {
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
    for (var entry in req.entries) {
      final key = entry.key;
      final value = entry.value;

      switch (key) {
        case 'score':
          if (score < value) return false;
          break;
        case 'level':
          if (level < value) return false;
          break;
        case 'levelExact':
          if (level != value) return false;
          break;
        case 'incorrectAnswers':
          if (incorrectAnswers > value) return false;
          break;
        case 'isPremium':
          if (isPremium != value) return false;
          break;
        case 'averageTimePerQuestion':
          if (averageTimePerQuestion > value) return false;
          break;
        case 'questionsAnswered':
          if (questionsAnswered < value) return false;
          break;
        case 'category':
          if (category != value) return false;
          break;
        case 'distinctCategoriesPlayed':
          if (distinctCategoriesPlayed.length < value) return false;
          break;
        case 'dailyStreak':
          if (dailyStreak < value) return false;
          break;
        default:
          break;
      }
    }
    return true;
  }
}
