import 'package:zifromania/features/user/data/models/user_model.dart';

abstract interface class RankRemoteDataSource {
  Future<List<UserModel>> fetchTopRankedUsers({int limit = 50});

  Stream<List<UserModel>> streamTopRankedUsers({int limit = 50});
  
  Future<int> getUserRankPosition(String userId);
}
