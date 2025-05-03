// lib/main.dart (Updated)
import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/presentation/screens/auth_screen.dart';
import 'package:zifromania/presentation/screens/splash_screen.dart';
import 'package:zifromania/presentation/screens/game_intro_screen.dart';
import 'package:zifromania/presentation/state_managment/ad_manager.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_bloc.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_event.dart';
import 'package:zifromania/presentation/state_managment/auth/auth_state.dart';
import 'package:zifromania/presentation/state_managment/game/game_bloc.dart';
import 'package:zifromania/presentation/state_managment/in-app-purchase/in_app_purchase.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/widgets/versionarte_gate.dart';
import 'services/in_app_purchase_service.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Reklam servisini başlatmaq
  final adManager = AdManager();
  await adManager.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => AuthService()),
          RepositoryProvider(create: (_) => InAppPurchaseService()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (ctx) => AuthBloc(authService: ctx.read<AuthService>())),
            BlocProvider(
              create: (context) => PurchaseBloc(
                purchaseService: InAppPurchaseService(),
              )..add(InitializePurchase()),
            ),
            BlocProvider(create: (_) => GameBloc()),
          ],
          child: const ZifroMania(),
        ),
      ),
    ),
  );
}

class ZifroMania extends StatelessWidget {
  const ZifroMania({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zifromania',
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: const VersionarteGate(child: SplashScreen()),
      builder: (ctx, child) {
        return BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.event != current.event,
          listener: (context, state) {
            if (state.event == AuthEvents.authenticated) {
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const GameIntroScreen(),
                  settings: const RouteSettings(name: 'game_intro'),
                ),
                (_) => false,
              );
            } else if (state.event == AuthEvents.unauthenticated) {
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const SignInPage(),
                  settings: const RouteSettings(name: 'sign_in'),
                ),
                (_) => false,
              );
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
