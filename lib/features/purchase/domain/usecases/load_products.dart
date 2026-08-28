import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';
import 'package:zifromania/features/purchase/domain/repositories/purchase_repository.dart';

class LoadProductsUseCase {
  LoadProductsUseCase({required this.repository});

  final PurchaseRepository repository;

  Future<List<StoreProductEntity>> call() {
    return repository.loadProducts();
  }
}
