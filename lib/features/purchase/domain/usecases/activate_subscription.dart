import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';
import 'package:zifromania/features/user/domain/repositories/subscription_repository.dart';

class ActivateSubscriptionUseCase {
  ActivateSubscriptionUseCase({required this.repository});

  final SubscriptionRepository repository;

  Future<void> call({required String uid, required SubscriptionEntity subscription}) async {
    await repository.updateSubscriptionDetails(uid: uid, subscription: subscription);
  }
}
