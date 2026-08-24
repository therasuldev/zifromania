import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';
import 'package:zifromania/features/user/domain/repositories/subscription_repository.dart';

class UpdateSubscriptionDetailsUseCase {
  final SubscriptionRepository repository;

  const UpdateSubscriptionDetailsUseCase(this.repository);

  Future<void> call({
    required String uid,
    required SubscriptionEntity subscription,
  }) {
    return repository.updateSubscriptionDetails(
      uid: uid,
      subscription: subscription,
    );
  }
}
