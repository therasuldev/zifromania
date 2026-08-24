import 'package:zifromania/features/user/domain/repositories/subscription_repository.dart';

class ExpireSubscriptionUseCase {
  final SubscriptionRepository repository;

  const ExpireSubscriptionUseCase(this.repository);

  Future<void> call({required String uid}) {
    return repository.expireSubscription(uid: uid);
  }
}
