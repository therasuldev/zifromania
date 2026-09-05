import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';

class SubscriptionPlan {
  final String productId;
  final String title;
  final double staticPrice; // store yüklənməyibsə fallback qiymət
  final int duration; // in months
  final List<String> features;
  final bool mostPopular;
  final int savePercentage;
  final StoreProductEntity? productDetails;

  SubscriptionPlan({
    required this.productId,
    required this.title,
    required this.staticPrice,
    required this.duration,
    required this.features,
    required this.mostPopular,
    required this.savePercentage,
    this.productDetails,
  });

  // Store yüklənəndə real, lokallaşdırılmış qiymət mətnini göstərir
  // (məs. "$4.99" AŞB-də, "4,99 ₼" Azərbaycanda və s.).
  String get priceLabel => productDetails?.price ?? '\$${staticPrice.toStringAsFixed(2)}';

  SubscriptionPlan copyWithProduct(StoreProductEntity? details) => SubscriptionPlan(
        productId: productId,
        title: title,
        staticPrice: staticPrice,
        duration: duration,
        features: features,
        mostPopular: mostPopular,
        savePercentage: savePercentage,
        productDetails: details,
      );
}
