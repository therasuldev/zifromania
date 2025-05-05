import 'package:zifromania/models/user_model.dart';
import 'auth_event.dart';

class AuthState {
  final UserModel? user;
  final AuthEvents? event;
  final String? error;

  const AuthState({
    this.user,
    this.event,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    AuthEvents? event,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      event: event ?? this.event,
      error: error, // Allow null to clear errors
    );
  }

  factory AuthState.initial() => const AuthState(event: null);
}
