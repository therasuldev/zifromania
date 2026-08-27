import 'package:firebase_auth/firebase_auth.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

abstract interface class AuthRepository {
  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get userStream;

  Stream<UserModel?> userDocumentStream(String uid);

  Future<bool> isSignedIn();

  Future<UserModel?> get currentUserModel;

  User? get currentUser;
}
