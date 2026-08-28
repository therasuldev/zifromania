import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseEntity {
  final String productId;
  final String? purchaseId;
  final PurchaseStatus status;

  const PurchaseEntity({
    required this.productId,
    required this.purchaseId,
    required this.status,
  });
}
