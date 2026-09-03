import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zifromania/features/daily_reward/presentation/widgets/models/particle_data.dart';

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
      final random = math.Random();
      return ParticleData(
        angle: (index * 24.0) * (math.pi / 180),
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
        _particleController.forward();
      }
    });

    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_animationCompleteCallbackCalled) {
        _animationCompleteCallbackCalled = true;
        widget.onAnimationComplete?.call();
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
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
            ...particles.map((particle) => _buildParticle(particle)),
            ScaleTransition(
              scale: _bounceAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/coin-bag.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      final pulseScale = 1.0 + (math.sin(_bounceController.value * math.pi * 4) * 0.1);
                      return Transform.scale(
                        scale: math.max(0.1, pulseScale),
                        child: Text(
                          '+${widget.coins}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Scabber',
                            color: Colors.white,
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
    final progress = Curves.easeOut.transform(
      math.max(0.0, math.min(1.0, (_particleController.value - particle.delay) / (1.0 - particle.delay))),
    );

    final x = math.cos(particle.angle) * particle.distance * progress;
    final y = math.sin(particle.angle) * particle.distance * progress;

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
