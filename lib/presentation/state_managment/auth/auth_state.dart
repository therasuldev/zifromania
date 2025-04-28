// auth_state.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';

class AuthState {
  final User? user;
  final AuthEvents? event;
  final String? error;

  const AuthState({this.user, this.event, this.error});

  AuthState copyWith({User? user, AuthEvents? event, String? error}) {
    return AuthState(
      user: user ?? this.user,
      event: event ?? this.event,
      error: error ?? this.error,
    );
  }

  AuthState.initial()
      : user = null,
        event = null,
        error = null;
}
