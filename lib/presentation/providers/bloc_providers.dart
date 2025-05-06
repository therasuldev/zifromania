// lib/presentation/providers/bloc_providers.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/in_app_purchase_service.dart';
import 'package:zifromania/services/settings_service.dart';
import 'package:zifromania/services/user_service.dart';

import '../../locator.dart';
import '../state_managment/auth/auth_bloc.dart';
import '../state_managment/game/game_bloc.dart';
import '../state_managment/in-app-purchase/in_app_purchase.dart';
import '../state_managment/settings/settings_bloc.dart';

final blocProviders = [
  BlocProvider(
    create: (ctx) => AuthBloc(
      authService: locator.get<AuthService>(),
      userService: locator.get<UserService>(),
      cacheService: locator.get<SecureCacheService>(),
    ),
  ),
  BlocProvider(
    create: (_) => PurchaseBloc(
      purchaseService: locator.get<InAppPurchaseService>(),
    )..add(InitializePurchase()),
  ),
  BlocProvider(
    create: (_) => SettingsBloc(
      settingsService: locator.get<SettingsService>(),
    ),
  ),
  BlocProvider(create: (_) => GameBloc()),
];
