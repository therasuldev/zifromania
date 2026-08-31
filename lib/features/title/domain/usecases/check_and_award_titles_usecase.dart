import 'package:zifromania/features/title/domain/service/title_evaluator.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';
import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';
import '../repositories/title_repository.dart';
import 'award_title_to_user_usecase.dart';

final class CheckAndAwardTitlesUseCase {
  final TitleRepository titleRepository;
  final UserStatisticsRepository userStatisticsRepository;
  final UserRepository userRepository;
  final AwardTitleToUserUseCase awardTitleToUserUseCase;

  const CheckAndAwardTitlesUseCase({
    required this.titleRepository,
    required this.userStatisticsRepository,
    required this.userRepository,
    required this.awardTitleToUserUseCase,
  });

  Future<List<String>> call({
    required String userId,
    required int lastGameScore,
    required int incorrectAnswers,
    required int averageTimePerQuestion,
    required int questionsAnswered,
    required String category,
  }) async {
    final user = await userRepository.getUser(uid: userId);
    final allTitles = await titleRepository.getAllTitles();

    final newEarnedTitleIds = <String>[];

    for (final title in allTitles) {
      if (user.achievements.contains(title.id)) continue;

      final meetsReqs = TitleEvaluator.doesUserMeetRequirements(
        title.requirements,
        score: lastGameScore,
        level: user.level,
        incorrectAnswers: incorrectAnswers,
        isPremium: user.hasActiveSubscription,
        averageTimePerQuestion: averageTimePerQuestion,
        questionsAnswered: questionsAnswered,
        category: category,
        distinctCategoriesPlayed: await userStatisticsRepository.getDistinctCategoriesPlayed(uid: userId),
        dailyStreak: user.currentStreak,
      );

      if (meetsReqs) {
        // Doğrudan repository əvəzinə mövcud UseCase-i çağırırıq
        await awardTitleToUserUseCase(uid: userId, titleId: title.id);
        newEarnedTitleIds.add(title.id);
      }
    }

    return newEarnedTitleIds;
  }
}
