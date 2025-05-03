// Import the necessary services and bloc
import 'package:zifromania/presentation/state_managment/in-app-purchase/in_app_purchase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_bloc.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_state.dart';
import 'package:zifromania/services/in_app_purchase_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _selectedSubscriptionIndex = 1;
  int _selectedCoinsPackIndex = -1;

  // Product ID mapping for subscriptions and coin packs
  final List<String> _subscriptionProductIds = [
    'subscription_monthly',
    'subscription_quarterly',
    'subscription_annual',
  ];

  final List<String> _coinProductIds = [
    'coins_100',
    'coins_500',
    'coins_1200',
    'coins_2500',
  ];

  // Define subscription packages
  final List<SubscriptionPlan> _subscriptionPlans = [
    SubscriptionPlan(
      title: '1 Month',
      price: 4.99,
      duration: 1,
      features: ['Unlimited puzzles', 'No ads', 'Special challenges'],
      mostPopular: false,
      savePercentage: 0,
    ),
    SubscriptionPlan(
      title: '3 Months',
      price: 9.99,
      duration: 3,
      features: ['Unlimited puzzles', 'No ads', 'Special challenges', 'Daily rewards'],
      mostPopular: true,
      savePercentage: 33,
    ),
    SubscriptionPlan(
      title: '12 Months',
      price: 29.99,
      duration: 12,
      features: ['Unlimited puzzles', 'No ads', 'Special challenges', 'Daily rewards', 'Premium avatars'],
      mostPopular: false,
      savePercentage: 50,
    ),
  ];

  // Define coin packages
  final List<CoinsPack> _coinsPacks = [
    CoinsPack(amount: 100, price: 0.99, bonus: 0),
    CoinsPack(amount: 500, price: 3.99, bonus: 50),
    CoinsPack(amount: 1200, price: 7.99, bonus: 200),
    CoinsPack(amount: 2500, price: 14.99, bonus: 500),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the purchase service
    context.read<PurchaseBloc>().add(InitializePurchase());
    context.read<PurchaseBloc>().add(CheckSubscriptions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Store',
          style: TextStyle(
            fontFamily: 'Scabber',
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Add restore purchases button
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              context.read<PurchaseBloc>().add(RestorePurchases());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restoring previous purchases...')),
              );
            },
            tooltip: 'Restore Purchases',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<PurchaseBloc, PurchaseState>(
          listener: (context, state) {
            if (state is PurchaseLoading) {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
            } else if (state is PurchaseInProgress) {
              // Show purchase in progress dialog
              Navigator.pop(context); // Pop loading dialog if exists
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  title: Text('Processing Purchase', style: TextStyle(fontFamily: 'Scabber')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Please wait while your purchase is being processed...', style: TextStyle(fontFamily: 'Scabber')),
                    ],
                  ),
                ),
              );
            } else if (state is PurchaseSuccess) {
              // Dismiss any dialogs
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              // Show success dialog
              _showSuccessDialog();
            } else if (state is PurchaseError) {
              // Dismiss any dialogs
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              // Show error dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Purchase Failed', style: TextStyle(fontFamily: 'Scabber', color: Colors.red)),
                  content: Text(state.message, style: const TextStyle(fontFamily: 'Scabber')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK', style: TextStyle(fontFamily: 'Scabber')),
                    ),
                  ],
                ),
              );
            } else if (state is PurchaseCanceled) {
              // Dismiss any dialogs
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              // Show canceled dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase was canceled')),
              );
            } else if (state is ProductsLoaded) {
              // Dismiss loading dialog if exists
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
          child: BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, purchaseState) {
              return BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final user = authState.user;
                  const int userCoins = 350; // Replace with actual user coins

                  bool hasActiveSubscription = false;
                  List<StoreProduct> subscriptionProducts = [];
                  List<StoreProduct> coinProducts = [];

                  if (purchaseState is ProductsLoaded) {
                    hasActiveSubscription = purchaseState.hasActiveSubscription;
                    subscriptionProducts = purchaseState.subscriptions;
                    coinProducts = purchaseState.coinProducts;
                  }

                  return Column(
                    children: [
                      // Top user info bar with coins
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade100, Colors.purple.shade100],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100.withValues(alpha: 0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user?.displayName ?? 'Math Player',
                                  style: const TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  hasActiveSubscription ? 'Premium Account' : 'Basic Account',
                                  style: TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 12,
                                    color: hasActiveSubscription ? Colors.amber.shade800 : Colors.grey.shade700,
                                    fontWeight: hasActiveSubscription ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
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
                                    '$userCoins',
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

                      // Main content area
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  indicatorColor: Colors.transparent,
                                  indicator: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.grey.shade700,
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Scabber',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  tabs: const [
                                    Tab(text: 'Subscription'),
                                    Tab(text: 'Coins'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildSubscriptionTab(subscriptionProducts, hasActiveSubscription),
                                    _buildCoinsTab(coinProducts),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionTab(List<StoreProduct> subscriptionProducts, bool hasActiveSubscription) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Subscription Plan',
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasActiveSubscription
                ? 'You have an active subscription. You can change your plan anytime.'
                : 'Upgrade your account to access premium features!',
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 14,
              color: hasActiveSubscription ? Colors.green.shade700 : Colors.grey.shade700,
              fontWeight: hasActiveSubscription ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 16),

          // Subscription Plans
          subscriptionProducts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading subscription plans...', style: TextStyle(fontFamily: 'Scabber')),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subscriptionPlans.length,
                  itemBuilder: (context, index) {
                    final plan = _subscriptionPlans[index];
                    // Find the corresponding product from the store
                    final storeProduct = subscriptionProducts.isNotEmpty && index < subscriptionProducts.length
                        ? subscriptionProducts[index]
                        : null;

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
                            color: _selectedSubscriptionIndex == index ? Colors.blue.shade400 : Colors.grey.shade300,
                            width: _selectedSubscriptionIndex == index ? 2 : 1,
                          ),
                          color: _selectedSubscriptionIndex == index ? Colors.blue.shade50 : Colors.white,
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
                                    color: _selectedSubscriptionIndex == index ? Colors.blue.shade400 : Colors.grey.shade100,
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
                                          color: _selectedSubscriptionIndex == index ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        storeProduct != null
                                            ? storeProduct.productDetails.price
                                            : '\$${plan.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: 'Scabber',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedSubscriptionIndex == index ? Colors.white : Colors.blue.shade700,
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
                                      child: const Text(
                                        'BEST VALUE',
                                        style: TextStyle(
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
                                        'SAVE ${plan.savePercentage}%',
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
                                              style: const TextStyle(
                                                fontFamily: 'Scabber',
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: storeProduct != null && _selectedSubscriptionIndex == index
                                          ? () {
                                              context.read<PurchaseBloc>().add(BuyProduct(storeProduct.productDetails));
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        hasActiveSubscription
                                            ? _selectedSubscriptionIndex == index
                                                ? 'Change Plan'
                                                : 'Select Plan'
                                            : _selectedSubscriptionIndex == index
                                                ? 'Subscribe Now'
                                                : 'Select Plan',
                                        style: const TextStyle(
                                          fontFamily: 'Scabber',
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
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Premium Benefits',
                      style: TextStyle(
                        fontFamily: 'Scabber',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBenefitItem('Unlimited access to all math puzzles and challenges'),
                _buildBenefitItem('Ad-free gaming experience for better focus'),
                _buildBenefitItem('Exclusive premium avatars and profile customization'),
                _buildBenefitItem('Priority access to new game features'),
                _buildBenefitItem('Bonus daily coins rewards'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsTab(List<StoreProduct> coinProducts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get More Coins',
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use coins to unlock hints, special power-ups, and unique avatars!',
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),

          // Coins packages
          coinProducts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading coin packages...', style: TextStyle(fontFamily: 'Scabber')),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: coinProducts.length,
                  itemBuilder: (context, index) {
                    final pack = _coinsPacks[index];
                    final storeProduct = index < coinProducts.length ? coinProducts[index] : null;

                    return GestureDetector(
                      onTap: () {
                        if (storeProduct != null) {
                          setState(() {
                            _selectedCoinsPackIndex = index;
                          });

                          // Initiate the purchase directly
                          context.read<PurchaseBloc>().add(BuyProduct(storeProduct.productDetails));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedCoinsPackIndex == index ? Colors.amber.shade400 : Colors.grey.shade300,
                            width: _selectedCoinsPackIndex == index ? 2 : 1,
                          ),
                          color: _selectedCoinsPackIndex == index ? Colors.amber.shade50 : Colors.white,
                          boxShadow: _selectedCoinsPackIndex == index
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.shade200.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Coin image
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade100,
                              ),
                              child: Image.asset(
                                'assets/icons/star.png',
                                height: 40,
                                width: 40,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Amount
                            Text(
                              '${pack.amount}',
                              style: TextStyle(
                                fontFamily: 'Scabber',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Bonus if any
                            if (pack.bonus > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+${pack.bonus} BONUS',
                                  style: TextStyle(
                                    fontFamily: 'Scabber',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),

                            const Spacer(),

                            // Price
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade400,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              child: Text(
                                storeProduct != null ? storeProduct.productDetails.price : '\$${pack.price.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Scabber',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          const SizedBox(height: 24),

          // Special offers or daily rewards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/gift.png',
                  height: 60,
                  width: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Reward',
                        style: TextStyle(
                          fontFamily: 'Scabber',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Come back tomorrow to claim your free coins!',
                        style: TextStyle(
                          fontFamily: 'Scabber',
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Scabber',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
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
