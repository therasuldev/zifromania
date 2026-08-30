// domain/usecases/listen_purchase_updates_usecase.dart

import 'package:zifromania/features/purchase/domain/entities/purchase_result_entity.dart';
import 'package:zifromania/features/purchase/domain/repositories/store_repository.dart';

class ListenPurchaseUpdatesUseCase {
  ListenPurchaseUpdatesUseCase({required this.repository});

  final StoreRepository repository;

  Stream<PurchaseEntity> call() {
    return repository.watchPurchases();
  }
}
