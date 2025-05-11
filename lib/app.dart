import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/locator.dart';

import 'core/widgets/versionarte_gate.dart';
import 'domain/entities/constant.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/game_intro_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/state_managment/auth/auth_bloc.dart';
import 'presentation/state_managment/auth/auth_event.dart';
import 'presentation/state_managment/auth/auth_state.dart';
import 'services/settings_service.dart';
import 'services/sound_service.dart';

class ZifroMania extends StatefulWidget {
  final SoundService soundService;

  const ZifroMania({super.key, required this.soundService});

  @override
  State<ZifroMania> createState() => _ZifroManiaState();
}

class _ZifroManiaState extends State<ZifroMania> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Start background music
    widget.soundService.playBackgroundMusic('sounds/zifromania_background.mp3');

    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Manage background music based on app lifecycle
    final settingsService = locator.get<SettingsService>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        widget.soundService.pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        if (settingsService.getMusicEnabled()) {
          widget.soundService.resumeBackgroundMusic();
        }
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZifroMania',
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: const VersionarteGate(child: SplashScreen()),
      builder: (ctx, child) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Handle authentication events for navigation
            if (state.event == AuthEvents.authenticated) {
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const GameIntroScreen(),
                  settings: const RouteSettings(name: 'game_intro'),
                ),
                (_) => false,
              );
            } else if (state.event == AuthEvents.unauthenticated) {
              // and also about checking the current route
              final navigator = navigatorKey.currentState;
              if (navigator != null) {
                // Safe navigation to SignInPage
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const AuthScreen(),
                    settings: const RouteSettings(name: 'sign_in'),
                  ),
                  (_) => false,
                );
              }
            }

            // Display errors if present
            if (state.error != null && state.error!.isNotEmpty) {
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          child: child,
        );
      },
    );
  }
}
