import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

class AddAchievementUseCase {
  final UserStatisticsRepository repository;

  const AddAchievementUseCase(this.repository);

  Future<void> call({
    required String uid,
    required String achievementId,
  }) {
    return repository.addAchievement(
      uid: uid,
      achievementId: achievementId,
    );
  }
}
