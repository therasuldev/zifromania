import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final SubscriptionType? type;
  final Timestamp? startDate;
  final Timestamp? endDate;

  const SubscriptionModel({
    this.type,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type?.value,
      'startDate': startDate?.toDate().toIso8601String(),
      'endDate': endDate?.toDate().toIso8601String(),
    };
  }

  static SubscriptionModel fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SubscriptionModel();

    return SubscriptionModel(
      type: SubscriptionType.fromString(map['type'] as String?),
      startDate: map['startDate'],
      endDate: map['endDate'],
    );
  }
}

enum SubscriptionType {
  oneMonth,
  threeMonths,
  sixMonths;

  String get value {
    return switch (this) {
      SubscriptionType.oneMonth => 'oneMonth',
      SubscriptionType.threeMonths => 'threeMonths',
      SubscriptionType.sixMonths => 'sixMonths',
    };
  }

  factory SubscriptionType.fromString(String? value) {
    return switch (value) {
      'oneMonth' => SubscriptionType.oneMonth,
      'threeMonths' => SubscriptionType.threeMonths,
      'sixMonths' => SubscriptionType.sixMonths,
      _ => SubscriptionType.oneMonth, // Default case
    };
  }
}
