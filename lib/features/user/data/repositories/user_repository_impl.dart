import 'package:zifromania/features/user/data/datasource/user_local_data_source.dart';
import 'package:zifromania/features/user/data/datasource/user_remote_datasource.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  @override
  Future<void> createUserProfile({required UserEntity user}) async {
    await remoteDataSource.createUserProfile(
      user: UserModel.fromEntity(user),
    );
  }

  @override
  Future<UserEntity> getUser({required String uid}) async {
    try {
      final user = await remoteDataSource.getUser(uid: uid);

      await localDataSource.cacheUser(user);

      return user.toEntity();
    } catch (e) {
      final cachedUser = await localDataSource.getUser();

      if (cachedUser != null && cachedUser.uid == uid) {
        return cachedUser.toEntity();
      }

      rethrow;
    }
  }

  @override
  Stream<UserEntity> watchUser({required String uid}) {
    return remoteDataSource.watchUser(uid: uid).map((user) {
      localDataSource.cacheUser(user);

      return user.toEntity();
    });
  }

  @override
  Future<void> deleteUser({required String uid}) async {
    await remoteDataSource.deleteUser(uid: uid);
    await localDataSource.clearUser();
  }

  @override
  Future<UserEntity> addCoins({required String uid, required int amount}) async {
    final user = await remoteDataSource.addCoins(uid: uid, amount: amount);
    await localDataSource.cacheUser(user);

    return user.toEntity();
  }

  @override
  Future<UserEntity> spendCoins({required String uid, required int amount}) async {
    final user = await remoteDataSource.spendCoins(uid: uid, amount: amount);
    await localDataSource.cacheUser(user);

    return user.toEntity();
  }

  @override
  Future<UserEntity> addXp({required String uid, required int xpEarned}) async {
    final user = await remoteDataSource.addXp(uid: uid, xpEarned: xpEarned);
    await localDataSource.cacheUser(user);

    return user.toEntity();
  }
}
