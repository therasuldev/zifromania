import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

final class AwardTitleToUserUseCase {
  final UserStatisticsRepository userStatisticsRepository;

  const AwardTitleToUserUseCase(this.userStatisticsRepository);

  Future<void> call({required String uid, required String titleId}) async {
    await userStatisticsRepository.addAchievement(uid: uid, achievementId: titleId);
  }
}
