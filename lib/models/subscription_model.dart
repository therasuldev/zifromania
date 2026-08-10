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
      startDate: _parseTimestamp(map['startDate']),
      endDate: _parseTimestamp(map['endDate']),
    );
  }

  // Helper method to parse timestamp from various formats
  static Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value;
    }

    if (value is String) {
      try {
        final dateTime = DateTime.parse(value);
        return Timestamp.fromDate(dateTime);
      } catch (e) {
        print('Error parsing timestamp from string: $e');
        return null;
      }
    }

    if (value is int) {
      try {
        return Timestamp.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        print('Error parsing timestamp from int: $e');
        return null;
      }
    }

    return null;
  }
}

enum SubscriptionType {
  free,
  oneMonth,
  threeMonths,
  sixMonths;

  String get value {
    return switch (this) {
      SubscriptionType.free => 'free',
      SubscriptionType.oneMonth => 'oneMonth',
      SubscriptionType.threeMonths => 'threeMonths',
      SubscriptionType.sixMonths => 'sixMonths',
    };
  }

  factory SubscriptionType.fromString(String? value) {
    return switch (value) {
      'free' => SubscriptionType.free,
      'oneMonth' => SubscriptionType.oneMonth,
      'threeMonths' => SubscriptionType.threeMonths,
      'sixMonths' => SubscriptionType.sixMonths,
      _ => SubscriptionType.free, // default olaraq FREE
    };
  }
}
