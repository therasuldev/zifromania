import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zifromania/presentation/state-managment/ad_manager.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:zifromania/presentation/widgets/dialogs/subscription_dialog.dart';
import 'package:zifromania/services/game_limit_service.dart';

class AdRewardContainer extends StatefulWidget {
  final GameLimitService gameLimitService;
  final AdManager adManager;
  final VoidCallback? onRewardEarned;
  final VoidCallback? onClose;

  const AdRewardContainer({
    super.key,
    required this.gameLimitService,
    required this.adManager,
    this.onRewardEarned,
    this.onClose,
  });

  @override
  State<AdRewardContainer> createState() => _AdRewardContainerState();
}

class _AdRewardContainerState extends State<AdRewardContainer> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Map<String, dynamic> _adStatus = {};

  static const int _maxAdsForReward = 3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadAdStatus();
  }

  void _loadAdStatus() {
    setState(() {
      _adStatus = widget.gameLimitService.getGlobalAdStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _watchAd() async {
    if (_isLoading || !widget.gameLimitService.canWatchAdForReward()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // YENİ: AdManager-in yeni metodundan istifadə et
      final success = await widget.adManager.showRewardedAdForFlexibleGames(
        onRewardEarned: () {
          setState(() {
            _isLoading = false;
          });

          _animationController.forward().then((_) {
            _animationController.reverse();
          });

          // Ad status-u yenilə
          _loadAdStatus();

          // Yenidən yoxla ki, mükafat verildinimi
          final newStatus = widget.gameLimitService.getGlobalAdStatus();
          if (newStatus['hasEarnedReward'] == true) {
            _showRewardDialog();
          }

          // Callback-i çağır
          widget.onRewardEarned?.call();
        },
        onError: (String error) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );

      if (!success) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reklam göstərilmədi. Yenidən cəhd edin.')),
      );
    }
  }

  void _showRewardDialog() {
    final flexibleGames = _adStatus['flexibleGames'] ?? 0;

    showDialog(context: context, barrierDismissible: false, builder: (context) => AppDialog(message: 'extra_games_unlocked'.tr()));
  }

  @override
  Widget build(BuildContext context) {
    // Ad status-u hər build-də yenilə
    _loadAdStatus();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.withValues(alpha: 0.2), Colors.tealAccent.withValues(alpha: 0.1)],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Arxa fon pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PatternPainter(),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ana məlumat
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.withValues(alpha: 0.2), Colors.tealAccent.withValues(alpha: 0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.tr('subscription.extra_games'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Scabber',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reklam progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _maxAdsForReward,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              image: DecorationImage(
                                image: index < (_adStatus['watchedAds'] ?? 0)
                                    ? const AssetImage('assets/icons/trending.png')
                                    : const AssetImage('assets/icons/play.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'subscription.ad_status'.tr(namedArgs: {
                          'watched': (_adStatus['watchedAds'] ?? 0).toString(),
                          'max': _maxAdsForReward.toString(),
                        }),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Scabber',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reklam izləmə düyməsi və ya nəticə
                      if (!(_adStatus['hasEarnedReward'] ?? false))
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: PressableFilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
                                foregroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: _isLoading ? null : _watchAd,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'subscription.watch_ad'.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Scabber',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Məlumat hissəsi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/information.png',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'subscription.ad_info'.tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontFamily: 'Scabber',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Arxa fon pattern çəkmək üçün
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Diagonal xətlər
    for (double i = -size.height; i < size.width + size.height; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
