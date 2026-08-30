import 'package:zifromania/features/purchase/domain/repositories/store_repository.dart';

class BuyProductUseCase {
  BuyProductUseCase({required this.repository});

  final StoreRepository repository;

  Future<bool> call(String productId) {
    return repository.buyProduct(productId);
  }
}
