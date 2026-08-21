import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/auth/auth_module.dart';
import 'package:zifromania/features/auth/data/models/user_model.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() async {
    return ref.read(getCurrentUserUseCaseProvider).call();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final usecase = ref.read(signInWithGoogleUseCaseProvider);
      return await usecase.call();
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final usecase = ref.read(signOutUseCaseProvider);
      await usecase.call();

      return null;
    });
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
