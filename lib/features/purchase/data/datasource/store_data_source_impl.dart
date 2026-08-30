import 'package:in_app_purchase/in_app_purchase.dart';
import 'store_datasource.dart';

class StoreDataSourceImpl implements StoreDataSource {
  StoreDataSourceImpl({required this.inAppPurchase});

  final InAppPurchase inAppPurchase;

  static const Set<String> _productIds = {
    '100_coin',
    '550_coin',
    '1200_coin',
    '5000_coin',
  };

  @override
  Future<bool> isAvailable() {
    return inAppPurchase.isAvailable();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream {
    return inAppPurchase.purchaseStream;
  }

  @override
  Future<List<ProductDetails>> loadProducts() async {
    final response = await inAppPurchase.queryProductDetails(_productIds);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    return response.productDetails;
  }

  @override
  Future<bool> buyProduct(String productId) async {
    final response = await inAppPurchase.queryProductDetails({productId});

    if (response.productDetails.isEmpty) {
      throw Exception('Product not found');
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);

    return inAppPurchase.buyConsumable(
      purchaseParam: purchaseParam,
    );
  }

  @override
  Future<void> restorePurchases() {
    return inAppPurchase.restorePurchases();
  }
}
