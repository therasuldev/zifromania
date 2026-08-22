import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Initialize SharedPreferences in main.dart and override this provider in
  // ProviderScope before running the application.
  throw UnimplementedError('SharedPreferences must be initialized and provided from main.dart.');
});
