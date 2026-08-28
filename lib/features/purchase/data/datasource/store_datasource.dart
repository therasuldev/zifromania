import 'package:in_app_purchase/in_app_purchase.dart';

abstract interface class StoreDataSource {
  Future<bool> isAvailable();

  Future<List<ProductDetails>> loadProducts();

  Future<bool> buyProduct(String productId);

  Future<void> restorePurchases();

  Stream<List<PurchaseDetails>> get purchaseStream;
}
