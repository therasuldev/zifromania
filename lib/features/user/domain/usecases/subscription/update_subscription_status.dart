import 'package:zifromania/features/user/domain/repositories/subscription_repository.dart';

class UpdateSubscriptionStatusUseCase {
  final SubscriptionRepository repository;

  const UpdateSubscriptionStatusUseCase(this.repository);

  Future<void> call({
    required String uid,
    required bool isActive,
  }) {
    return repository.updateSubscriptionStatus(
      uid: uid,
      isActive: isActive,
    );
  }
}
