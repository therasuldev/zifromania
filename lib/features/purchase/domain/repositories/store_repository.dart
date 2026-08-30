import 'package:zifromania/features/purchase/domain/entities/purchase_result_entity.dart';
import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';

abstract interface class StoreRepository {
  Future<bool> isAvailable();

  Future<List<StoreProductEntity>> loadProducts();

  Future<bool> buyProduct(String productId);

  Future<void> restorePurchases();

  Stream<PurchaseEntity> watchPurchases();
}
