import 'package:zifromania/features/purchase/domain/entities/purchase_result_entity.dart';
import 'package:zifromania/features/purchase/domain/repositories/store_repository.dart';

class CompletePurchaseUseCase {
  const CompletePurchaseUseCase({required this.repository});

  final StoreRepository repository;

  Future<void> call(PurchaseEntity purchase) {
    return repository.completePurchase(purchase);
  }
}
