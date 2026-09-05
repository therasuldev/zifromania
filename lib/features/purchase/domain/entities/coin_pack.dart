import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';

class CoinPack {
  final String productId;
  final int amount;
  final int bonus;
  final double staticPrice;
  final String? specialOffer;
  final StoreProductEntity? productDetails;

  CoinPack({
    required this.productId,
    required this.amount,
    this.bonus = 0,
    required this.staticPrice,
    this.specialOffer,
    this.productDetails,
  });

  String get priceLabel => productDetails?.price ?? '\$${staticPrice.toStringAsFixed(2)}';

  CoinPack copyWithProduct(StoreProductEntity? details) => CoinPack(
        productId: productId,
        amount: amount,
        bonus: bonus,
        staticPrice: staticPrice,
        specialOffer: specialOffer,
        productDetails: details,
      );
}
