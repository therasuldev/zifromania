import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zifromania/services/cache_service.dart';

import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final SecureCacheService _cacheService;

  bool _googleSignInInitialized = false;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
    SecureCacheService? cacheService,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _cacheService = cacheService ?? SecureCacheService();

  /// v7-də GoogleSignIn istifadə edilmədən əvvəl mütləq initialize
  /// olunmalıdır. Bunu app başlanğıcında (məs. main() içində) bir dəfə
  /// çağırın, ya da hər signIn cəhdindən əvvəl bu metodu çağırın.
  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(
        // clientId: 'YOUR_IOS_CLIENT_ID', // lazım olarsa
        // serverClientId: 'YOUR_SERVER_CLIENT_ID', // Firebase üçün adətən lazımdır
        );
    _googleSignInInitialized = true;
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      // 1. Google istifadəçisi ilə imzalanma (signIn -> authenticate)
      final googleUser = await _googleSignIn.authenticate();

      // 2. Google Auth token-lərini əldə et (yalnız idToken var)
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw Exception("Google sign-in failed. idToken is null.");
      }

      // 3. accessToken lazımdırsa authorizationClient ilə al
      String? accessToken;
      try {
        final authorization = await googleUser.authorizationClient.authorizationForScopes(<String>['email', 'profile']);
        accessToken = authorization?.accessToken;
      } catch (_) {
        // accessToken alına bilmədi, Firebase üçün adətən vacib deyil
      }

      // 4. Firebase Auth üçün credential yarat
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      // 5. Firebase Auth ilə giriş et
      final userCredential = await _auth.signInWithCredential(credential);
      final firebase.User? user = userCredential.user;

      if (user == null) {
        throw Exception("Google sign-in failed. User is null.");
      }

      // 6. Firestore-dan mövcud profil məlumatını al
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      Map<String, dynamic> profileMap;

      if (docSnapshot.exists && docSnapshot.data() != null) {
        profileMap = docSnapshot.data()!;
      } else {
        profileMap = {
          'uid': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
        };

        final fullUser = UserModel.fromFirebase(user: user, profileMap: profileMap);
        await docRef.set(fullUser.toMap());
      }

      return UserModel.fromFirebase(user: user, profileMap: profileMap);
    } catch (e) {
      throw Exception("Google sign-in error: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final profileMap = doc.exists ? doc.data() : null;

    return UserModel.fromFirebase(user: user, profileMap: profileMap);
  }

  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final profileMap = doc.exists ? doc.data() : null;

      return UserModel.fromFirebase(user: user, profileMap: profileMap);
    });
  }

  Stream<UserModel?> userDocumentStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final user = _auth.currentUser;
      if (!doc.exists || user == null) return null;
      return UserModel.fromFirebase(user: user, profileMap: doc.data());
    });
  }

  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }

  Future<UserModel?> get currentUserModel async => _cacheService.read<UserModel>('user');
  User? get currentUser => _auth.currentUser;

  // User get user => _auth.currentUser!;
}
