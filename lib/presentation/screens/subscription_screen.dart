import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_notifier.dart';
import 'package:zifromania/features/purchase/domain/entities/subscription_plan.dart';
import 'package:zifromania/features/purchase/presentation/enum/tab_type.dart';
import 'package:zifromania/features/purchase/presentation/providers/purchase_notifier.dart';
import 'package:zifromania/features/purchase/presentation/providers/state/purchase_state.dart';
import 'package:zifromania/features/purchase/presentation/widgets/game_coin_purchase_widget.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/widgets/ad_reward_container.dart';
import 'package:zifromania/presentation/widgets/daily_reward.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key, required this.tabType});
  final TabType tabType;

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  int _selectedSubscriptionIndex = 1;

  bool _isPurchasing = false;
  String? _purchasingProductId;

  // Yerli marketinq məlumatları (features, "best value" tag və s.).
  // Product IDs must match the IDs configured in the store data source.
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
    ref.listenManual<PurchaseState>(purchaseNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        _showResultDialog(success: true, message: next.successMessage!);
      } else if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showResultDialog(success: false, message: next.errorMessage!);
      }
    });
  }

  Future<void> _handleBuy(String productId) async {
    if (_isPurchasing) return;

    final product = ref.read(purchaseNotifierProvider).products.where((item) => item.id == productId).firstOrNull;
    if (product == null) {
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

    await ref.read(purchaseNotifierProvider.notifier).buyProduct(productId);
    if (mounted) setState(() => _purchasingProductId = null);
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    await ref.read(purchaseNotifierProvider.notifier).restorePurchases();
    // The provider handles restored purchase updates; stop the spinner if no
    // update arrives from the store.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPurchasing) {
        setState(() => _isPurchasing = false);
      }
    });
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog<void>(
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
            onPressed: () => context.pop(),
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
              Builder(builder: (ctx) {
                final user = ref.watch(authNotifierProvider).value;
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
                        color: Colors.grey.withValues(alpha: 0.3),
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
                        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                        child: user.photoUrl == null
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
              }),
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
    final products = ref.watch(purchaseNotifierProvider).products;
    final plans = _subscriptionPlans.map((plan) {
      final product = products.where((item) => item.id == plan.productId).firstOrNull;
      return plan.copyWithProduct(product);
    }).toList();

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
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
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
                style: const TextStyle(
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
            products: ref.watch(purchaseNotifierProvider).products,
            onBuy: _handleBuy,
            isPurchasing: _isPurchasing,
            purchasingProductId: _purchasingProductId,
          ),
          const SizedBox(height: 24),
          const AdRewardContainer(),
          const SizedBox(height: 24),
          DailyRewardWidget(user: ref.watch(authNotifierProvider).value),
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
