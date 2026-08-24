import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class CreateUserProfileUseCase {
  final UserRepository repository;

  const CreateUserProfileUseCase(this.repository);

  Future<void> call(UserEntity user) {
    return repository.createUserProfile(user: user);
  }
}
