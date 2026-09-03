import 'package:zifromania/features/rank/domain/repositories/rank_repository.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

/// Liderlər lövhəsini real-vaxt rejimində izləyən use case.
final class StreamTopRankedUsersUseCase {
  const StreamTopRankedUsersUseCase(this._repository);

  final RankRepository _repository;

  Stream<List<UserModel>> call({int limit = 50}) {
    return _repository.streamTopRankedUsers(limit: limit);
  }
}
