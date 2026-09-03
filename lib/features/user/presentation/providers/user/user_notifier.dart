import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/user_module.dart';

/// Cari istifadəçini real-time olaraq dinləyir (watchUser).
final userProvider = StreamProvider.family<UserEntity, String>(
  (ref, uid) {
    final watchUser = ref.watch(watchUserUseCaseProvider);

    return watchUser(uid);
  },
);

/// User-ə aid mutasiya (action) əməliyyatlarını idarə edir:
/// profil yaratma, coin/xp əlavə etmə-xərcləmə, silmə.
class UserActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Başlanğıc state-ə ehtiyac yoxdur, sadəcə action-lar üçün istifadə olunur.
  }

  Future<void> createUserProfile(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(createUserProfileUseCaseProvider).call(user);
    });
  }

  Future<void> addCoins({required String uid, required int amount}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addCoinsUseCaseProvider).call(uid: uid, amount: amount);
    });
  }

  Future<void> spendCoins({required String uid, required int amount}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(spendCoinsUseCaseProvider).call(uid: uid, amount: amount);
    });
  }

  Future<void> addXp({required String uid, required int xp}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addXpUseCaseProvider).call(uid: uid, xp: xp);
    });
  }

  Future<void> deleteUser(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteUserUseCaseProvider).call(uid);
    });
  }
}

final userActionsProvider = AsyncNotifierProvider<UserActionsNotifier, void>(UserActionsNotifier.new);
