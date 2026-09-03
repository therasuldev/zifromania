import 'package:zifromania/features/rank/domain/repositories/rank_repository.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

/// Liderlər lövhəsinin ilk N istifadəçisini bir dəfəlik gətirən use case.
final class FetchTopRankedUsersUseCase {
  const FetchTopRankedUsersUseCase(this._repository);

  final RankRepository _repository;

  Future<List<UserModel>> call({int limit = 50}) {
    return _repository.fetchTopRankedUsers(limit: limit);
  }
}