import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';
import 'package:zifromania/features/user/user_module.dart';

/// Abunəlik ilə bağlı mutasiya (action) əməliyyatlarını idarə edir:
/// detalların yenilənməsi, statusun dəyişdirilməsi, ləğv/expire.
class SubscriptionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateSubscriptionDetails({
    required String uid,
    required SubscriptionEntity subscription,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateSubscriptionDetailsUseCaseProvider).call(
            uid: uid,
            subscription: subscription,
          );
    });
  }

  Future<void> updateSubscriptionStatus({
    required String uid,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateSubscriptionStatusUseCaseProvider).call(
            uid: uid,
            isActive: isActive,
          );
    });
  }

  Future<void> expireSubscription(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expireSubscriptionUseCaseProvider).call(uid: uid);
    });
  }
}

final subscriptionProvider = AsyncNotifierProvider<SubscriptionNotifier, void>(SubscriptionNotifier.new);
