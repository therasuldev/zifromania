import 'package:zifromania/features/rank/data/datasource/rank_remote_datasouce.dart';
import 'package:zifromania/features/rank/domain/repositories/rank_repository.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

/// [RankRepository] kontraktının data qatındakı implementasiyası.
///
/// Bu sinif özü heç bir biznes qaydası daşımır — sadəcə remote data source-a
/// müraciəti həyata keçirir. Exception-lar artıq [RankRemoteDataSourceImpl]
/// içində `ServerException` / `UnknownException` formatına salınıb ötürüldüyü
/// üçün burada əlavə try/catch-ə ehtiyac yoxdur.
final class RankRepositoryImpl implements RankRepository {
  const RankRepositoryImpl({required RankRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  final RankRemoteDataSource _remoteDataSource;

  @override
  Future<List<UserModel>> fetchTopRankedUsers({int limit = 50}) {
    return _remoteDataSource.fetchTopRankedUsers(limit: limit);
  }

  @override
  Stream<List<UserModel>> streamTopRankedUsers({int limit = 50}) {
    return _remoteDataSource.streamTopRankedUsers(limit: limit);
  }

  @override
  Future<int> getUserRankPosition(String userId) {
    return _remoteDataSource.getUserRankPosition(userId);
  }
}
