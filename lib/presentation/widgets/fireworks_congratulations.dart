
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class FireworksCongratulationsWidget extends StatefulWidget {
  final String text;
  final double fontSize;
  final String fontFamily;
  final Color textColor;

  const FireworksCongratulationsWidget({
    super.key,
    this.text = 'Congratulations!',
    this.fontSize = 30,
    this.fontFamily = 'Scabber',
    this.textColor = const Color(0xCCFFFFFF),
  });

  @override
  State<FireworksCongratulationsWidget> createState() => _FireworksCongratulationsWidgetState();
}

class _FireworksCongratulationsWidgetState extends State<FireworksCongratulationsWidget> with TickerProviderStateMixin {
  late AnimationController _fireworksController;
  late AnimationController _textController;
  late Animation<double> _textScaleAnimation;

  List<Particle> particles = [];
  final math.Random random = math.Random();
  Timer? _fireworksTimer;

  @override
  void initState() {
    super.initState();

    // Fişəng animasiyası üçün controller - davamlı loop
    _fireworksController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Mətn animasiyası üçün controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    // Animasiyaları başlat
    _startAnimation();
  }

  void _startAnimation() async {
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // İlk fişəng yaradıb
    _createFireworks();
    _fireworksController.forward();

    // Davamlı fişəng animasiyası
    _startContinuousFireworks();
  }

  void _startContinuousFireworks() {
    _fireworksTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        _addNewFirework();
      } else {
        timer.cancel();
      }
    });

    // Controller-i davam etdir
    _fireworksController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _fireworksController.reset();
        _fireworksController.forward();
      }
    });
  }

  void _addNewFirework() {
    // Yeni fişəng əlavə et
    double centerX = 80 + random.nextDouble() * 150;
    double centerY = 30 + random.nextDouble() * 100;

    // Hər fişəng üçün parçacıqlar yaradıb
    for (int j = 0; j < 12; j++) {
      double angle = random.nextDouble() * 2 * math.pi;
      double speed = 25 + random.nextDouble() * 35;

      particles.add(Particle(
        startX: centerX,
        startY: centerY,
        velocityX: math.cos(angle) * speed,
        velocityY: math.sin(angle) * speed,
        color: _getRandomColor(),
        size: 2 + random.nextDouble() * 3,
        creationTime: DateTime.now().millisecondsSinceEpoch,
        lifespan: 2000 + random.nextInt(1000), // 2-3 saniyə həyat müddəti
      ));
    }

    // Köhnə parçacıqları təmizlə
    _cleanupOldParticles();
  }

  void _createFireworks() {
    // İlk fişəng partlaması
    for (int i = 0; i < 2; i++) {
      double centerX = 100 + random.nextDouble() * 150;
      double centerY = 50 + random.nextDouble() * 100;

      // Hər fişəng üçün parçacıqlar yaradıb
      for (int j = 0; j < 12; j++) {
        double angle = random.nextDouble() * 2 * math.pi;
        double speed = 25 + random.nextDouble() * 35;

        particles.add(Particle(
          startX: centerX,
          startY: centerY,
          velocityX: math.cos(angle) * speed,
          velocityY: math.sin(angle) * speed,
          color: _getRandomColor(),
          size: 2 + random.nextDouble() * 3,
          creationTime: DateTime.now().millisecondsSinceEpoch,
          lifespan: 2000 + random.nextInt(1000),
        ));
      }
    }
  }

  void _cleanupOldParticles() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    particles.removeWhere((particle) {
      return currentTime - particle.creationTime > particle.lifespan;
    });
  }

  Color _getRandomColor() {
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    _textController.dispose();
    _fireworksTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fişəng parçacıqları
            AnimatedBuilder(
              animation: _fireworksController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(350, 200),
                  painter: FireworksPainter(
                    particles: particles,
                    currentTime: DateTime.now().millisecondsSinceEpoch,
                  ),
                );
              },
            ),

            // Mətn
            AnimatedBuilder(
              animation: _textScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _textScaleAnimation.value,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontFamily: widget.fontFamily,
                      color: widget.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Particle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final int creationTime;
  final int lifespan;

  Particle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.creationTime,
    required this.lifespan,
  });
}

class FireworksPainter extends CustomPainter {
  final List<Particle> particles;
  final int currentTime;

  FireworksPainter({required this.particles, required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      int age = currentTime - particle.creationTime;
      if (age < 0) continue;

      double progress = age / particle.lifespan.toDouble();
      if (progress >= 1.0) continue;

      // Parçacığın pozisiyası
      double timeInSeconds = age / 1000.0;
      double x = particle.startX + particle.velocityX * timeInSeconds;
      double y = particle.startY + particle.velocityY * timeInSeconds + 0.5 * 30 * timeInSeconds * timeInSeconds; // Cazibə effekti

      // Şəffaflıq azaldıb
      double opacity = math.max(0, 1 - progress);

      // Ölçü kiçildir
      double currentSize = particle.size * (1 - progress * 0.3);

      if (opacity > 0 && currentSize > 0) {
        final paint = Paint()
          ..color = particle.color.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;

        // Parıltı effekti üçün
        canvas.drawCircle(
          Offset(x, y),
          currentSize + 1,
          Paint()
            ..color = Colors.white.withValues(alpha: opacity * 0.4)
            ..style = PaintingStyle.fill,
        );

        // Əsas parçacıq
        canvas.drawCircle(Offset(x, y), currentSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
