import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/services/auth_service.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/user_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserService _userService;
  final SecureCacheService _cacheService;
  late final StreamSubscription<firebase.User?> _authStateSubscription;

  AuthBloc({
    required AuthService authService,
    required UserService userService,
    required SecureCacheService cacheService,
  })  : _authService = authService,
        _userService = userService,
        _cacheService = cacheService,
        super(AuthState.initial()) {
    // Register event handler with debug print
    on<AuthEvent>((event, emit) async {
      print("Event received in on<AuthEvent>: ${event.type}, payload: ${event.payload}");
      await _onAuthEvent(event, emit);
    });

    // Load cached user on startup
    _checkCachedUser();

    // Subscribe to Firebase auth state changes
    _authStateSubscription = _authService.authStateChanges.listen(_onFirebaseAuthChanged);
  }

  // Handle cached user data on app startup
  Future<void> _checkCachedUser() async {
    try {
      final UserModel? cachedUser = await _cacheService.read<UserModel>('user');

      if (cachedUser != null && cachedUser.uid.isNotEmpty) {
        // Only emit if we have a valid user with a UID
        emit(state.copyWith(
          user: cachedUser,
          event: AuthEvents.authenticated,
          error: null,
        ));

        // Optional: Refresh the user data from Firestore in the background
        _refreshUserData(cachedUser.uid);
      }
    } catch (e) {
      // Silent failure for cache issues - will rely on Firebase Auth state
      print('Cache read error: $e');
      // Try to clean up corrupted cache
      await _cacheService.delete('user');
    }
  }

  // Refresh user data from Firestore
  Future<void> _refreshUserData(String uid) async {
    try {
      final UserModel refreshedUser = await _userService.fetchFullUser(uid);
      await _cacheService.write<UserModel>('user', refreshedUser);

      emit(state.copyWith(
        user: refreshedUser,
        event: AuthEvents.loadProfileSuccess,
      ));
    } catch (e) {
      // Don't change auth state, but record the error
      emit(state.copyWith(
        event: AuthEvents.loadProfileError,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthEvent(AuthEvent event, Emitter<AuthState> emit) async {
    try {
      print("Processing event: ${event.type}, payload: ${event.payload}");

      switch (event.type) {
        case AuthEvents.authenticated:
          print("Handling authenticated event with payload: ${event.payload}");
          if (event.payload is UserModel) {
            final userModel = event.payload as UserModel;
            print("Valid UserModel payload: ${userModel.uid}");
            await _handleAuthenticated(userModel, emit);
          } else {
            print("Invalid payload type for authenticated event: ${event.payload?.runtimeType}");
            _handleError('Invalid payload for authenticated event: ${event.payload}', emit);
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

        case AuthEvents.loadProfileStart:
          if (event.payload is String) {
            final uid = event.payload as String;
            await _refreshUserData(uid);
          } else {
            _handleError('Invalid payload for loadProfileStart event', emit);
          }
          break;

        default:
          print("Unhandled event type: ${event.type}");
          break;
      }
    } catch (e) {
      print("Error in _onAuthEvent: $e");
      _handleError(e, emit);
    }
  }

  void _onFirebaseAuthChanged(firebase.User? fbUser) {
    if (fbUser != null) {
      try {
        // Create basic UserModel from Firebase Auth data
        final UserModel basicUser = UserModel.fromFirebaseUser(fbUser);
        // Here we should pass the user model
        print("Firebase auth changed - creating auth event with user: ${basicUser.uid}");
        final authEvent = AuthEvent.authenticated(basicUser);
        print("Created auth event with payload: ${authEvent.payload}");
        add(authEvent);
      } catch (e) {
        print('Error creating user model from Firebase user: $e');
        // Handle error but don't change auth state
      }
    } else {
      add(AuthEvent.unauthenticated());
    }
  }

  Future<void> _handleAuthenticated(UserModel basicUser, Emitter<AuthState> emit) async {
    if (basicUser.uid.isEmpty) {
      emit(state.copyWith(
        event: AuthEvents.loadProfileError,
        error: 'Invalid user data received',
      ));
      return;
    }

    try {
      // Emit interim state with basic user info
      emit(state.copyWith(
        user: basicUser,
        event: AuthEvents.authenticated,
      ));

      // Create/update user profile in Firestore
      await _userService.createUserProfile(basicUser);

      // Fetch complete user data from Firestore
      final UserModel fullUser = await _userService.fetchFullUser(basicUser.uid);

      // Cache the full user data
      await _cacheService.write<UserModel>('user', fullUser);

      // Emit final state with complete user data
      emit(state.copyWith(
        user: fullUser,
        event: AuthEvents.authenticated,
        error: null,
      ));
    } catch (e) {
      print('Error in _handleAuthenticated: $e');
      // If Firestore operations fail, keep basic user data from auth
      emit(state.copyWith(
        user: basicUser,
        event: AuthEvents.loadProfileError,
        error: 'Failed to load complete profile: ${e.toString()}',
      ));
    }
  }

  Future<void> _handleUnauthenticated(Emitter<AuthState> emit) async {
    // Clear cached user data
    await _cacheService.delete('user');

    emit(state.copyWith(
      event: AuthEvents.unauthenticated,
      user: null,
      error: null,
    ));
  }

  Future<void> _handleGoogleSignInRequested(Emitter<AuthState> emit) async {
    emit(state.copyWith(
      event: AuthEvents.googleSignInRequested,
      error: null,
    ));

    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        emit(state.copyWith(
          event: AuthEvents.googleSignInRequestedError,
          error: 'Google sign in was cancelled',
        ));
      } else {
        // Success state update will come through the Firebase auth listener
        emit(state.copyWith(
          event: AuthEvents.googleSignInRequestedSuccess,
          error: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        event: AuthEvents.googleSignInRequestedError,
        error: 'Google sign in failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _handleLoggedOutStart(Emitter<AuthState> emit) async {
    emit(state.copyWith(
      event: AuthEvents.loggedOutStart,
      error: null,
    ));

    try {
      await _cacheService.delete('user');
      await _authService.signOut();

      // Auth state listener will handle the unauthenticated state
    } catch (e) {
      emit(state.copyWith(
        event: AuthEvents.loggedOutError,
        error: 'Error during sign out: ${e.toString()}',
      ));
    }
  }

  void _handleError(Object error, Emitter<AuthState> emit) {
    final String errorMessage = error is String ? error : error.toString();
    print('Auth error: $errorMessage');

    // Use a more specific event type if we can determine it from context
    final AuthEvents errorEvent = state.event == AuthEvents.googleSignInRequested
        ? AuthEvents.googleSignInRequestedError
        : state.event == AuthEvents.loadProfileStart
            ? AuthEvents.loadProfileError
            : state.event == AuthEvents.loggedOutStart
                ? AuthEvents.loggedOutError
                : AuthEvents.googleSignInRequestedError; // Default

    emit(state.copyWith(
      event: errorEvent,
      error: errorMessage,
    ));
  }

  @override
  void add(AuthEvent event) {
    print("Adding event to BLoC: ${event.type}, payload: ${event.payload}");
    super.add(event);
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
