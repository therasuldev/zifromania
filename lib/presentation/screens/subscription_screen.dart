import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/state-managment/ad_manager.dart';
import 'package:zifromania/presentation/state-managment/user/user_bloc.dart';
import 'package:zifromania/presentation/widgets/ad_reward_container.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:zifromania/presentation/widgets/daily_reward.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/game_limit_service.dart';
import 'package:zifromania/services/in_app_purchase_service.dart';

enum TabType {
  subscription,
  coins;

  int get idx => switch (this) {
        TabType.subscription => 0,
        TabType.coins => 1,
      };
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, required this.tabType});
  final TabType tabType;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedSubscriptionIndex = 1;

  late final AdManager adManager;
  late final InAppPurchaseService _iapService;

  StreamSubscription<List<StoreProduct>>? _productsSub;
  StreamSubscription<PurchaseResult>? _purchaseSub;

  bool _isPurchasing = false;
  String? _purchasingProductId;

  // Yerli marketinq məlumatları (features, "best value" tag və s.).
  // `productId` sahəsi InAppPurchaseService-dəki _subscriptionIds ilə EYNİ
  // olmalıdır - orada dəyişsəniz burada da dəyişin.
  late List<SubscriptionPlan> _subscriptionPlans = [
    SubscriptionPlan(
      productId: 'subscription_monthly',
      title: 'subscription.1_month.title'.tr(),
      staticPrice: 4.99,
      duration: 1,
      features: [...List.generate(3, (index) => 'subscription.1_month.features.$index'.tr())],
      mostPopular: false,
      savePercentage: 0,
    ),
    SubscriptionPlan(
      productId: 'subscription_quarterly',
      title: 'subscription.3_months.title'.tr(),
      staticPrice: 9.99,
      duration: 3,
      features: [...List.generate(4, (index) => 'subscription.3_months.features.$index'.tr())],
      mostPopular: true,
      savePercentage: 33,
    ),
    SubscriptionPlan(
      productId: 'subscription_semiannual',
      title: 'subscription.6_months.title'.tr(),
      staticPrice: 17.99,
      duration: 6,
      features: [...List.generate(5, (index) => 'subscription.6_months.features.$index'.tr())],
      mostPopular: false,
      savePercentage: 40,
    ),
  ];

  @override
  void initState() {
    super.initState();
    adManager = locator.get<AdManager>();
    _iapService = locator.get<InAppPurchaseService>();

    // Servis app başlanğıcında artıq init olunub (services_init.dart), ona
    // görə mövcud məhsulları dərhal götürüb ekrana bağlayırıq.
    _syncPlansWithStore(_iapService.products);

    _productsSub = _iapService.productsStream.listen((storeProducts) {
      if (!mounted) return;
      _syncPlansWithStore(storeProducts);
    });

    _purchaseSub = _iapService.purchaseStream.listen(_handlePurchaseResult);
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _purchaseSub?.cancel();
    super.dispose();
  }

  void _syncPlansWithStore(List<StoreProduct> storeProducts) {
    setState(() {
      _subscriptionPlans = _subscriptionPlans.map((plan) {
        ProductDetails? match;
        for (final sp in storeProducts) {
          if (sp.productDetails.id == plan.productId) {
            match = sp.productDetails;
            break;
          }
        }
        return plan.copyWithProduct(match);
      }).toList();
    });
  }

  StoreProduct? _findStoreProduct(String productId) {
    for (final p in _iapService.products) {
      if (p.productDetails.id == productId) return p;
    }
    return null;
  }

  Future<void> _handleBuy(String productId) async {
    if (_isPurchasing) return;

    final storeProduct = _findStoreProduct(productId);
    if (storeProduct == null) {
      _showResultDialog(
        success: false,
        message: 'subscription.not_available'.tr(),
      );
      return;
    }

    setState(() {
      _isPurchasing = true;
      _purchasingProductId = productId;
    });

    final bool started = await _iapService.buyProduct(storeProduct.productDetails);

    // `started == false` deməkdir ki, native ödəniş axını heç başlamadı
    // (məs. istifadəçi dərhal imtina etdi və ya store xətası). Əks halda
    // nəticə purchaseStream vasitəsilə _handlePurchaseResult-a gələcək.
    if (!started && mounted) {
      setState(() {
        _isPurchasing = false;
        _purchasingProductId = null;
      });
    }
  }

  void _handlePurchaseResult(PurchaseResult result) {
    if (!mounted) return;

    switch (result.status) {
      case PurchaseStatus.pending:
        setState(() => _isPurchasing = true);
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        setState(() {
          _isPurchasing = false;
          _purchasingProductId = null;
        });
        _showResultDialog(
          success: true,
          message: 'subscription.purchase_success'.tr(),
        );
        break;

      case PurchaseStatus.error:
        setState(() {
          _isPurchasing = false;
          _purchasingProductId = null;
        });
        _showResultDialog(
          success: false,
          message: result.message ?? 'subscription.purchase_error'.tr(),
        );
        break;

      case PurchaseStatus.canceled:
        setState(() {
          _isPurchasing = false;
          _purchasingProductId = null;
        });
        break;
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    await _iapService.restorePurchases();
    // Nəticə purchaseStream vasitəsilə PurchaseStatus.restored kimi gələcək
    // (əgər bərpa ediləcək bir şey varsa); heç nə gəlməzsə _isPurchasing
    // özü aşağıdakı timeout ilə söndürülür ki, istifadəçi əbədi gözləməsin.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPurchasing) {
        setState(() => _isPurchasing = false);
      }
    });
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          success ? 'subscription.dialog_success_title'.tr() : 'subscription.dialog_error_title'.tr(),
          style: TextStyle(
            fontFamily: 'Scabber',
            fontWeight: FontWeight.bold,
            color: success ? Colors.green : Colors.red.shade400,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (success ? Colors.green : Colors.red).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.error_outline,
                size: 48,
                color: success ? Colors.green.shade700 : Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontFamily: 'Scabber'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: success ? Colors.green.shade400 : Colors.red.shade300,
            ),
            child: Text(
              'subscription.ok'.tr(),
              style: const TextStyle(
                fontFamily: 'Scabber',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              ValueListenableBuilder<UserModel?>(
                valueListenable: locator.get<SecureCacheService>().userNotifier,
                builder: (ctx, user, _) {
                  if (user == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade700,
                        highlightColor: Colors.white70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 16, width: 100, color: Colors.white),
                                    const SizedBox(height: 6),
                                    Container(height: 12, width: 80, color: Colors.white),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(height: 18, width: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Container(height: 14, width: 30, color: Colors.white),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName?.isNotEmpty == true ? user.displayName![0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.displayName ?? 'Math Player',
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'Scabber',
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  color: transparentIndigoColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'subscription.account'.tr(),
                                style: TextStyle(
                                  fontFamily: 'Scabber',
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade300, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/star.png',
                                height: 18,
                                width: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${user.coins}',
                                style: TextStyle(
                                  fontFamily: 'Scabber',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  initialIndex: widget.tabType.idx,
                  animationDuration: const Duration(seconds: 1),
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: backgroundColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          indicatorAnimation: TabIndicatorAnimation.elastic,
                          indicator: BoxDecoration(
                            color: lightIndigoColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white70,
                          unselectedLabelColor: Colors.white60,
                          labelStyle: const TextStyle(
                            fontFamily: 'Scabber',
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(text: 'subscription.subscription'.tr()),
                            Tab(text: 'subscription.coins'.tr()),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildSubscriptionTab(),
                            _buildCoinsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'subscription.section_title'.tr(),
            style: const TextStyle(
              fontFamily: 'Scabber',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'subscription.section_subtitle'.tr(),
            style: const TextStyle(
              fontFamily: 'Scabber',
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subscriptionPlans.length,
            itemBuilder: (context, index) {
              final plan = _subscriptionPlans[index];
              final bool isThisPurchasing = _isPurchasing && _purchasingProductId == plan.productId;
              final bool isSelected = _selectedSubscriptionIndex == index;

              return GestureDetector(
                onTap: _isPurchasing
                    ? null
                    : () {
                        setState(() {
                          _selectedSubscriptionIndex = index;
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.teal.shade400.withValues(alpha: 0.8) : Colors.teal.shade100.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected ? backgroundColor.withValues(alpha: 0.2) : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16) + const EdgeInsets.only(top: 24, bottom: 6.0),
                            decoration: const BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54,
                                  ),
                                ),
                                Text(
                                  plan.priceLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (plan.mostPopular)
                            Positioned(
                              top: -10,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.teal.shade400, Colors.teal.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.shade200.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'subscription.best_value'.tr(),
                                  style: const TextStyle(
                                    fontFamily: 'Scabber',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plan.savePercentage > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Text(
                                  'subscription.save_percentage'.tr(args: [plan.savePercentage.toString()]),
                                  style: const TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ...plan.features.map((feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check_circle, size: 18, color: Colors.green.shade500),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: const TextStyle(
                                            fontFamily: 'Scabber',
                                            fontSize: 14,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (isSelected && !_isPurchasing) ? () => _handleBuy(plan.productId) : null,
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Colors.teal.shade300.withValues(alpha: 0.3),
                                  backgroundColor: Colors.teal.shade600.withValues(alpha: 0.7),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: isSelected ? 2 : 0,
                                  shadowColor: Colors.indigo.shade200,
                                ),
                                child: isThisPurchasing
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        isSelected ? 'subscription.subscribe'.tr() : 'subscription.select_plan'.tr(),
                                        style: TextStyle(
                                          fontFamily: 'Scabber',
                                          color: isSelected ? Colors.teal.shade100 : Colors.teal.shade100.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          Center(
            child: TextButton(
              onPressed: _isPurchasing ? null : _handleRestore,
              child: Text(
                'subscription.restore_purchases'.tr(),
                style: TextStyle(
                  fontFamily: 'Scabber',
                  color: Colors.white54,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.shade500),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'subscription.premium_benefits.title'.tr(),
                  style: TextStyle(
                    fontFamily: 'Scabber',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade200,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(5, (index) => _buildBenefitItem('subscription.premium_benefits.$index'.tr())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CustomBackButton(color: lightBrownColor),
        const SizedBox(width: 16),
        Text(
          'subscription.title'.tr(),
          style: TextStyle(
            fontFamily: 'Scabber',
            fontSize: 22,
            color: lightBrownColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCoinsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameCoinPurchaseWidget(
            onBuy: _handleBuy,
            isPurchasing: _isPurchasing,
            purchasingProductId: _purchasingProductId,
          ),
          const SizedBox(height: 24),
          AdRewardContainer(
            gameLimitService: locator.get<GameLimitService>(),
            adManager: adManager,
          ),
          const SizedBox(height: 24),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return DailyRewardWidget(user: state.user);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Colors.yellow.withValues(alpha: .7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Scabber',
                fontSize: 14,
                color: Colors.brown.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class SubscriptionPlan {
  final String productId;
  final String title;
  final double staticPrice; // store yüklənməyibsə fallback qiymət
  final int duration; // in months
  final List<String> features;
  final bool mostPopular;
  final int savePercentage;
  final ProductDetails? productDetails;

  SubscriptionPlan({
    required this.productId,
    required this.title,
    required this.staticPrice,
    required this.duration,
    required this.features,
    required this.mostPopular,
    required this.savePercentage,
    this.productDetails,
  });

  // Store yüklənəndə real, lokallaşdırılmış qiymət mətnini göstərir
  // (məs. "$4.99" AŞB-də, "4,99 ₼" Azərbaycanda və s.).
  String get priceLabel => productDetails?.price ?? '\$${staticPrice.toStringAsFixed(2)}';

  SubscriptionPlan copyWithProduct(ProductDetails? details) => SubscriptionPlan(
        productId: productId,
        title: title,
        staticPrice: staticPrice,
        duration: duration,
        features: features,
        mostPopular: mostPopular,
        savePercentage: savePercentage,
        productDetails: details,
      );
}

class CoinPack {
  final String productId;
  final int amount;
  final int bonus;
  final double staticPrice;
  final String? specialOffer;
  final ProductDetails? productDetails;

  CoinPack({
    required this.productId,
    required this.amount,
    this.bonus = 0,
    required this.staticPrice,
    this.specialOffer,
    this.productDetails,
  });

  String get priceLabel => productDetails?.price ?? '\$${staticPrice.toStringAsFixed(2)}';

  CoinPack copyWithProduct(ProductDetails? details) => CoinPack(
        productId: productId,
        amount: amount,
        bonus: bonus,
        staticPrice: staticPrice,
        specialOffer: specialOffer,
        productDetails: details,
      );
}

class GameCoinPurchaseWidget extends StatefulWidget {
  const GameCoinPurchaseWidget({
    super.key,
    required this.onBuy,
    required this.isPurchasing,
    required this.purchasingProductId,
  });

  final Future<void> Function(String productId) onBuy;
  final bool isPurchasing;
  final String? purchasingProductId;

  @override
  State<GameCoinPurchaseWidget> createState() => _GameCoinPurchaseWidgetState();
}

class _GameCoinPurchaseWidgetState extends State<GameCoinPurchaseWidget> with SingleTickerProviderStateMixin {
  int _selectedCoinsPackIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late final InAppPurchaseService _iapService;
  StreamSubscription<List<StoreProduct>>? _productsSub;

  // productId-lər InAppPurchaseService-dəki _coinProductIds ilə EYNİ olmalıdır.
  late List<CoinPack> coinPacks = [
    CoinPack(productId: '100_coin', amount: 100, staticPrice: 0.99),
    CoinPack(productId: '550_coin', amount: 550, bonus: 50, staticPrice: 4.99),
    CoinPack(productId: '1200_coin', amount: 1200, bonus: 200, staticPrice: 9.99, specialOffer: 'POPULAR'),
    CoinPack(productId: '5000_coin', amount: 5000, bonus: 2000, staticPrice: 39.99, specialOffer: 'BEST VALUE'),
  ];

  @override
  void initState() {
    super.initState();
    _iapService = locator.get<InAppPurchaseService>();

    _syncPacksWithStore(_iapService.products);
    _productsSub = _iapService.productsStream.listen((storeProducts) {
      if (!mounted) return;
      _syncPacksWithStore(storeProducts);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _syncPacksWithStore(List<StoreProduct> storeProducts) {
    setState(() {
      coinPacks = coinPacks.map((pack) {
        ProductDetails? match;
        for (final sp in storeProducts) {
          if (sp.productDetails.id == pack.productId) {
            match = sp.productDetails;
            break;
          }
        }
        return pack.copyWithProduct(match);
      }).toList();
    });
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndBuy(CoinPack pack) async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4E342E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.orange.shade200.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 25, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'coin.confirm_title'.tr(),
                  style: TextStyle(
                    fontFamily: 'Scabber',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade100.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'coin.confirm_message'.tr(args: ['${pack.amount + pack.bonus}', pack.priceLabel]),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontFamily: 'Scabber', color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 28),
                PressableFilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade400.withValues(alpha: 0.8),
                    foregroundColor: Colors.brown.shade900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onBuy(pack.productId);
                  },
                  child: Text('coin.buy_now'.tr(), style: const TextStyle(fontFamily: 'Scabber')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/treasure.png',
                  height: 32,
                  opacity: Animation.fromValueListenable(ValueNotifier(0.7)),
                ),
                const SizedBox(width: 8),
                Text(
                  'coin.pack'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Scabber',
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: coinPacks.length,
            itemBuilder: (context, index) {
              final pack = coinPacks[index];
              final isSelected = _selectedCoinsPackIndex == index;
              final isThisPurchasing = widget.isPurchasing && widget.purchasingProductId == pack.productId;

              return GestureDetector(
                onTap: widget.isPurchasing
                    ? null
                    : () async {
                        setState(() {
                          _selectedCoinsPackIndex = index;
                        });
                        _animationController.forward().then((_) => _animationController.reverse());
                        await _confirmAndBuy(pack);
                      },
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.indigo.shade200.withValues(alpha: .4),
                              Colors.indigo.shade50.withValues(alpha: .6),
                            ],
                          ),
                          border: Border.all(
                            color: isSelected ? Colors.indigo.shade100 : Colors.indigo.shade500,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.indigo.shade200.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/coin-bag.png', height: 32),
                                const SizedBox(width: 8),
                                Text(
                                  '${pack.amount}',
                                  style: TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade500.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isThisPurchasing
                                  ? const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      pack.priceLabel,
                                      style: const TextStyle(
                                        fontFamily: 'Scabber',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      if (pack.bonus > 0)
                        Positioned(
                          top: -12,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade600,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              '+${pack.bonus}',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Scabber',
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade100,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}