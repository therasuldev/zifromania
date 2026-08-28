import 'package:zifromania/features/user/data/models/user_model.dart';

abstract interface class UserLocalDataSource {
  Future<UserModel?> getUser();

  Future<void> cacheUser(UserModel user);

  Future<void> clearUser();
}
