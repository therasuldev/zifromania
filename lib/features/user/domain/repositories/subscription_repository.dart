import '../entities/subscription_entity.dart';

abstract interface class SubscriptionRepository {
  Future<void> updateSubscriptionDetails({
    required String uid,
    required SubscriptionEntity subscription,
  });

  Future<void> updateSubscriptionStatus({
    required String uid,
    required bool isActive,
  });

  Future<void> expireSubscription({required String uid});
}
