// Create this as a separate widget file: title_reward_dialog.dart

import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';

import '../fireworks_congratulations.dart';

class TitleRewardDialog extends StatefulWidget {
  final List<TitleModel> titles;
  final VoidCallback? onComplete;

  const TitleRewardDialog({
    super.key,
    required this.titles,
    this.onComplete,
  });

  @override
  State<TitleRewardDialog> createState() => _TitleRewardDialogState();
}

class _TitleRewardDialogState extends State<TitleRewardDialog> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _transitionController; // Yeni controller

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideFromRightAnimation; // Sağdan sola animasiya
  late Animation<Offset> _slideToLeftAnimation; // Soldan çıxış animasiyası

  int _currentTitleIndex = 0;

  @override
  void initState() {
    super.initState();

    // Main animation controller for the trophy/medal
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Transition controller for title switching
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Set up animations
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Sağdan sola animasiya
    _slideFromRightAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));

    // Soldan çıxış animasiyası
    _slideToLeftAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInCubic,
    ));

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start particle animation
    _particleController.repeat();

    // Initialize transition controller for first title
    await _transitionController.forward();

    // Start main trophy animation
    await _mainController.forward();

    // Start text animation
    await _textController.forward();
  }

  void _nextTitle() async {
    if (_currentTitleIndex < widget.titles.length - 1) {
      // Start transition animation
      await _transitionController.forward();

      // Update to next title
      setState(() {
        _currentTitleIndex++;
      });

      // Reset and start transition animation for new title
      _transitionController.reset();
      await _transitionController.forward();
    } else {
      // 🆕 Call the onComplete callback when finishing all titles
      if (widget.onComplete != null) {
        widget.onComplete!();
      } else {
        // Fallback: close dialog if no callback provided
        Navigator.of(context).pop();
      }
    }
  }

  String _getTitleIconAsset(String key) {
    return "assets/title-avatars/$key.png";
  }

  Color _getTitleColor(String key) {
    return switch (key) {
      'xp-seeker' => Colors.cyanAccent,
      'expert-challenger' => Colors.red,
      'legendary' => Colors.deepOrangeAccent,
      'marathon-mind' => Colors.blue,
      'multiplier-master' => Colors.yellow,
      'no-mistake' => Colors.green,
      'speedster' => Colors.orange,
      'persistent-player' => Colors.purple,
      'quick-thinker' => Colors.lightBlueAccent,
      'truth-seeker' => Colors.teal,
      'zifro-premium' => Colors.purpleAccent,
      _ => Colors.white,
    };
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FireworksCongratulationsWidget(
            textColor: Colors.blueGrey.shade300,
          ),

          // Particle effect background
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated particles
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(310, 310),
                    painter: ParticlePainter(
                      animationValue: _particleController.value,
                      particleColor: Colors.cyan,
                    ),
                  );
                },
              ),

              // Main trophy/medal animation with transition
              AnimatedBuilder(
                animation: Listenable.merge([_mainController, _transitionController]),
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideFromRightAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * math.sin(_mainController.value * 4 * math.pi),
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getTitleColor(widget.titles[_currentTitleIndex].key).withValues(alpha: 0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(_getTitleIconAsset(widget.titles[_currentTitleIndex].key)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title text animation with transition
          AnimatedBuilder(
            animation: Listenable.merge([_textController, _transitionController]),
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: SlideTransition(
                  position: _slideFromRightAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          context.tr('new_title_unlocked'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[300],
                            fontFamily: 'Scabber',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _getTitleColor(widget.titles[_currentTitleIndex].key).withValues(alpha: .5),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            widget.titles[_currentTitleIndex].name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Scabber',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.titles.length > 1) ...[
                          const SizedBox(height: 10),
                          Text(
                            '${_currentTitleIndex + 1} / ${widget.titles.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Scabber',
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Continue/Close button
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return Opacity(
                opacity: _textController.value,
                child: PressableFilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(_getTitleColor(widget.titles[_currentTitleIndex].key).withValues(alpha: .2)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  onPressed: _nextTitle,
                  child: Text(
                    _currentTitleIndex < widget.titles.length - 1 ? context.tr('continue') : context.tr('close'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Scabber',
                      fontWeight: FontWeight.w600,
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

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Color particleColor;

  ParticlePainter({
    required this.animationValue,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42); // Fixed seed for consistent animation

    // Draw particles
    for (int i = 0; i < 15; i++) {
      final angle = (i / 15) * 2 * math.pi;
      final distance = 130 + (35 * math.sin(animationValue * 2 * math.pi + i));
      final particleSize = 3 + (2 * math.sin(animationValue * 3 * math.pi + i));

      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      final alpha = 0.3 + 0.4 * math.sin(animationValue * 2 * math.pi + i).abs();
      paint.color = Colors.cyanAccent.withValues(alpha: alpha);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }

    // Draw sparkles
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + animationValue * 2 * math.pi;
      final distance = 110 + (25 * math.sin(animationValue * 4 * math.pi));

      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      _drawSparkle(canvas, Offset(x, y), 10);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw cross shape for sparkle
    canvas.drawLine(
      Offset(center.dx - size / 2, center.dy),
      Offset(center.dx + size / 2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size / 2),
      Offset(center.dx, center.dy + size / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
