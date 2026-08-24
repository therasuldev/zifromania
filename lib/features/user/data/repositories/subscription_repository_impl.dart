import 'package:zifromania/features/user/data/datasource/user_remote_datasource.dart';
import 'package:zifromania/features/user/data/models/subscription_model.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';
import 'package:zifromania/features/user/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl({required this.remoteDataSource});

  final UserRemoteDataSource remoteDataSource;

  @override
  Future<void> updateSubscriptionDetails({
    required String uid,
    required SubscriptionEntity subscription,
  }) {
    return remoteDataSource.updateSubscriptionDetails(
      uid: uid,
      subscription: SubscriptionModel.fromEntity(
        subscription,
      ),
    );
  }

  @override
  Future<void> updateSubscriptionStatus({
    required String uid,
    required bool isActive,
  }) {
    return remoteDataSource.updateSubscriptionStatus(
      uid: uid,
      isActive: isActive,
    );
  }

  @override
  Future<void> expireSubscription({required String uid}) {
    return remoteDataSource.expireSubscription(uid: uid);
  }
}
