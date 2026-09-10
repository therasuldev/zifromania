import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/auth/auth_module.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() async {
    return ref.read(getCurrentUserUseCaseProvider).call();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    try {
      final usecase = ref.read(signInWithGoogleUseCaseProvider);
      final user = await usecase.call();

      state = AsyncData(user);
    } on GoogleSignInCancelledException {
      // user canceled the sign-in process, so we can just set the state to null or handle it accordingly
      // this is not an error.
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
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
