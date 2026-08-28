import 'package:zifromania/features/purchase/domain/repositories/purchase_repository.dart';

class BuyProductUseCase {
  BuyProductUseCase({required this.repository});

  final PurchaseRepository repository;

  Future<bool> call(String productId) {
    return repository.buyProduct(productId);
  }
}
