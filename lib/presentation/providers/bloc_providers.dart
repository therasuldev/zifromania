// lib/presentation/providers/bloc_providers.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/presentation/state-managment/tasks-bloc/task_bloc.dart';
import 'package:zifromania/presentation/state-managment/titles-bloc/title_bloc.dart';
import 'package:zifromania/services/audio_service.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/in_app_purchase_service.dart';
import 'package:zifromania/services/open_ai_service.dart';
import 'package:zifromania/services/settings_service.dart';
import 'package:zifromania/services/title_service.dart';
import 'package:zifromania/services/user_service.dart';

import '../../locator.dart';
import '../state-managment/auth/auth_bloc.dart';
import '../state-managment/game/game_bloc.dart';
import '../state-managment/in-app-purchase/in_app_purchase.dart';
import '../state-managment/settings/settings_bloc.dart';

final List<BlocProvider> blocProviders = [
  BlocProvider<AuthBloc>(
    create: (_) {
      return AuthBloc(
        authService: locator.get<AuthService>(),
        userService: locator.get<UserService>(),
        cacheService: locator.get<SecureCacheService>(),
      );
    },
  ),
  BlocProvider<PurchaseBloc>(
    create: (_) {
      return PurchaseBloc(
        purchaseService: locator.get<InAppPurchaseService>(),
      )..add(InitializePurchase());
    },
  ),
  BlocProvider<SettingsBloc>(
    create: (_) {
      return SettingsBloc(
        settingsService: locator.get<SettingsService>(),
      )..add(SettingsEvent.getLanguage());
    },
  ),
  BlocProvider<GameBloc>(
    create: (_) {
      return GameBloc(
        authService: locator.get<AuthService>(),
        userService: locator.get<UserService>(),
        audioService: locator.get<AudioService>(),
        openAIService: locator.get<EnhancedOpenAIService>(),
        titleService: locator.get<TitleService>(),
        inAppPurchaseService: locator.get<InAppPurchaseService>(),
      );
    },
  ),
  BlocProvider<TaskBloc>(
    create: (_) {
      return TaskBloc()..add(TaskEvent.fetchAllTasksStart());
    },
  ),
  BlocProvider<TitleBloc>(
    create: (_) {
      return TitleBloc(
        titleService: locator.get<TitleService>(),
        cacheService: locator.get<SecureCacheService>(),
      )..add(TitleEvent.fetchUserTitlesStart());
    },
  ),
];
