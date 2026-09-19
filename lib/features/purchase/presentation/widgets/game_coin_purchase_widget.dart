import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zifromania/features/purchase/domain/entities/coin_pack.dart';
import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';
import 'package:zifromania/shared/widgets/animated_icon_button.dart';

class GameCoinPurchaseWidget extends StatefulWidget {
  const GameCoinPurchaseWidget({
    super.key,
    required this.products,
    required this.onBuy,
    required this.isPurchasing,
    required this.purchasingProductId,
  });

  final Future<void> Function(String productId) onBuy;
  final List<StoreProductEntity> products;
  final bool isPurchasing;
  final String? purchasingProductId;

  @override
  State<GameCoinPurchaseWidget> createState() => _GameCoinPurchaseWidgetState();
}

class _GameCoinPurchaseWidgetState extends State<GameCoinPurchaseWidget> with SingleTickerProviderStateMixin {
  int _selectedCoinsPackIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Product IDs must match the IDs configured in the store data source.
  late List<CoinPack> coinPacks = [
    CoinPack(productId: '100_coin', amount: 100, staticPrice: 0.99),
    CoinPack(productId: '550_coin', amount: 550, bonus: 50, staticPrice: 4.99),
    CoinPack(productId: '1200_coin', amount: 1200, bonus: 200, staticPrice: 9.99, specialOffer: 'POPULAR'),
    CoinPack(productId: '5000_coin', amount: 5000, bonus: 2000, staticPrice: 39.99, specialOffer: 'BEST VALUE'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _syncPacksWithStore(List<StoreProductEntity> storeProducts) {
    coinPacks = coinPacks.map((pack) {
      final product = storeProducts.where((item) => item.id == pack.productId).firstOrNull;
      return pack.copyWithProduct(product);
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPacksWithStore(widget.products);
  }

  @override
  void didUpdateWidget(covariant GameCoinPurchaseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) _syncPacksWithStore(widget.products);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndBuy(CoinPack pack) async {
    showDialog<void>(
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
                    context.pop();
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
