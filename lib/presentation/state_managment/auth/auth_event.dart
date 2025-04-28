// auth_event.dart
enum AuthEvents {
  authenticated,
  unauthenticated,

  googleSignInRequested,
  googleSignInSuccess,
  googleSignInFailure,

  appleSignInRequested,
  appleSignInSuccess,
  appleSignInFailure,

  loggedOut,

  authError,
}

class AuthEvent {
  AuthEvents? type;
  dynamic payload;

  AuthEvent.authenticated() : type = AuthEvents.authenticated;

  AuthEvent.unauthenticated() : type = AuthEvents.unauthenticated;

  AuthEvent.googleSignInRequested() : type = AuthEvents.googleSignInRequested;

  AuthEvent.appleSignInRequested() : type = AuthEvents.appleSignInRequested;

  AuthEvent.loggedOut() : type = AuthEvents.loggedOut;

  AuthEvent.authError() : type = AuthEvents.authError;
}


// import 'package:equatable/equatable.dart';

// abstract class AuthEvent extends Equatable {
//   const AuthEvent();

//   @override
//   List<Object?> get props => [];
// }

// class AppStarted extends AuthEvent {}

// class LoggedIn extends AuthEvent {}

// class GoogleSignInRequested extends AuthEvent {}

// class AppleSignInRequested extends AuthEvent {}

// class LoggedOut extends AuthEvent {}