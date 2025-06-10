// purchase_models.dart
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionPlan {
  final String id;
  final String title;
  final String description;
  final double price;
  final String period;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
  });

  factory SubscriptionPlan.fromProductDetails(ProductDetails product) {
    final period = product.id.contains('monthly') ? 'Monthly' : 'Yearly';
    return SubscriptionPlan(
      id: product.id,
      title: product.title,
      description: product.description,
      price: double.parse(product.price.replaceAll(RegExp(r'[^0-9.]'), '')),
      period: period,
    );
  }
}

class CoinPack {
  final String id;
  final String title;
  final String description;
  final double price;
  final int coins;
  final bool isPopular;

  const CoinPack({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.coins,
    this.isPopular = false,
  });

  factory CoinPack.fromProductDetails(ProductDetails product, {bool isPopular = false}) {
    final coins = int.parse(product.id.split('_')[1]);
    return CoinPack(
      id: product.id,
      title: product.title,
      description: product.description,
      price: double.parse(product.price.replaceAll(RegExp(r'[^0-9.]'), '')),
      coins: coins,
      isPopular: isPopular,
    );
  }
}
