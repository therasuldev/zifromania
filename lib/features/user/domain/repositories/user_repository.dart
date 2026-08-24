import '../entities/user_entity.dart';

abstract interface class UserRepository {
  Future<void> createUserProfile({required UserEntity user});

  Future<UserEntity> getUser({required String uid});

  Stream<UserEntity> watchUser({required String uid});

  Future<void> deleteUser({required String uid});

  Future<UserEntity> addCoins({
    required String uid,
    required int amount,
  });

  Future<void> spendCoins({
    required String uid,
    required int amount,
  });

  Future<void> addXp({
    required String uid,
    required int xpEarned,
  });
}
