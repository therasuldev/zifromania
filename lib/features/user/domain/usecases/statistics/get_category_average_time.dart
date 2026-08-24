import 'package:zifromania/features/user/domain/repositories/user_statistics_repository.dart';

class GetCategoryAverageTimeUseCase {
  final UserStatisticsRepository repository;

  const GetCategoryAverageTimeUseCase(
    this.repository,
  );

  Future<double> call({
    required String uid,
    required String category,
  }) {
    return repository.getCategoryAverageTime(
      uid: uid,
      category: category,
    );
  }
}
