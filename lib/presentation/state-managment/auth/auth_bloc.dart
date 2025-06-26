import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/user_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  final SecureCacheService _cacheService;
  late final StreamSubscription<UserModel?> _userStreamSubscription;

  AuthBloc({
    required AuthService authService,
    required UserService userService,
    required SecureCacheService cacheService,
  })  : _authService = authService,
        _cacheService = cacheService,
        super(AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      debugPrint('🔥 AuthBloc → event: ${event.type}, payload: ${event.payload}');
      await _onAuthEvent(event, emit);
    });

    // AuthService-dən user stream dinləməsi
    _userStreamSubscription = _authService.userStream.listen((user) {
      if (user != null) {
        add(AuthEvent.authenticated(user));
      } else {
        add(AuthEvent.unauthenticated());
      }
    });
  }

  /// Public API - SplashScreen-dən çağırılır
  Future<void> checkAuthentication() async {
    try {
      final UserModel? cachedUser = await _cacheService.read<UserModel>('user');
      final bool isSignedIn = await _authService.isSignedIn();

      if (cachedUser != null && isSignedIn) {
        debugPrint('✅ Cache-dən user tapıldı: ${cachedUser.uid}');

        // Cache-ddən user-i göstər
        emit(state.copyWith(
          user: cachedUser,
          event: AuthEvents.authenticated,
          error: null,
        ));

        // Arxa planda yenilə
        _refreshUserDataSilently();
      } else {
        // Cache köhnədir və ya user sign-in olmayıb
        await _cacheService.delete('user');

        if (isSignedIn) {
          // Firebase-də user var, tam məlumatları yüklə
          final currentUser = await _authService.getCurrentUser();
          if (currentUser != null) {
            await _cacheService.write<UserModel>('user', currentUser);
            emit(state.copyWith(
              user: currentUser,
              event: AuthEvents.authenticated,
              error: null,
            ));
          } else {
            emit(state.copyWith(
              event: AuthEvents.unauthenticated,
              user: null,
              error: null,
            ));
          }
        } else {
          debugPrint('❌ Heç bir authenticated user tapılmadı');
          emit(state.copyWith(
            event: AuthEvents.unauthenticated,
            user: null,
            error: null,
          ));
        }
      }
    } catch (e) {
      debugPrint('💥 Cache yoxlama xətası: $e');
      await _cacheService.delete('user');
      emit(state.copyWith(
        event: AuthEvents.unauthenticated,
        user: null,
        error: 'Authentication check failed: ${e.toString()}',
      ));
    }
  }

  /// Arxa planda user məlumatlarını yenilə
  Future<void> _refreshUserDataSilently() async {
    try {
      final refreshedUser = await _authService.getCurrentUser();
      if (refreshedUser != null) {
        await _cacheService.write<UserModel>('user', refreshedUser);

        // Yalnız məlumatlar dəyişibsə state-i yenilə
        if (state.user != null && !_areUsersEqual(state.user!, refreshedUser)) {
          emit(state.copyWith(
            user: refreshedUser,
            event: AuthEvents.profileSynced,
          ));
        }
      }
    } catch (e) {
      debugPrint('⚠️ Səssiz user yeniləmə xətası: $e');
    }
  }

  /// İki user eyni olub-olmadığını yoxla
  bool _areUsersEqual(UserModel user1, UserModel user2) {
    return user1.uid == user2.uid &&
        user1.displayName == user2.displayName &&
        user1.email == user2.email &&
        user1.coins == user2.coins &&
        user1.level == user2.level &&
        user1.xp == user2.xp;
  }

  // ---------- EVENT HANDLERS ----------

  Future<void> _onAuthEvent(AuthEvent event, Emitter<AuthState> emit) async {
    try {
      switch (event.type) {
        case AuthEvents.authenticated:
          await _handleAuthenticated(event.payload as UserModel, emit);
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
            await _refreshUserDataSilently();
          }
          break;

        default:
          debugPrint('✨ İşlənməyən event: ${event.type}');
          break;
      }
    } catch (e) {
      _handleError(e, emit);
    }
  }

  Future<void> _handleAuthenticated(UserModel user, Emitter<AuthState> emit) async {
    debugPrint('✅ User authenticated: ${user.uid}');

    // Cache-ə yaz
    await _cacheService.write<UserModel>('user', user);

    // State-i yenilə
    emit(state.copyWith(
      user: user,
      event: AuthEvents.authenticated,
      error: null,
    ));
  }

  Future<void> _handleUnauthenticated(Emitter<AuthState> emit) async {
    debugPrint('❌ User unauthenticated');

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
      final user = await _authService.signInWithGoogle();
      debugPrint('✅ Google sign-in successful: ${user.uid}');

      // Cache-ə yaz
      await _cacheService.write<UserModel>('user', user);

      // Authenticated event göndər (daha məntiqi)
      emit(state.copyWith(
        user: user,
        event: AuthEvents.authenticated,
        error: null,
      ));
    } catch (e) {
      debugPrint('💥 Google sign-in error: $e');
      emit(state.copyWith(
        event: AuthEvents.googleSignInRequestedError,
        error: e.toString(),
      ));
    }
  }

  Future<void> _handleLoggedOutStart(Emitter<AuthState> emit) async {
    emit(state.copyWith(event: AuthEvents.loggedOutStart));

    try {
      await _cacheService.delete('user');
      await _authService.signOut();

      emit(state.copyWith(
        event: AuthEvents.loggedOutSuccess,
        user: null,
        error: null,
      ));
    } catch (e) {
      debugPrint('💥 Sign-out error: $e');
      emit(state.copyWith(
        event: AuthEvents.loggedOutError,
        error: e.toString(),
      ));
    }
  }

  Future<void> _handleProfileSynced(UserModel user, Emitter<AuthState> emit) async {
    debugPrint('📡 Profile synced: ${user.uid}');

    // Cache-i yenilə
    await _cacheService.write<UserModel>('user', user);

    // State-i yenilə
    emit(state.copyWith(
      user: user,
      event: AuthEvents.profileSynced,
    ));
  }

  void _handleError(Object error, Emitter<AuthState> emit) {
    debugPrint('💥 AuthBloc error: $error');
    emit(state.copyWith(
      event: AuthEvents.googleSignInRequestedError,
      error: error.toString(),
    ));
  }

  @override
  Future<void> close() {
    _userStreamSubscription.cancel();
    return super.close();
  }
}
