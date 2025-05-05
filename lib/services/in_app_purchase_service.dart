import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

// Yaradacağımız ProductDetails obyektlərini saxlamaq üçün sinif
class StoreProduct {
  final ProductDetails productDetails;
  final ProductType productType;

  StoreProduct({required this.productDetails, required this.productType});
}

// Məhsul növləri
enum ProductType {
  subscription,
  consumable,
}

// Ödəniş nəticəsi
class PurchaseResult {
  final PurchaseStatus status;
  final String? message;
  final PurchaseDetails? purchaseDetails;

  const PurchaseResult({
    required this.status,
    this.message,
    this.purchaseDetails,
  });
}

class InAppPurchaseService {
  // Singleton pattern tətbiqi
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Abunəlik ID-ləri
  final List<String> _subscriptionIds = [
    'subscription_monthly', // Aylıq - 4.99$
    'subscription_quarterly', // 3 aylıq - 9.99$
    'subscription_annual', // 12 aylıq - 29.99$
  ];

  // Coin paketləri ID-ləri
  final List<String> _coinProductIds = [
    'coins_100', // 100 coin - 0.99$
    'coins_500', // 500 coin (+50 bonus) - 3.99$
    'coins_1200', // 1200 coin (+200 bonus) - 7.99$
    'coins_2500', // 2500 coin (+500 bonus) - 14.99$
  ];

  // Bütün məhsulların siyahısı
  List<String> get _storeProductIds => [..._subscriptionIds, ..._coinProductIds];

  // Əldə edilmiş məhsullar
  List<StoreProduct> _products = [];
  List<StoreProduct> get products => _products;

  // Stream controllerlər
  final StreamController<List<StoreProduct>> _productsController = StreamController<List<StoreProduct>>.broadcast();
  Stream<List<StoreProduct>> get productsStream => _productsController.stream;

  final StreamController<PurchaseResult> _purchaseController = StreamController<PurchaseResult>.broadcast();
  Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  // Abunəlik məhsulları
  List<StoreProduct> get subscriptions =>
      _products.where((product) => _subscriptionIds.contains(product.productDetails.id)).toList();

  // Coin məhsulları
  List<StoreProduct> get coinProducts =>
      _products.where((product) => _coinProductIds.contains(product.productDetails.id)).toList();

  // Abunəlik aktiv olub olmadığını yoxlamaq üçün
  bool _hasActiveSubscription = false;
  bool get hasActiveSubscription => _hasActiveSubscription;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // İlkin yükləmə və quraşdırma
  Future<void> init() async {
    final bool available = await _inAppPurchase.isAvailable();

    if (!available) {
      _products = [];
      _productsController.add([]);
      return;
    }

    // Platform spesifik quraşdırmalar
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(IOSPaymentQueueDelegate());
    }

    // Satın almaları dinləyən
    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.error,
            message: error.toString(),
          ),
        );
      },
    );

    // Məhsulları yüklə
    await loadProducts();

    // Aktiv abunəlikləri yoxla
    await checkActiveSubscriptions();
  }

  // Məhsulları yükləmək
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_storeProductIds.toSet());

      if (response.error != null) {
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.error,
            message: 'Məhsul məlumatları yüklənə bilmədi: ${response.error}',
          ),
        );
        return;
      }

      if (response.productDetails.isEmpty) {
        _purchaseController.add(
          const PurchaseResult(
            status: PurchaseStatus.error,
            message: 'Məhsul tapılmadı',
          ),
        );
        return;
      }

      _products = response.productDetails.map((details) {
        final isSubscription = _subscriptionIds.contains(details.id);
        return StoreProduct(
          productDetails: details,
          productType: isSubscription ? ProductType.subscription : ProductType.consumable,
        );
      }).toList();

      _productsController.add(_products);
    } catch (e) {
      _purchaseController.add(
        PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Məhsul yüklənməsində xəta: ${e.toString()}',
        ),
      );
    }
  }

  // Məhsul satın alma
  Future<bool> buyProduct(ProductDetails product) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );

      // Abunəlik və ya birdəfəlik satınalma əməliyyatı
      bool success = false;
      if (_subscriptionIds.contains(product.id)) {
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }

      return success;
    } catch (e) {
      _purchaseController.add(
        PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Satınalma zamanı xəta: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  // Satınalmaları dinləmək
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.pending,
            purchaseDetails: purchaseDetails,
          ),
        );
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.error,
            message: purchaseDetails.error?.message ?? 'Naməlum xəta',
            purchaseDetails: purchaseDetails,
          ),
        );
      } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.canceled,
            purchaseDetails: purchaseDetails,
          ),
        );
      }

      // Bitmiş satınalmaları tamamla
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Satınalmanı yoxlamaq (server tərəfində də yoxlama etmək tövsiyə olunur)
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Real tətbiqdə, burada server tərəfində doğrulama etməlisiniz
    // Təhlükəsizlik üçün satınalma qəbzi serverdə yoxlanılmalıdır

    final bool isSubscription = _subscriptionIds.contains(purchaseDetails.productID);

    if (isSubscription) {
      _hasActiveSubscription = true;
      // Abunəliyin başlama və bitmə tarixlərini saxlayın
    }

    _purchaseController.add(
      PurchaseResult(
        status: PurchaseStatus.purchased,
        purchaseDetails: purchaseDetails,
      ),
    );
  }

  // Aktiv abunəlikləri yoxlamaq
  Future<void> checkActiveSubscriptions() async {
    // Əməliyyat sistemindən asılı olaraq aktiv abunəlikləri yoxlayın
    try {
      if (Platform.isAndroid) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

        final QueryPurchaseDetailsResponse response = await androidAddition.queryPastPurchases();

        if (response.error != null) {
          print('Keçmiş satınalmaları yoxlama xətası: ${response.error}');
          return;
        }

        for (final PurchaseDetails purchase in response.pastPurchases) {
          if (_subscriptionIds.contains(purchase.productID)) {
            // Abunəliyin aktiv olub olmadığını yoxlayın
            // (Əlavə məntiq lazım ola bilər - bitmə tarixini yoxlamaq və s.)
            _hasActiveSubscription = true;
            break;
          }
        }
      } else if (Platform.isIOS) {
        // iOS üçün aktiv abunəlikləri yoxlama
        await restorePurchases();
      }
    } catch (e) {
      print('Abunəlikləri yoxlayarkən xəta: $e');
    }
  }

  // Əvvəlki satınalmaları bərpa etmək
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _purchaseController.add(
        PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Satınalmaları bərpa edərkən xəta: ${e.toString()}',
        ),
      );
    }
  }

  // Resursları azad etmək
  void dispose() {
    _subscription?.cancel();
    _productsController.close();
    _purchaseController.close();
  }
}

// iOS üçün ödəniş növbəsi delegatı
class IOSPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return true;
  }
}
