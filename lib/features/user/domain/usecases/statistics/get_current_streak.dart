import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

class GetCurrentStreakUseCase {
  final UserStatisticsRepository repository;

  const GetCurrentStreakUseCase(this.repository);

  Future<int> call(String uid) {
    return repository.getCurrentStreak(uid: uid);
  }
}
