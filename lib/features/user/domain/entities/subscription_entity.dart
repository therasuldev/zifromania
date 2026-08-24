enum SubscriptionTypeEntity {
  free,
  oneMonth,
  threeMonths,
  sixMonths,
}

class SubscriptionEntity {
  final SubscriptionTypeEntity type;
  final DateTime? startDate;
  final DateTime? endDate;

  const SubscriptionEntity({
    required this.type,
    this.startDate,
    this.endDate,
  });

  bool get isActive {
    if (endDate == null) return false;
    return endDate!.isAfter(DateTime.now());
  }
}