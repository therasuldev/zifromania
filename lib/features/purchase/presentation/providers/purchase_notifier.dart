import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:zifromania/features/auth/auth_module.dart';
import 'package:zifromania/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:zifromania/features/purchase/domain/entities/purchase_result_entity.dart';
import 'package:zifromania/features/purchase/domain/usecases/buy_product.dart';
import 'package:zifromania/features/purchase/domain/usecases/deliver_coins.dart';
import 'package:zifromania/features/purchase/domain/usecases/listen_purchase_updates_usecase.dart';
import 'package:zifromania/features/purchase/domain/usecases/load_products.dart';
import 'package:zifromania/features/purchase/domain/usecases/restore_purchases.dart';
import 'package:zifromania/features/purchase/presentation/providers/state/purchase_state.dart';
import 'package:zifromania/features/purchase/purchase_module.dart';

class PurchaseNotifier extends Notifier<PurchaseState> {
  StreamSubscription<PurchaseEntity>? _purchaseSubscription;

  @override
  PurchaseState build() {
    ref.onDispose(() {
      _purchaseSubscription?.cancel();
    });

    _init();
    return const PurchaseState();
  }

  // Dependent use-case-ləri ref vasitəsilə provider-lərdən götürmək tövsiyə olunur:
  LoadProductsUseCase get _loadProductsUseCase => ref.read(loadProductsUseCaseProvider);
  BuyProductUseCase get _buyProductUseCase => ref.read(buyProductUseCaseProvider);
  RestorePurchasesUseCase get _restorePurchasesUseCase => ref.read(restorePurchasesUseCaseProvider);
  ListenPurchaseUpdatesUseCase get _listenPurchaseUpdatesUseCase => ref.read(listenPurchaseUpdatesUseCaseProvider);
  DeliverCoinsUseCase get _deliverCoinsUseCase => ref.read(deliverCoinsUseCaseProvider);
  GetCurrentUserUseCase get _getCurrentUserUseCase => ref.read(getCurrentUserUseCaseProvider);

  void _init() {
    loadProducts();
    _listenToPurchases();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final products = await _loadProductsUseCase();
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load products: $e',
      );
    }
  }

  void _listenToPurchases() {
    _purchaseSubscription = _listenPurchaseUpdatesUseCase().listen(
      (purchase) async {
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          await _handleSuccessfulPurchase(purchase.productId);
        } else if (purchase.status == PurchaseStatus.error) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'An error occurred during payment.',
          );
        } else if (purchase.status == PurchaseStatus.pending) {
          state = state.copyWith(isLoading: true);
        }
      },
      onError: (dynamic error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> buyProduct(String productId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _buyProductUseCase(productId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initiate purchase: $e',
      );
    }
  }

  Future<void> _handleSuccessfulPurchase(String productId) async {
    final coinAmount = _getCoinAmountFromId(productId);

    if (coinAmount > 0) {
      try {
        final currentUser = await _getCurrentUserUseCase();

        if (currentUser == null) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'User is not authenticated.',
          );
          return;
        }

        await _deliverCoinsUseCase(uid: currentUser.uid, amount: coinAmount);

        state = state.copyWith(
          isLoading: false,
          successMessage: '$coinAmount coins successfully added to your balance!',
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to deliver coins: $e',
        );
      }
    }
  }

  int _getCoinAmountFromId(String productId) {
    switch (productId) {
      case '100_coin':
        return 100;
      case '550_coin':
        return 550;
      case '1200_coin':
        return 1200;
      case '5000_coin':
        return 5000;
      default:
        return 0;
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      await _restorePurchasesUseCase();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to restore purchases: $e',
      );
    }
  }
}

// Provider təyini:
final purchaseNotifierProvider = NotifierProvider<PurchaseNotifier, PurchaseState>(
  PurchaseNotifier.new,
);
