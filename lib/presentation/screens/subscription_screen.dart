import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equation_quest/presentation/state_managment/auth/auth_bloc.dart';
import 'package:equation_quest/presentation/state_managment/auth/auth_state.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _selectedSubscriptionIndex = -1;
  int _selectedCoinsPackIndex = -1;

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
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            const int userCoins = 350; // Replace with actual user coins

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
                            'Basic Account',
                            style: TextStyle(
                              fontFamily: 'Scabber',
                              fontSize: 12,
                              color: Colors.grey.shade700,
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
            );
          },
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
            'Upgrade your account to access premium features!',
            style: TextStyle(
              fontFamily: 'Scabber',
              fontSize: 14,
              color: Colors.grey.shade700,
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
                                  '\$${plan.price.toStringAsFixed(2)}',
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
                                onPressed: _selectedSubscriptionIndex == index
                                    ? () {
                                        // Process subscription purchase
                                        _showPurchaseDialog(
                                          'Subscribe to ${plan.title}',
                                          'You will be charged \$${plan.price.toStringAsFixed(2)} for ${plan.duration} ${plan.duration == 1 ? 'month' : 'months'} of premium access.',
                                        );
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
                                  _selectedSubscriptionIndex == index ? 'Subscribe Now' : 'Select Plan',
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

  Widget _buildCoinsTab() {
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
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _coinsPacks.length,
            itemBuilder: (context, index) {
              final pack = _coinsPacks[index];
              final isSelected = _selectedCoinsPackIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCoinsPackIndex = index;
                  });

                  // Show purchase dialog immediately when a coin pack is selected
                  _showPurchaseDialog(
                    'Purchase Coins',
                    'You will receive ${pack.amount + pack.bonus} coins for \$${pack.price.toStringAsFixed(2)}.',
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.amber.shade400 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected ? Colors.amber.shade50 : Colors.white,
                    boxShadow: isSelected
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
                          '\$${pack.price.toStringAsFixed(2)}',
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
