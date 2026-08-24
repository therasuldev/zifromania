import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class SpendCoinsUseCase {
  final UserRepository repository;

  const SpendCoinsUseCase(this.repository);

  Future<void> call({
    required String uid,
    required int amount,
  }) {
    return repository.spendCoins(
      uid: uid,
      amount: amount,
    );
  }
}
