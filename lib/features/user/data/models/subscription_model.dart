import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';

class SubscriptionModel {
  final SubscriptionTypeEntity? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const SubscriptionModel({
    this.type,
    this.startDate,
    this.endDate,
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

  factory SubscriptionModel.fromEntity(
    SubscriptionEntity entity,
  ) {
    return SubscriptionModel(
      type: SubscriptionTypeEntity.values.firstWhere(
        (e) => e.name == entity.type.name,
        orElse: () => SubscriptionTypeEntity.free,
      ),
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  SubscriptionEntity toEntity() {
    return SubscriptionEntity(
      type: type ?? SubscriptionTypeEntity.free,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type?.name,
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
