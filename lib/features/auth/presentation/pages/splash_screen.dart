import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_provider.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _navigationTimer;
  bool _authResolved = false;
  bool _minimumDurationCompleted = false;
  UserModel? _user;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.6,
          curve: Curves.easeIn,
        ),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.2,
          0.8,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _animationController.forward();

    // Splash minimum 2 seconds göstərilsin.
    _navigationTimer = Timer(
      const Duration(seconds: 2),
      () {
        _minimumDurationCompleted = true;
        _tryNavigate();
      },
    );
  }

  void _tryNavigate() {
    if (!mounted) return;

    if (!_authResolved || !_minimumDurationCompleted) {
      return;
    }

    if (_user != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserModel?>>(
      authNotifierProvider,
      (previous, next) {
        next.when(
          loading: () {
            // Authentication yoxlanılır.
          },
          data: (user) {
            _user = user;
            _authResolved = true;
            _tryNavigate();
          },
          error: (error, stackTrace) {
            _user = null;
            _authResolved = true;
            _tryNavigate();
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withValues(
                              alpha: 0.5,
                            ),
                            offset: const Offset(0, 10),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/zifromania.png',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'ZifroMania',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Challenge your mind',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
