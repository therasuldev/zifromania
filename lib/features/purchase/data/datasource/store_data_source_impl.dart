import 'package:in_app_purchase/in_app_purchase.dart';
import 'store_datasource.dart';

class StoreDataSourceImpl implements StoreDataSource {
  StoreDataSourceImpl({
    InAppPurchase? inAppPurchase,
  }) : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  static const Set<String> _productIds = {
    '100_coin',
    '550_coin',
    '1200_coin',
    '5000_coin',
    'subscription_monthly',
    'subscription_quarterly',
    'subscription_semiannual',
  };

  @override
  Future<bool> isAvailable() {
    return _inAppPurchase.isAvailable();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream {
    return _inAppPurchase.purchaseStream;
  }

  @override
  Future<List<ProductDetails>> loadProducts() async {
    final response = await _inAppPurchase.queryProductDetails(
      _productIds,
    );

    if (response.error != null) {
      throw Exception(
        response.error!.message,
      );
    }

    return response.productDetails;
  }

  @override
  Future<bool> buyProduct(String productId) async {
    final response = await _inAppPurchase.queryProductDetails(
      {productId},
    );

    if (response.productDetails.isEmpty) {
      throw Exception(
        'Product not found',
      );
    }

    final product = response.productDetails.first;

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    if (productId.startsWith('subscription_')) {
      return _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    }

    return _inAppPurchase.buyConsumable(
      purchaseParam: purchaseParam,
    );
  }

  @override
  Future<void> restorePurchases() {
    return _inAppPurchase.restorePurchases();
  }
}
