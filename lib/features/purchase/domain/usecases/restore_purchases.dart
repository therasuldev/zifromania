import 'package:zifromania/features/purchase/domain/repositories/purchase_repository.dart';

class RestorePurchasesUseCase {
  RestorePurchasesUseCase({required this.repository});

  final PurchaseRepository repository;

  Future<void> call() {
    return repository.restorePurchases();
  }
}
