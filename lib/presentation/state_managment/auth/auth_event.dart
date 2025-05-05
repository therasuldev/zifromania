// auth_event.dart
import 'package:zifromania/models/user_model.dart';

enum AuthEvents {
  authenticated,
  unauthenticated,

  googleSignInRequested,
  googleSignInRequestedSuccess,
  googleSignInRequestedError,

  // appleSignInRequested,

  loggedOutStart,
  loggedOutSuccess,
  loggedOutError,

  // for loading profile from user service
  loadProfileStart,
  loadProfileSuccess,
  loadProfileError,
}

class AuthEvent {
  AuthEvents? type;
  dynamic payload;

  AuthEvent.authenticated(UserModel userModel) {
    type = AuthEvents.authenticated;
    payload = userModel;
  }

  AuthEvent.unauthenticated() {
    type = AuthEvents.unauthenticated;
    payload = null;
  }

  AuthEvent.googleSignInRequested() {
    type = AuthEvents.googleSignInRequested;
    payload = null;
  }

  AuthEvent.loggedOutStart() {
    type = AuthEvents.loggedOutStart;
    payload = null;
  }

  AuthEvent.loadProfileStart(String uid) {
    type = AuthEvents.loadProfileStart;
    payload = uid;
  }
}
