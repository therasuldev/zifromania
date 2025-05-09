// ==========================
// auth_bloc.dart
// ==========================
import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/user_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc now exposes [checkAuthentication] so you can yeet the auth‑check
/// straight from your splash screen, instead of doing it in the constructor.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserService _userService;
  final SecureCacheService _cacheService;
  late final StreamSubscription<firebase.User?> _authStateSubscription;
  StreamSubscription<UserModel>? _profileSub;

  AuthBloc({
    required AuthService authService,
    required UserService userService,
    required SecureCacheService cacheService,
  })  : _authService = authService,
        _userService = userService,
        _cacheService = cacheService,
        super(AuthState.initial()) {
    _profileSub = _userService.streamUserData(_authService.currentUser?.uid ?? '').listen(
          (user) => add(AuthEvent.profileSynced(user)),
        );
    // 1️⃣ Universal event handler (single entry point, because simplicity rules)
    on<AuthEvent>((event, emit) async {
      debugPrint('🔥 AuthBloc → event: ${event.type}, payload: ${event.payload}');
      await _onAuthEvent(event, emit);
    });

    // 2️⃣ Firebase auth state subscription
    _authStateSubscription = _authService.authStateChanges.listen(_onFirebaseAuthChanged);
  }

  /// 🌊 Public API — call this from the SplashScreen to kick‑start the cached
  /// user check.  Returns a [Future] so you can await it if you feel like it.
  Future<void> checkAuthentication() async => _checkCachedUser();

  // ---------- PRIVATE HELPERS ----------
  Future<void> _checkCachedUser() async {
    try {
      final UserModel? cachedUser = await _cacheService.read<UserModel>('user');

      if (cachedUser != null && cachedUser.uid.isNotEmpty) {
        emit(state.copyWith(
          user: cachedUser,
          event: AuthEvents.authenticated,
          error: null,
        ));

        // Silent Firestore refresh ✨
        _refreshUserData(cachedUser.uid);
      }
    } catch (e) {
      debugPrint('💥 Cache read error: $e');
      await _cacheService.delete('user');
    }
  }

  Future<void> _refreshUserData(String uid) async {
    try {
      final UserModel refreshedUser = await _userService.fetchFullUser(uid);
      await _cacheService.write<UserModel>('user', refreshedUser);
      emit(state.copyWith(
        user: refreshedUser,
        event: AuthEvents.loadProfileSuccess,
      ));
    } catch (e) {
      emit(state.copyWith(
        event: AuthEvents.loadProfileError,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthEvent(AuthEvent event, Emitter<AuthState> emit) async {
    try {
      switch (event.type) {
        case AuthEvents.authenticated:
          if (event.payload is UserModel) {
            await _handleAuthenticated(event.payload as UserModel, emit);
          } else {
            _handleError('Invalid payload for authenticated event', emit);
          }
          break;
        case AuthEvents.unauthenticated:
          await _handleUnauthenticated(emit);
          break;
        case AuthEvents.googleSignInRequested:
          await _handleGoogleSignInRequested(emit);
          break;
        case AuthEvents.loggedOutStart:
          await _handleLoggedOutStart(emit);
          break;
        case AuthEvents.profileSynced:
          await _handleProfileSynced(event.payload as UserModel, emit);
          break;
        case AuthEvents.loadProfileStart:
          if (event.payload is String) {
            await _refreshUserData(event.payload as String);
          } else {
            _handleError('Invalid payload for loadProfileStart event', emit);
          }
          break;
        default:
          debugPrint('✨ Unhandled event: ${event.type}');
          break;
      }
    } catch (e) {
      _handleError(e, emit);
    }
  }

  void _onFirebaseAuthChanged(firebase.User? fbUser) {
    if (fbUser != null) {
      final basicUser = UserModel.fromFirebaseUser(fbUser);
      add(AuthEvent.authenticated(basicUser));
    } else {
      add(AuthEvent.unauthenticated());
    }
  }

  Future<void> _handleProfileSynced(UserModel user, Emitter<AuthState> emit) async {
    //await _cacheService.write<UserModel>('user', user);
    log('Profile synced: ${user.toString()}');
    emit(state.copyWith(user: user, event: AuthEvents.profileSynced));
  }

  Future<void> _handleAuthenticated(UserModel basicUser, Emitter<AuthState> emit) async {
    if (basicUser.uid.isEmpty) {
      emit(state.copyWith(event: AuthEvents.loadProfileError, error: 'Invalid user data received'));
      return;
    }
    try {
      emit(state.copyWith(user: basicUser, event: AuthEvents.authenticated));
      await _userService.createUserProfile(basicUser);
      final fullUser = await _userService.fetchFullUser(basicUser.uid);
      await _cacheService.write<UserModel>('user', fullUser);
      emit(state.copyWith(
        user: fullUser,
        event: AuthEvents.authenticated,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        user: basicUser,
        event: AuthEvents.loadProfileError,
        error: 'Failed to load complete profile: ${e.toString()}',
      ));
    }
  }

  Future<void> _handleUnauthenticated(Emitter<AuthState> emit) async {
    await _cacheService.delete('user');
    emit(state.copyWith(
      event: AuthEvents.unauthenticated,
      user: null,
      error: null,
    ));
  }

  Future<void> _handleGoogleSignInRequested(Emitter<AuthState> emit) async {
    emit(state.copyWith(event: AuthEvents.googleSignInRequested));
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        emit(state.copyWith(
          event: AuthEvents.googleSignInRequestedError,
          error: 'Google sign‑in was cancelled',
        ));
      } else {
        emit(state.copyWith(event: AuthEvents.googleSignInRequestedSuccess));
      }
    } catch (e) {
      emit(state.copyWith(
        event: AuthEvents.googleSignInRequestedError,
        error: 'Google sign‑in failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _handleLoggedOutStart(Emitter<AuthState> emit) async {
    emit(state.copyWith(event: AuthEvents.loggedOutStart));
    try {
      await _cacheService.delete('user');
      await _authService.signOut();
    } catch (e) {
      emit(state.copyWith(
        event: AuthEvents.loggedOutError,
        error: 'Error during sign‑out: ${e.toString()}',
      ));
    }
  }

  void _handleError(Object error, Emitter<AuthState> emit) {
    emit(state.copyWith(
      event: AuthEvents.googleSignInRequestedError,
      error: error.toString(),
    ));
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    _profileSub?.cancel();
    return super.close();
  }
}
