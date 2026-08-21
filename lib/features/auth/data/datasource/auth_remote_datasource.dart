import 'package:firebase_auth/firebase_auth.dart';
import 'package:zifromania/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get userStream;

  Stream<UserModel?> userDocumentStream(String uid);

  Future<bool> isSignedIn();

  Future<UserModel?> get currentUserModel;

  User? get currentUser;
}
