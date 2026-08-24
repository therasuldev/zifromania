import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class WatchUserUseCase {
  final UserRepository repository;

  const WatchUserUseCase(this.repository);

  Stream<UserEntity> call(String uid) {
    return repository.watchUser(uid: uid);
  }
}
