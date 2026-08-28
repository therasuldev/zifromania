import 'package:zifromania/features/purchase/data/datasource/store_datasource.dart';
import 'package:zifromania/features/purchase/domain/entities/purchase_result_entity.dart';
import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';
import 'package:zifromania/features/purchase/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  const PurchaseRepositoryImpl({
    required this.storeDataSource,
  });

  final StoreDataSource storeDataSource;

  @override
  Future<bool> isAvailable() {
    return storeDataSource.isAvailable();
  }

  @override
  Future<List<StoreProductEntity>> loadProducts() async {
    final products = await storeDataSource.loadProducts();

    return products
        .map(
          (product) => StoreProductEntity(
            id: product.id,
            title: product.title,
            description: product.description,
            price: product.price,
            isSubscription: _isSubscription(product.id),
          ),
        )
        .toList();
  }

  @override
  Future<bool> buyProduct(String productId) async {
    final products = await storeDataSource.loadProducts();

    final product = products.firstWhere(
      (e) => e.id == productId,
    );

    return storeDataSource.buy(product);
  }

  @override
  Future<void> restorePurchases() {
    return storeDataSource.restorePurchases();
  }

  @override
  Stream<PurchaseEntity> watchPurchases() {
    return storeDataSource.purchaseStream.expand(
      (purchaseList) => purchaseList.map(
        (purchase) => PurchaseEntity(
          productId: purchase.productID,
          purchaseId: purchase.purchaseID,
          status: purchase.status,
        ),
      ),
    );
  }

  bool _isSubscription(String productId) {
    return productId.startsWith('subscription_');
  }
}
