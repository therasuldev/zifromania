import 'package:zifromania/features/purchase/domain/repositories/store_repository.dart';

class RestorePurchasesUseCase {
  RestorePurchasesUseCase({required this.repository});

  final StoreRepository repository;

  Future<void> call() {
    return repository.restorePurchases();
  }
}
