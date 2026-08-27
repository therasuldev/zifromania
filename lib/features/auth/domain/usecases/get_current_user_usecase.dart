import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  Future<UserModel?> call() => _repository.getCurrentUser();
}
