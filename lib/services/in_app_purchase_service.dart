import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'user_service.dart';
import 'package:zifromania/models/subscription_model.dart';

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
  // QEYD: Bu servis artıq GetIt tərəfindən `registerLazySingleton` ilə
  // idarə olunur (services_init.dart), ona görə burada AYRICA daxili
  // singleton pattern (factory + static _instance) SAXLANILMIR — ikisi
  // birlikdə olsa, GetIt-ə ötürdüyünüz `userService` parametri əslində
  // effektsiz qala bilərdi.
  //
  // İstifadəçiyə coin/abunəlik çatdırmaq üçün UserService injection edilir.
  // Öz UserService-inizdəki metod adları fərqlidirsə (aşağıdakı
  // `_deliverCoins` / `_activateSubscription` funksiyalarında), onları öz
  // metodlarınızın adı ilə əvəzləyin.
  InAppPurchaseService({required UserService userService}) : _userService = userService;

  final UserService _userService;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Coin ID-si → çatdırılacaq coin miqdarı (bonuslar daxil).
  // Play Console-dakı əsl qiymət/miqdarlarla üst-üstə düşməlidir.
  static const Map<String, int> _coinAmountByProductId = {
    '100_coin': 100,
    '550_coin': 550, // 500 + 50 bonus
    '1200_coin': 1200, // 1000 + 200 bonus
    '5000_coin': 5000, // 3000 + 2000 bonus
  };

  // Abunəlik ID-si → (SubscriptionType, müddət). Öz Play Console/App Store
  // ID-lərinizlə uyğunlaşdırın (_subscriptionIds siyahısı ilə eyni olmalıdır).
  static const Map<String, ({SubscriptionType type, Duration duration})> _subscriptionPlanByProductId = {
    'subscription_monthly': (type: SubscriptionType.oneMonth, duration: Duration(days: 30)),
    'subscription_quarterly': (type: SubscriptionType.threeMonths, duration: Duration(days: 90)),
    'subscription_semiannual': (type: SubscriptionType.sixMonths, duration: Duration(days: 180)),
  };

  // ⚠️ ABUNƏLİK ID-LƏRİ: bunlar Google Play Console / App Store Connect-dəki
  // ƏSL məhsul ID-ləri ilə EYNİ olmalıdır. Screenshot-da yalnız coin cədvəlini
  // gördüm, subscription ID-lərini öz konsolunuzdan yoxlayıb bura yazın.
  final List<String> _subscriptionIds = [
    'subscription_monthly',   // 1 Ay - $4.99
    'subscription_quarterly', // 3 Ay - $9.99
    'subscription_semiannual', // 6 Ay - $17.99
  ];

  // Coin paketləri ID-ləri — Play Console-dakı əsl ID-lərlə uyğunlaşdırıldı
  final List<String> _coinProductIds = [
    '100_coin',  // 100 coin - $0.99
    '550_coin',  // 500 coin (+50 bonus) - $4.99
    '1200_coin', // 1200 coin (+200 bonus) - $9.99
    '5000_coin', // 5000 coin (+2000 bonus) - $39.99
  ];

  // Bütün məhsulların siyahısı
  List<String> get _storeProductIds => [..._subscriptionIds, ..._coinProductIds];

  // Əldə edilmiş məhsullar
  List<StoreProduct> _products = [];
  List<StoreProduct> get products => List.unmodifiable(_products);

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Stream controllerlər
  final StreamController<List<StoreProduct>> _productsController =
      StreamController<List<StoreProduct>>.broadcast();
  Stream<List<StoreProduct>> get productsStream => _productsController.stream;

  final StreamController<PurchaseResult> _purchaseController =
      StreamController<PurchaseResult>.broadcast();
  Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  // Abunəlik məhsulları
  List<StoreProduct> get subscriptions =>
      _products.where((p) => _subscriptionIds.contains(p.productDetails.id)).toList();

  // Coin məhsulları
  List<StoreProduct> get coinProducts =>
      _products.where((p) => _coinProductIds.contains(p.productDetails.id)).toList();

  // Abunəlik aktiv olub olmadığını yoxlamaq üçün
  bool _hasActiveSubscription = false;
  bool get hasActiveSubscription => _hasActiveSubscription;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Eyni satınalmanın iki dəfə işlənməsinin qarşısını almaq üçün
  final Set<String> _processingPurchaseIds = {};

  bool _initialized = false;

  // İlkin yükləmə və quraşdırma
  Future<void> init() async {
    if (_initialized) return; // ikiqat init-in qarşısını al
    _initialized = true;

    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      _products = [];
      _productsController.add([]);
      _purchaseController.add(
        const PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Store əlçatan deyil (isAvailable=false). Cihazda mağaza girişini yoxlayın.',
        ),
      );
      return;
    }

    // Platform spesifik quraşdırmalar
    if (Platform.isIOS) {
      final iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(IOSPaymentQueueDelegate());
    }

    // Satın almaları dinləyən - init başında bir dəfə qoşulmalıdır
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

    // Aktiv abunəlikləri yoxla (yalnız keçmiş satınalmalardan işarə üçün;
    // etibarlı status üçün server-side yoxlama tövsiyə olunur - aşağıya bax)
    await checkActiveSubscriptions();
  }

  // Məhsulları yükləmək
  Future<void> loadProducts() async {
    _isLoading = true;
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_storeProductIds.toSet());

      if (response.error != null) {
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.error,
            message: 'Məhsul məlumatları yüklənə bilmədi: ${response.error}',
          ),
        );
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        // Bu, ən çox rast gəlinən istehsalat xətasıdır: kod ilə store
        // arasında ID uyğunsuzluğu. Konsolla mütləq müqayisə edin.
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.error,
            message: 'Store-da tapılmayan ID-lər: ${response.notFoundIDs.join(", ")}',
          ),
        );
      }

      if (response.productDetails.isEmpty) {
        _purchaseController.add(
          const PurchaseResult(
            status: PurchaseStatus.error,
            message: 'Məhsul tapılmadı',
          ),
        );
        _products = [];
        _productsController.add(_products);
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
    } finally {
      _isLoading = false;
    }
  }

  // Məhsul satın alma
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      _purchaseController.add(
        const PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Store əlçatan deyil',
        ),
      );
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );

      if (_subscriptionIds.contains(product.id)) {
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
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

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      final String purchaseKey = purchaseDetails.purchaseID ??
          '${purchaseDetails.productID}_${purchaseDetails.transactionDate}';

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _purchaseController.add(
            PurchaseResult(
              status: PurchaseStatus.pending,
              purchaseDetails: purchaseDetails,
            ),
          );
          break;

        case PurchaseStatus.error:
          _purchaseController.add(
            PurchaseResult(
              status: PurchaseStatus.error,
              message: purchaseDetails.error?.message ?? 'Naməlum xəta',
              purchaseDetails: purchaseDetails,
            ),
          );
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Eyni transaction-un iki dəfə işlənməsinin qarşısını al
          if (!_processingPurchaseIds.contains(purchaseKey)) {
            _processingPurchaseIds.add(purchaseKey);
            await _verifyAndDeliverPurchase(purchaseDetails);
            _processingPurchaseIds.remove(purchaseKey);
          }
          break;

        case PurchaseStatus.canceled:
          _purchaseController.add(
            PurchaseResult(
              status: PurchaseStatus.canceled,
              purchaseDetails: purchaseDetails,
            ),
          );
          break;
      }

      // Bitmiş satınalmaları tamamla (bu addım OLMASA, App Store/Play
      // eyni transaction-u təkrar-təkrar göndərəcək)
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Satınalmanı yoxlamaq və məhsulu istifadəçiyə çatdırmaq
  //
  // ⚠️ VACIB: Bu metod hazırda LOKAL olaraq "purchased" statusunu qəbul edir.
  // Production-da bu, saxta/manipulyasiya edilmiş satınalmalara qarşı
  // qorunmasızdır. Əsl production axını belə olmalıdır:
  //   1) purchaseDetails.verificationData.serverVerificationData
  //      (App Store: base64 receipt / Play: purchaseToken) öz backend-inizə göndərin
  //   2) Backend Apple/Google-un rəsmi API-si ilə receipt-i doğrulasın
  //      (Play: Purchases.products.get / Purchases.subscriptions.get,
  //       App Store: App Store Server API)
  //   3) Backend təsdiq versə, coin/abunəlik statusunu backend-də (DB-də) yeniləyin
  //   4) Yalnız backend təsdiqindən sonra UI-da coin/abunəlik göstərin
  //
  // Aşağıdakı `_verifyOnBackend` funksiyasını öz API endpoint-inizə qoşun.
  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchaseDetails) async {
    final bool isSubscription = _subscriptionIds.contains(purchaseDetails.productID);
    final bool isCoinPack = _coinProductIds.contains(purchaseDetails.productID);

    try {
      final bool verified = await _verifyOnBackend(purchaseDetails);

      if (!verified) {
        _purchaseController.add(
          PurchaseResult(
            status: PurchaseStatus.error,
            message: 'Satınalma doğrulanmadı',
            purchaseDetails: purchaseDetails,
          ),
        );
        return;
      }

      if (isSubscription) {
        await _activateSubscription(purchaseDetails.productID);
      } else if (isCoinPack) {
        await _deliverCoins(purchaseDetails.productID);
      }

      _purchaseController.add(
        PurchaseResult(
          status: PurchaseStatus.purchased,
          purchaseDetails: purchaseDetails,
        ),
      );
    } catch (e) {
      _purchaseController.add(
        PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Doğrulama zamanı xəta: ${e.toString()}',
          purchaseDetails: purchaseDetails,
        ),
      );
    }
  }

  // Coin balansını istifadəçiyə çatdırır.
  Future<void> _deliverCoins(String productId) async {
    final int amount = _coinAmountByProductId[productId] ?? 0;
    if (amount <= 0) return;

    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _purchaseController.add(
        const PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Coin çatdırıla bilmədi: istifadəçi giriş etməyib',
        ),
      );
      return;
    }

    await _userService.addCoins(uid, amount);
  }

  // Abunəliyi aktivləşdirir: plan tipini müəyyən edir, başlanğıc/bitmə
  // tarixini hesablayır və SubscriptionModel-i Firestore-a yazır.
  //
  // ⚠️ QEYD: Yenilənən (auto-renewing) abunəliklərdə endDate hər dəfə
  // "indi + müddət" kimi hesablanır. Bu, yalnız İLK alışda dəqiqdir —
  // avtomatik yenilənmələrdə real bitmə tarixini almaq üçün Play/App Store
  // Server Notifications ilə backend-dən yeniləmə tövsiyə olunur, əks halda
  // istifadəçi tətbiqi açmasa status köhnəlmiş qala bilər.
  Future<void> _activateSubscription(String productId) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _purchaseController.add(
        const PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Abunəlik aktivləşdirilə bilmədi: istifadəçi giriş etməyib',
        ),
      );
      return;
    }

    final plan = _subscriptionPlanByProductId[productId];
    if (plan == null) {
      _purchaseController.add(
        PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Naməlum abunəlik ID-si: $productId',
        ),
      );
      return;
    }

    final now = DateTime.now();
    final subscription = SubscriptionModel(
      type: plan.type,
      startDate: Timestamp.fromDate(now),
      endDate: Timestamp.fromDate(now.add(plan.duration)),
    );

    _hasActiveSubscription = true;
    await _userService.updateSubscriptionDetails(uid, subscription);
  }

  // Backend receipt doğrulaması üçün yer tutucu.
  // Öz API-nizi (məs. POST /verify-purchase) buraya qoşun və server
  // cavabına əsasən true/false qaytarın. Backend hazır deyilsə, inkişaf
  // mərhələsində müvəqqəti `true` qaytara bilərsiniz, amma bunu production-a
  // buraxmadan əvvəl mütləq real doğrulama ilə əvəzləyin.
  Future<bool> _verifyOnBackend(PurchaseDetails purchaseDetails) async {
    // TODO: real backend çağırışı ilə əvəz edin, məsələn:
    //
    // final response = await http.post(
    //   Uri.parse('https://YOUR_API/verify-purchase'),
    //   body: {
    //     'platform': Platform.isIOS ? 'ios' : 'android',
    //     'productId': purchaseDetails.productID,
    //     'token': purchaseDetails.verificationData.serverVerificationData,
    //   },
    // );
    // return response.statusCode == 200;

    return true;
  }

  // Aktiv abunəlikləri yoxlamaq
  //
  // QEYD: Bu, yalnız "keçmişdə bu ID alınıb" deməkdir — bitmə/yenilənmə
  // tarixini əks etdirmir. Real abunəlik statusu üçün backend-də Play/App
  // Store Server API ilə mütəmadi yoxlama (ya da server-to-server bildiriş,
  // Real-time Developer Notifications / App Store Server Notifications)
  // qurmaq lazımdır.
  Future<void> checkActiveSubscriptions() async {
    try {
      if (Platform.isAndroid) {
        final androidAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

        final QueryPurchaseDetailsResponse response =
            await androidAddition.queryPastPurchases();

        if (response.error != null) {
          _purchaseController.add(
            PurchaseResult(
              status: PurchaseStatus.error,
              message: 'Keçmiş satınalmaları yoxlama xətası: ${response.error}',
            ),
          );
          return;
        }

        for (final purchase in response.pastPurchases) {
          if (_subscriptionIds.contains(purchase.productID)) {
            _hasActiveSubscription = true;
            break;
          }
        }
      } else if (Platform.isIOS) {
        await restorePurchases();
      }
    } catch (e) {
      _purchaseController.add(
        PurchaseResult(
          status: PurchaseStatus.error,
          message: 'Abunəlikləri yoxlayarkən xəta: ${e.toString()}',
        ),
      );
    }
  }

  // Əvvəlki satınalmaları bərpa etmək (İstifadəçiyə "Restore Purchases"
  // düyməsi ilə əlçatan olmalıdır - App Store tələb edir)
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
    _initialized = false;
  }
}

/* ------------------------------------------------------------------------
services_init.dart-da qeydiyyat SIRASI vacibdir: InAppPurchaseService,
UserService-dən SONRA qeydiyyatdan keçməlidir, çünki ona bağımlıdır:

  locator
    ..registerLazySingleton(() => UserService())
    ..registerLazySingleton(
      () => InAppPurchaseService(userService: locator<UserService>()),
    );

Və Future.wait([...]) siyahısına əlavə edin:

  await Future.wait([
    ...
    locator<InAppPurchaseService>().init(),
  ]);
------------------------------------------------------------------------ */

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