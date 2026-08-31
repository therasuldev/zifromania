import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    super.type = SubscriptionTypeEntity.free,
    super.startDate,
    super.endDate,
  });

  factory SubscriptionModel.fromMap(
    Map<String, dynamic>? map,
  ) {
    if (map == null) {
      return const SubscriptionModel();
    }

    final typeValue = map['type'] as String?;

    return SubscriptionModel(
      type: SubscriptionTypeEntity.values.firstWhere(
        (e) => e.name == typeValue,
        orElse: () => SubscriptionTypeEntity.free,
      ),
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
    );
  }

  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      type: SubscriptionTypeEntity.values.firstWhere(
        (e) => e.name == entity.type.name,
        orElse: () => SubscriptionTypeEntity.free,
      ),
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
    };
  }

  SubscriptionModel copyWith({
    SubscriptionTypeEntity? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return SubscriptionModel(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
