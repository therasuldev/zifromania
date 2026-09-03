import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/rank/rank_module.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

/// Liderlər lövhəsinin ilk N istifadəçisini bir dəfəlik gətirən provider.
/// UI-da `ref.watch(topRankedUsersProvider)` ilə `AsyncValue<List<UserModel>>`
/// olaraq istifadə olunur.
final topRankedUsersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final useCase = ref.watch(fetchTopRankedUsersUseCaseProvider);
  return useCase();
});

/// Liderlər lövhəsini real-vaxt rejimində izləyən provider.
final topRankedUsersStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final useCase = ref.watch(streamTopRankedUsersUseCaseProvider);
  return useCase();
});

/// Konkret bir istifadəçinin (userId) reytinq mövqeyini gətirən family provider.
/// UI-da: `ref.watch(userRankPositionProvider(userId))`
final userRankPositionProvider = FutureProvider.autoDispose.family<int, String>((ref, userId) async {
  final useCase = ref.watch(getUserRankPositionUseCaseProvider);
  return useCase(userId);
});
