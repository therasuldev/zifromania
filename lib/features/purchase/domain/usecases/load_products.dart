import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';
import 'package:zifromania/features/purchase/domain/repositories/store_repository.dart';

class LoadProductsUseCase {
  LoadProductsUseCase({required this.repository});

  final StoreRepository repository;

  Future<List<StoreProductEntity>> call() {
    return repository.loadProducts();
  }
}
