import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;
  SignInWithGoogleUseCase(this._repository);

  Future<UserModel> call() => _repository.signInWithGoogle();
}
