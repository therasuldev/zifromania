import 'package:zifromania/features/rank/domain/repositories/rank_repository.dart';

/// Konkret bir istifadəçinin ümumi reytinqdəki mövqeyini hesablayan use case.
final class GetUserRankPositionUseCase {
  const GetUserRankPositionUseCase(this._repository);

  final RankRepository _repository;

  Future<int> call(String userId) {
    return _repository.getUserRankPosition(userId);
  }
}
