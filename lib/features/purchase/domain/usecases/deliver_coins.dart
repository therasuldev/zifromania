import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class DeliverCoinsUseCase {
  DeliverCoinsUseCase({required this.repository});

  final UserRepository repository;

  Future<void> call({required String uid, required int amount}) async {
    await repository.addCoins(uid: uid, amount: amount);
  }
}
