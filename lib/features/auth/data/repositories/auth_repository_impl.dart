import 'package:firebase_auth/firebase_auth.dart';
import 'package:zifromania/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<UserModel> signInWithGoogle() {
    return _remoteDatasource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _remoteDatasource.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return _remoteDatasource.getCurrentUser();
  }

  @override
  Stream<UserModel?> get userStream {
    return _remoteDatasource.userStream;
  }

  @override
  Stream<UserModel?> userDocumentStream(String uid) {
    return _remoteDatasource.userDocumentStream(uid);
  }

  @override
  Future<bool> isSignedIn() {
    return _remoteDatasource.isSignedIn();
  }

  @override
  Future<UserModel?> get currentUserModel {
    return _remoteDatasource.currentUserModel;
  }

  @override
  User? get currentUser {
    return _remoteDatasource.currentUser;
  }
}
