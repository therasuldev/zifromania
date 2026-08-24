import 'package:zifromania/features/user/data/datasource/user_remote_datasource.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({required this.remoteDataSource});

  final UserRemoteDataSource remoteDataSource;

  @override
  Future<void> createUserProfile({required UserEntity user}) {
    return remoteDataSource.createUserProfile(
      user: UserModel.fromEntity(user),
    );
  }

  @override
  Future<UserEntity> getUser({required String uid}) async {
    final user = await remoteDataSource.getUser(uid: uid);

    return user.toEntity();
  }

  @override
  Stream<UserEntity> watchUser({required String uid}) {
    return remoteDataSource.watchUser(uid: uid).map(
          (user) => user.toEntity(),
        );
  }

  @override
  Future<void> deleteUser({required String uid}) {
    return remoteDataSource.deleteUser(uid: uid);
  }

  @override
  Future<UserEntity> addCoins({
    required String uid,
    required int amount,
  }) async {
    final user = await remoteDataSource.addCoins(
      uid: uid,
      amount: amount,
    );

    return user.toEntity();
  }

  @override
  Future<void> spendCoins({
    required String uid,
    required int amount,
  }) {
    return remoteDataSource.spendCoins(
      uid: uid,
      amount: amount,
    );
  }

  @override
  Future<void> addXp({
    required String uid,
    required int xpEarned,
  }) {
    return remoteDataSource.addXp(
      uid: uid,
      xpEarned: xpEarned,
    );
  }
}
