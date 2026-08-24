import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository repository;

  const GetUserUseCase(this.repository);

  Future<UserEntity> call(String uid) {
    return repository.getUser(uid: uid);
  }
}
