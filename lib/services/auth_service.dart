import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Stream to listen to auth changes - useful for BLoC
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on PlatformException catch (e) {
      print('Google Sign-In Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during Google sign-in: $e');
      rethrow;
    }
  }
  
  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // For web, we need a different implementation
      if (kIsWeb) {
        // Create Apple provider for web
        final provider = OAuthProvider('apple.com');
        provider.addScope('email');
        provider.addScope('name');
        
        // Sign in with popup for web
        return await _auth.signInWithPopup(provider);
      } 
      else {
        // For iOS and macOS
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        
        // Create an OAuthCredential for Firebase
        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
        
        // Sign in to Firebase with the Apple credential
        return await _auth.signInWithCredential(oauthCredential);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // User canceled the sign-in flow
        return null;
      }
      print('Apple Sign-In Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during Apple sign-in: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  // Get user display name
  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }
  
  // Get user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }
  
  // Get user photo URL
  String? getUserPhotoUrl() {
    return _auth.currentUser?.photoURL;
  }
  
  // Get user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }
  
  // Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }
  
  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }
}