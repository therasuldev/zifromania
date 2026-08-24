import 'package:zifromania/features/user/domain/repositories/user_repository.dart';

class AddXpUseCase {
  final UserRepository repository;

  const AddXpUseCase(this.repository);

  Future<void> call({
    required String uid,
    required int xp,
  }) {
    return repository.addXp(
      uid: uid,
      xpEarned: xp,
    );
  }
}
