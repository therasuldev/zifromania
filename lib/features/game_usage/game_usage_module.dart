import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/shared_prefs_provider.dart';

import 'data/datasource/game_usage_local_datasource.dart';
import 'data/datasource/game_usage_local_datasource_impl.dart';
import 'data/repositories/game_usage_repositories_impl.dart';

final gameUsageLocalDataSourceProvider = Provider<GameUsageLocalDataSource>(
  (ref) => GameUsageLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider)),
);

final gameUsageRepositoryProvider = Provider<GameUsageRepositoryImpl>(
  (ref) => GameUsageRepositoryImpl(dataSource: ref.watch(gameUsageLocalDataSourceProvider)),
);
