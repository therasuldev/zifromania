import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class AddCoinsUseCase {
  final UserRepository repository;

  const AddCoinsUseCase(this.repository);

  Future<UserEntity> call({
    required String uid,
    required int amount,
  }) {
    return repository.addCoins(
      uid: uid,
      amount: amount,
    );
  }
}