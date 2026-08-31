import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:zifromania/features/purchase/data/datasource/store_data_source_impl.dart';
import 'package:zifromania/features/user/user_module.dart';

import 'data/datasource/store_datasource.dart';
import 'data/repositories/store_repository_impl.dart';
import 'domain/repositories/store_repository.dart';
import 'domain/usecases/activate_subscription.dart';
import 'domain/usecases/buy_product.dart';
import 'domain/usecases/deliver_coins.dart';
import 'domain/usecases/listen_purchase_updates_usecase.dart';
import 'domain/usecases/load_products.dart';
import 'domain/usecases/restore_purchases.dart';

final iapProvider = Provider<InAppPurchase>((ref) {
  return InAppPurchase.instance;
});

final storeDataSourceProvider = Provider<StoreDataSource>((ref) {
  return StoreDataSourceImpl(inAppPurchase: ref.watch(iapProvider));
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepositoryImpl(storeDataSource: ref.watch(storeDataSourceProvider));
});

final activateSubscriptionUseCaseProvider = Provider<ActivateSubscriptionUseCase>((ref) {
  return ActivateSubscriptionUseCase(repository: ref.watch(subscriptionRepositoryProvider));
});

final buyProductUseCaseProvider = Provider<BuyProductUseCase>((ref) {
  return BuyProductUseCase(repository: ref.watch(storeRepositoryProvider));
});

final deliverCoinsUseCaseProvider = Provider<DeliverCoinsUseCase>((ref) {
  return DeliverCoinsUseCase(repository: ref.watch(userRepositoryProvider));
});

final listenPurchaseUpdatesUseCaseProvider = Provider<ListenPurchaseUpdatesUseCase>((ref) {
  return ListenPurchaseUpdatesUseCase(repository: ref.watch(storeRepositoryProvider));
});

final loadProductsUseCaseProvider = Provider<LoadProductsUseCase>((ref) {
  return LoadProductsUseCase(repository: ref.watch(storeRepositoryProvider));
});

final restorePurchasesUseCaseProvider = Provider<RestorePurchasesUseCase>((ref) {
  return RestorePurchasesUseCase(repository: ref.watch(storeRepositoryProvider));
});
