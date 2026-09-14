import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/core/errors/app_exception.dart';
import 'package:zifromania/core/errors/domain_exception.dart';
import 'package:zifromania/features/auth/auth_module.dart';
import 'package:zifromania/features/auth/presentation/providers/auth_notifier.dart';

class AuthActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<AppException?> signInWithGoogle() async {
    if (state.isLoading) return null;

    state = const AsyncLoading();

    try {
      final usecase = ref.read(signInWithGoogleUseCaseProvider);
      final user = await usecase.call();

      ref.read(authNotifierProvider.notifier).setUser(user);
      state = const AsyncData(null);

      return null;
    } catch (e, st) {
      final exception = e is AppException ? e : UnknownException(error: e, stackTrace: st);
      state = AsyncError(exception, st);

      return exception;
    }
  }

  Future<void> signOut() async {
    if (state.isLoading) return;

    state = const AsyncLoading();

    try {
      final usecase = ref.read(signOutUseCaseProvider);
      await usecase.call();

      ref.read(authNotifierProvider.notifier).setUser(null);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clearError() {
    if (state.hasError) {
      state = const AsyncData(null);
    }
  }
}

final authActionNotifierProvider = AsyncNotifierProvider<AuthActionNotifier, void>(
  AuthActionNotifier.new,
);
