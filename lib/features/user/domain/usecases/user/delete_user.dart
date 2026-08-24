import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  const DeleteUserUseCase(this.repository);

  Future<void> call(String uid) {
    return repository.deleteUser(uid: uid);
  }
}
