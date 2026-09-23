import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class UpdateUsernameUseCase {
  final UserRepository repository;

  const UpdateUsernameUseCase(this.repository);

  Future<void> call({
    required String uid,
    required String username,
  }) async {
    await repository.updateUsername(uid: uid, username: username);
  }
}
