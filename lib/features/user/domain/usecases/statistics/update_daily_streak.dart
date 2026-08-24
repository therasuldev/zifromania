import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

class UpdateDailyStreakUseCase {
  final UserStatisticsRepository repository;

  const UpdateDailyStreakUseCase(this.repository);

  Future<void> call(String uid) {
    return repository.updateDailyStreak(uid: uid);
  }
}
