import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/auth/auth_module.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() {
    return ref.read(getCurrentUserUseCaseProvider).call();
  }

  void setUser(UserModel? user) {
    state = AsyncData(user);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
