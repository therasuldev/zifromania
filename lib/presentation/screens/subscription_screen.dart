import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/state-managment/ad_manager.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_bloc.dart';
import 'package:zifromania/presentation/state-managment/auth/auth_state.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:zifromania/presentation/widgets/banner_ad.dart';
import 'package:zifromania/presentation/widgets/daily_reward.dart';

enum TabType {
  subscription,
  coins;

  int get idx => switch (this) {
        TabType.subscription => 0,
        TabType.coins => 1,
      };
}

class CoinPack {
  final int amount;
  final int bonus;
  final double price;
  final String? specialOffer;

  CoinPack({
    required this.amount,
    this.bonus = 0,
    required this.price,
    this.specialOffer,
  });
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, required this.tabType});
  final TabType tabType;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedSubscriptionIndex = 1;

  // Define subscription packages
  final List<SubscriptionPlan> _subscriptionPlans = [
    SubscriptionPlan(
      title: 'subscription.1_month.title'.tr(),
      price: 4.99,
      duration: 1,
      features: [...List.generate(3, (index) => 'subscription.1_month.features.$index'.tr())],
      mostPopular: false,
      savePercentage: 0,
    ),
    SubscriptionPlan(
      title: 'subscription.3_months.title'.tr(),
      price: 9.99,
      duration: 3,
      features: [...List.generate(4, (index) => 'subscription.3_months.features.$index'.tr())],
      mostPopular: true,
      savePercentage: 33,
    ),
    SubscriptionPlan(
      title: 'subscription.6_months.title'.tr(),
      price: 17.99,
      duration: 6,
      features: [...List.generate(5, (index) => 'subscription.6_months.features.$index'.tr())],
      mostPopular: false,
      savePercentage: 40,
    ),
  ];

  late final AdManager adManager;

  @override
  void initState() {
    super.initState();
    adManager = locator.get<AdManager>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state.user;

              return Column(
                children: [
                  _buildHeader(),
                  // Top user info bar with coins
                  Container(
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
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null
                              ? Text(
                                  user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : '?',
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
                                user?.displayName ?? 'Math Player',
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
                                '${user?.coins}',
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
                  ),
                  const SizedBox(height: 16),
                  // Main content area
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
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4C87FF).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
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
                                _buildCoinsTab(user),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'subscription.section_subtitle'.tr(),
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 14,
              color: Colors.amber.withValues(alpha: .6),
            ),
          ),
          const SizedBox(height: 16),

          // Subscription Plans
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subscriptionPlans.length,
            itemBuilder: (context, index) {
              final plan = _subscriptionPlans[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSubscriptionIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedSubscriptionIndex == index ? transparentIndigoColor : Colors.grey.shade800,
                      width: _selectedSubscriptionIndex == index ? 2 : 1,
                    ),
                    color: _selectedSubscriptionIndex == index ? transparentIndigoColor.withValues(alpha: .4) : Colors.transparent,
                    boxShadow: _selectedSubscriptionIndex == index
                        ? [
                            BoxShadow(
                              color: Colors.blue.shade200.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      // Header with popular tag if applicable
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedSubscriptionIndex == index ? transparentIndigoColor : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  plan.title,
                                  style: TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedSubscriptionIndex == index ? Colors.black54 : transparentIndigoColor,
                                  ),
                                ),
                                Text(
                                  '\$${plan.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedSubscriptionIndex == index ? Colors.black54 : transparentIndigoColor,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
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

                      // Features
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plan.savePercentage > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Text(
                                  'subscription.save_percentage'.tr(args: [plan.savePercentage.toString()]),
                                  style: TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ...plan.features.map((feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: Colors.green.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        feature,
                                        style: TextStyle(
                                          fontFamily: 'Scabber',
                                          fontSize: 14,
                                          color: _selectedSubscriptionIndex == index ? Colors.black54 : lightBrownColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _selectedSubscriptionIndex == index ? () {} : null,
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Colors.blue.shade100.withValues(alpha: .3),
                                  backgroundColor: transparentIndigoColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _selectedSubscriptionIndex == index ? 'subscription.subscribe'.tr() : 'subscription.select_plan'.tr(),
                                  style: TextStyle(
                                    fontFamily: 'Scabber',
                                    color: _selectedSubscriptionIndex == index ? Colors.black54 : lightBrownColor,
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

          // Benefits section
          Container(
            margin: const EdgeInsets.only(top: 16),
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

  Widget _buildCoinsTab(UserModel? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coins packages
          const GameCoinPurchaseWidget(),
          const SizedBox(height: 24),
          DailyRewardWidget(user: user),
          const SizedBox(height: 24),
          const BannerAdWidget(),
          // Special offers or daily rewards
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

  void _showPurchaseDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Scabber',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontFamily: 'Scabber'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose Payment Method:',
              style: TextStyle(
                fontFamily: 'Scabber',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption('Credit Card', Icons.credit_card),
            const SizedBox(height: 8),
            _buildPaymentOption('PayPal', Icons.account_balance_wallet),
            const SizedBox(height: 8),
            _buildPaymentOption('Google Pay', Icons.g_mobiledata),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Scabber',
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show success dialog
              _showSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
            ),
            child: const Text(
              'Purchase',
              style: TextStyle(
                fontFamily: 'Scabber',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(
            method,
            style: const TextStyle(
              fontFamily: 'Scabber',
              fontSize: 16,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Purchase Successful!',
          style: TextStyle(
            fontFamily: 'Scabber',
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your purchase was successful! Your account has been updated.',
              style: TextStyle(fontFamily: 'Scabber'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
            ),
            child: const Text(
              'Great!',
              style: TextStyle(
                fontFamily: 'Scabber',
                fontWeight: FontWeight.bold,
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
  final String title;
  final double price;
  final int duration; // in months
  final List<String> features;
  final bool mostPopular;
  final int savePercentage;

  SubscriptionPlan({
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
    required this.mostPopular,
    required this.savePercentage,
  });
}

class CoinsPack {
  final int amount;
  final double price;
  final int bonus;

  CoinsPack({
    required this.amount,
    required this.price,
    required this.bonus,
  });
}

class GameCoinPurchaseWidget extends StatefulWidget {
  const GameCoinPurchaseWidget({super.key});

  @override
  State<GameCoinPurchaseWidget> createState() => _GameCoinPurchaseWidgetState();
}

class _GameCoinPurchaseWidgetState extends State<GameCoinPurchaseWidget> with SingleTickerProviderStateMixin {
  int _selectedCoinsPackIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<CoinPack> coinPacks = [
    CoinPack(amount: 100, price: 0.99),
    CoinPack(amount: 500, bonus: 50, price: 4.99),
    CoinPack(amount: 1000, bonus: 200, price: 9.99, specialOffer: 'POPULAR'),
    CoinPack(amount: 5000, bonus: 1500, price: 49.99, specialOffer: 'BEST VALUE'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPurchaseDialog(String title, String message) {
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
              color: const Color(0xFF4E342E).withValues(alpha: 0.5), // yumşaq brown (coffee tone)
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.orange.shade200.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Scabber',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade100.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Scabber',
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 28),
                PressableFilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade400.withValues(alpha: 0.8),
                    foregroundColor: Colors.brown.shade900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  ),
                  onPressed: () {
                    // handle purchase logic
                    Navigator.of(context).pop();
                  },
                  child: const Text('Buy Now', style: TextStyle(fontFamily: 'Scabber')),
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
        color: Colors.brown.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade500, width: 1.5),
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
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.withValues(alpha: .5),
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

              return GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedCoinsPackIndex = index;
                  });

                  if (_selectedCoinsPackIndex == index) {
                    _animationController.forward().then((_) {
                      _animationController.reverse();
                    });
                  } else {
                    _animationController.reset();
                  }
                  await Future.delayed(const Duration(milliseconds: 300));
                },
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.brown.withValues(alpha: .5), Colors.brown.shade100.withValues(alpha: .2)],
                      ),
                      border: Border.all(
                        color: isSelected ? Colors.amber.shade400 : Colors.brown.shade500,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.amber.shade300.withValues(alpha: 0.2),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/coin-bag.png', height: 32),
                            const SizedBox(width: 8),
                            Text(
                              '${pack.amount}',
                              style: TextStyle(
                                fontFamily: 'Scabber',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.withValues(alpha: .5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (pack.bonus > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade900.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${pack.bonus}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade300,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${pack.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
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
