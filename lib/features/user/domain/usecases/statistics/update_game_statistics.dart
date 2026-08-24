import 'package:zifromania/features/user/data/models/game_update_data.dart';
import '../../repositories/user_statistics_repository.dart';

class UpdateGameStatisticsUseCase {
  final UserStatisticsRepository repository;

  const UpdateGameStatisticsUseCase(this.repository);

  Future<void> call({
    required String uid,
    required GameUpdateData data,
  }) {
    return repository.updateGameStatistics(
      uid: uid,
      data: data,
    );
  }
}
