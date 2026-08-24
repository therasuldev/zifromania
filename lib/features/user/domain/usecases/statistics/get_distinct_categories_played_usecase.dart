import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

class GetDistinctCategoriesPlayedUseCase {
  final UserStatisticsRepository repository;

  const GetDistinctCategoriesPlayedUseCase(this.repository);

  Future<Set<String>> call(String uid) {
    return repository.getDistinctCategoriesPlayed(uid: uid);
  }
}
