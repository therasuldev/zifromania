import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/models/subscription_model.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/presentation/state-managment/user/user_bloc.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:zifromania/services/daily_reward_service.dart';

class DailyRewardWidget extends StatefulWidget {
  const DailyRewardWidget({super.key, this.user});
  final UserModel? user;

  @override
  State<DailyRewardWidget> createState() => _DailyRewardWidgetState();
}

class _DailyRewardWidgetState extends State<DailyRewardWidget> {
  final DailyRewardService _rewardService = locator.get<DailyRewardService>();

  bool _isLoading = true;
  bool _isRewardReady = false;
  bool _isClaiming = false;
  Duration _timeUntilReady = Duration.zero;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _refreshState(); // initial check
    _startPolling(); // keep UI ticking once per minute
  }

  /* --------------------------------------------------------------------- */
  /* Polling helpers */
  /* --------------------------------------------------------------------- */

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _refreshState());
  }

  Future<void> _refreshState() async {
    final ready = await _rewardService.isRewardReady();
    final remaining = await _rewardService.timeUntilReady();

    if (!mounted) return;
    setState(() {
      _isRewardReady = ready;
      _timeUntilReady = remaining;
      _isLoading = false;
    });
  }

  /* --------------------------------------------------------------------- */
  /* Claim logic */
  /* --------------------------------------------------------------------- */

  int get _coinsPerClaim => switch (widget.user?.subscription.type) {
        SubscriptionType.oneMonth => 15,
        SubscriptionType.threeMonths => 20,
        SubscriptionType.sixMonths => 30,
        _ => 7, // Default for no subscription or unknown type
      };

  Future<void> _claimReward() async {
    if (!_isRewardReady || _isClaiming) return; // İki dəfə kliklənməyə qarşı qoruma

    setState(() => _isClaiming = true); // Claim prosesi başladı

    try {
      await _rewardService.claimReward();

      if (!mounted) return;
      context.read<UserBloc>().add(UserEvent.grantCoinsStart(_coinsPerClaim));

      _showRewardClaimedDialog(_coinsPerClaim);
      _refreshState();
    } finally {
      if (mounted) setState(() => _isClaiming = false); // Proses bitdi
    }
  }

  void _showRewardClaimedDialog(int coins) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reward',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: AnimatedRewardWidget(
            animation: animation,
            coins: coins,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /* --------------------------------------------------------------------- */
  /* UI */
  /* --------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightBrownColor, Colors.brown.shade300.withValues(alpha: .5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            _isRewardReady ? 'assets/icons/gift_not_opened.png' : 'assets/icons/gift_opened.png',
            height: 60,
            width: 60,
            opacity: Animation.fromValueListenable(ValueNotifier(0.7)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'coin.daily_reward.title'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Scabber',
                    color: Colors.grey.shade300.withValues(alpha: .7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _isRewardReady
                    ? Text(
                        'coin.daily_reward.tap_to_collect'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Scabber',
                          color: Colors.grey.shade400.withValues(alpha: .7),
                        ),
                      )
                    : Text(
                        'coin.daily_reward.come_back_later'.tr(args: [DailyRewardService.formatRemainingTime(_timeUntilReady)]),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Scabber',
                          color: Colors.grey.shade400.withValues(alpha: .7),
                        ),
                      ),
              ],
            ),
          ),
          if (_isRewardReady && !_isLoading)
            PressableFilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _isClaiming ? null : _claimReward,
              child: Text('coin.daily_reward.collect_button'.tr(), style: const TextStyle(fontFamily: 'Scabber')),
            )
        ],
      ),
    );
  }
}

class AnimatedRewardWidget extends StatefulWidget {
  final Animation<double> animation;
  final int coins;
  final VoidCallback? onAnimationComplete;

  const AnimatedRewardWidget({
    super.key,
    required this.animation,
    required this.coins,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedRewardWidget> createState() => _AnimatedRewardWidgetState();
}

class _AnimatedRewardWidgetState extends State<AnimatedRewardWidget> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late List<ParticleData> particles;
  bool _animationCompleteCallbackCalled = false;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutBack,
    );

    particles = List.generate(15, (index) {
      final random = Random();
      return ParticleData(
        angle: (index * 24.0) * (pi / 180),
        distance: 80 + random.nextDouble() * 40,
        scale: 0.5 + random.nextDouble() * 0.5,
        delay: random.nextDouble() * 0.3,
        isStarType: random.nextBool(),
        color: random.nextBool() ? Colors.amberAccent : Colors.yellowAccent,
        size: 20 + random.nextDouble() * 15,
      );
    });

    widget.animation.addListener(() {
      if (widget.animation.value > 0.3) {
        _bounceController.forward();
      }
      if (widget.animation.value > 0.5) {
        _startParticleAnimation();
      }
    });

    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_animationCompleteCallbackCalled) {
        _animationCompleteCallbackCalled = true;
        widget.onAnimationComplete?.call();
      }
    });

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _startParticleAnimation() {
    _particleController.forward();
    // Təkrarlama artıq lazım deyil, çünki dialog bağlanacaq
  }

  @override
  void dispose() {
    _particleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_particleController, _bounceAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Parçacıq animasiyaları
            ...particles.map((particle) => _buildParticle(particle)),

            // Əsas reward widget
            ScaleTransition(
              scale: _bounceAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coin icon with rotation
                  AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return ScaleTransition(
                        scale: _bounceAnimation,
                        child: Image.asset(
                          'assets/icons/coin-bag.png',
                          height: 120,
                          width: 120,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Coins text with pulse effect
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      final pulseScale = 1.0 + (sin(_bounceController.value * pi * 4) * 0.1);
                      return Transform.scale(
                        scale: math.max(0.1, pulseScale),
                        child: Text(
                          '+${widget.coins}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Scabber',
                            color: Colors.indigo.shade300,
                            decoration: TextDecoration.none,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                              Shadow(
                                color: Colors.indigo.shade200.withValues(alpha: 0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticle(ParticleData particle) {
    final progress = Curves.easeOut.transform(math.max(0.0, math.min(1.0, (_particleController.value - particle.delay) / (1.0 - particle.delay))));

    final x = cos(particle.angle) * particle.distance * progress;
    final y = sin(particle.angle) * particle.distance * progress;

    final opacity = math.max(0.0, math.min(1.0, (1.0 - progress) * _bounceAnimation.value));
    final scale = math.max(0.0, particle.scale * (1.0 - progress) * _bounceAnimation.value);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            particle.isStarType ? Icons.star : Icons.circle,
            color: particle.color,
            size: particle.size,
          ),
        ),
      ),
    );
  }
}

class ParticleData {
  final double angle;
  final double distance;
  final double scale;
  final double delay;
  final bool isStarType;
  final Color color;
  final double size;

  ParticleData({
    required this.angle,
    required this.distance,
    required this.scale,
    required this.delay,
    required this.isStarType,
    required this.color,
    required this.size,
  });
}
