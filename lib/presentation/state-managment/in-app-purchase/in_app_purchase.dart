import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zifromania/services/in_app_purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meta/meta.dart';

// События
@immutable
abstract class PurchaseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Инициализация
class InitializePurchase extends PurchaseEvent {}

// Загрузка продуктов
class LoadProducts extends PurchaseEvent {}

// Покупка продукта
class BuyProduct extends PurchaseEvent {
  final ProductDetails product;

  BuyProduct(this.product);

  @override
  List<Object?> get props => [product];
}

// Проверка подписок
class CheckSubscriptions extends PurchaseEvent {}

// Восстановление покупок
class RestorePurchases extends PurchaseEvent {}

// Состояния
@immutable
abstract class PurchaseState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Начальное состояние
class PurchaseInitial extends PurchaseState {}

// Загрузка
class PurchaseLoading extends PurchaseState {}

// Продукты загружены
class ProductsLoaded extends PurchaseState {
  final List<StoreProduct> products;
  final List<StoreProduct> subscriptions;
  final List<StoreProduct> coinProducts;
  final bool hasActiveSubscription;

  ProductsLoaded({
    required this.products,
    required this.subscriptions,
    required this.coinProducts,
    required this.hasActiveSubscription,
  });

  @override
  List<Object?> get props => [products, subscriptions, coinProducts, hasActiveSubscription];
}

// В процессе покупки
class PurchaseInProgress extends PurchaseState {}

// Покупка успешно завершена
class PurchaseSuccess extends PurchaseState {
  final PurchaseDetails purchaseDetails;

  PurchaseSuccess(this.purchaseDetails);

  @override
  List<Object?> get props => [purchaseDetails];
}

// Ошибка покупки
class PurchaseError extends PurchaseState {
  final String message;

  PurchaseError(this.message);

  @override
  List<Object?> get props => [message];
}

// Отмена покупки
class PurchaseCanceled extends PurchaseState {}

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final InAppPurchaseService _purchaseService;
  StreamSubscription? _productsSubscription;
  StreamSubscription? _purchaseSubscription;

  PurchaseBloc({required InAppPurchaseService purchaseService})
      : _purchaseService = purchaseService,
        super(PurchaseInitial()) {
    on<InitializePurchase>(_onInitializePurchase);
    on<LoadProducts>(_onLoadProducts);
    on<BuyProduct>(_onBuyProduct);
    on<CheckSubscriptions>(_onCheckSubscriptions);
    on<RestorePurchases>(_onRestorePurchases);

    // Listen to product updates
    _productsSubscription = _purchaseService.productsStream.listen((products) {
      add(LoadProducts());
    });

    // Listen to purchase updates
    _purchaseSubscription = _purchaseService.purchaseStream.listen((result) {
      if (result.status == PurchaseStatus.pending) {
        emit(PurchaseInProgress());
      } else if (result.status == PurchaseStatus.purchased) {
        emit(PurchaseSuccess(result.purchaseDetails!));
        // Check for subscription changes
        add(CheckSubscriptions());
      } else if (result.status == PurchaseStatus.error) {
        emit(PurchaseError(result.message ?? 'Unknown error'));
      } else if (result.status == PurchaseStatus.canceled) {
        emit(PurchaseCanceled());
      }
    });
  }

  Future<void> _onInitializePurchase(
    InitializePurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    await _purchaseService.init();
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(ProductsLoaded(
      products: _purchaseService.products,
      subscriptions: _purchaseService.subscriptions,
      coinProducts: _purchaseService.coinProducts,
      hasActiveSubscription: _purchaseService.hasActiveSubscription,
    ));
  }

  Future<void> _onBuyProduct(
    BuyProduct event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    await _purchaseService.buyProduct(event.product);
  }

  Future<void> _onCheckSubscriptions(
    CheckSubscriptions event,
    Emitter<PurchaseState> emit,
  ) async {
    await _purchaseService.checkActiveSubscriptions();
    add(LoadProducts());
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    await _purchaseService.restorePurchases();
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    _purchaseSubscription?.cancel();
    _purchaseService.dispose();
    return super.close();
  }
}
