// auth_bloc.dart
import 'dart:async';
import 'package:equation_quest/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  late StreamSubscription<User?> _authStateSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthState.initial()) {
    on<AuthEvent>(_onAuthEvent);
    // Initialize the subscription to listen to Firebase auth state changes
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthEvent.authenticated());
      } else {
        add(AuthEvent.loggedOut());
      }
    });
  }

  void _onAuthEvent(AuthEvent event, Emitter<AuthState> emit) async {
    switch (event.type) {
      case AuthEvents.authenticated:
        _onLoggedIn(event, emit);
      case AuthEvents.googleSignInRequested:
        await _onGoogleSignInRequested(event, emit);
      case AuthEvents.appleSignInRequested:
        await _onAppleSignInRequested(event, emit);
      case AuthEvents.loggedOut:
        await _onLoggedOut(event, emit);
      default:
        break;
    }
  }

  void _onLoggedIn(AuthEvent event, Emitter<AuthState> emit) {
    final User? currentUser = _authService.currentUser;
    if (currentUser != null) {
      emit(state.copyWith(event: AuthEvents.authenticated, user: currentUser));
    }
  }

  Future<void> _onGoogleSignInRequested(AuthEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(event: AuthEvents.googleSignInRequested));
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        emit((state.copyWith(error: 'Google sign in aborted', event: AuthEvents.unauthenticated)));
      } else {
        emit((state.copyWith(event: AuthEvents.authenticated, user: result.user)));
      }
      // The subscription will handle the state change to Authenticated
    } catch (e) {
      emit((state.copyWith(error: e.toString(), event: AuthEvents.unauthenticated)));
    }
  }

  Future<void> _onAppleSignInRequested(AuthEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(event: AuthEvents.appleSignInRequested));
    try {
      final result = await _authService.signInWithApple();
      if (result == null) {
        emit((state.copyWith(error: 'Apple sign in aborted')));
      } else {
        emit((state.copyWith(event: AuthEvents.authenticated, user: result.user)));
      }
      // The subscription will handle the state change to Authenticated
    } catch (e) {
      emit((state.copyWith(error: e.toString(), event: AuthEvents.unauthenticated)));
    }
  }

  Future<void> _onLoggedOut(AuthEvent event, Emitter<AuthState> emit) async {
    try {
      await _authService.signOut();
      emit((state.copyWith(event: AuthEvents.unauthenticated)));
    } catch (e) {
      emit((state.copyWith(error: e.toString())));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
