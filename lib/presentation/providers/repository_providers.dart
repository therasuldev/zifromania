// lib/presentation/providers/repository_providers.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/presentation/state-managment/ad_manager.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/in_app_purchase_service.dart';
import 'package:zifromania/services/settings_service.dart';
import 'package:zifromania/services/sound_service.dart';
import 'package:zifromania/services/task_service.dart';
import 'package:zifromania/services/title_service.dart';
import 'package:zifromania/services/user_service.dart';
import '../../locator.dart';

final repositoryProviders = [
  RepositoryProvider.value(value: locator.get<AuthService>()),
  RepositoryProvider.value(value: locator.get<InAppPurchaseService>()),
  RepositoryProvider.value(value: locator.get<UserService>()),
  RepositoryProvider.value(value: locator.get<SecureCacheService>()),
  RepositoryProvider.value(value: locator.get<SettingsService>()),
  RepositoryProvider.value(value: locator.get<SoundService>()),
  RepositoryProvider.value(value: locator.get<AdManager>()),
  RepositoryProvider.value(value: locator.get<TaskService>()),
  RepositoryProvider.value(value: locator.get<TitleService>()),
];
