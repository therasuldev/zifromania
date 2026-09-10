import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/core/services/secure_storage_service.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

import 'package:zifromania/features/auth/data/datasource/auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _auth;
  final SecureStorageService _cacheService;

  AuthRemoteDatasourceImpl({required FirebaseAuth auth, required SecureStorageService cacheService})
      : _auth = auth,
        _cacheService = cacheService;

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        throw const GoogleSignInCancelledException();
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception("Firebase istifadəçisi tapılmadı.");
      }

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      Map<String, dynamic> profileMap;
      if (docSnapshot.exists && docSnapshot.data() != null) {
        profileMap = docSnapshot.data()!;
      } else {
        profileMap = {
          'uid': user.uid,
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
        };

        final fullUser = UserModel.fromFirebase(user: user, profileMap: profileMap);
        await docRef.set(fullUser.toMap());
        return fullUser;
      }

      return UserModel.fromFirebase(user: user, profileMap: profileMap);
    } catch (e, stackTrace) {
      print('Google Sign-In Error: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return null;
    }

    final profileMap = docSnapshot.data();
    return UserModel.fromFirebase(user: user, profileMap: profileMap);
  }

  @override
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return null;
      }

      final profileMap = docSnapshot.data();
      return UserModel.fromFirebase(user: user, profileMap: profileMap);
    });
  }

  @override
  Stream<UserModel?> userDocumentStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((docSnapshot) {
      if (!docSnapshot.exists) {
        return null;
      }

      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final profileMap = docSnapshot.data();
      return UserModel.fromFirebase(user: user, profileMap: profileMap);
    });
  }

  @override
  Future<bool> isSignedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }

  @override
  Future<UserModel?> get currentUserModel async {
    final user = _cacheService.read<UserModel>('user');
    return user;
  }

  @override
  User? get currentUser => _auth.currentUser;
}
