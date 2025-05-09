import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/models/user_model.dart';

import 'xp_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Create a new user profile in Firestore if it doesn't exist
  // or update it with any new info from authentication
  Future<void> createUserProfile(UserModel user) async {
    try {
      // First check if the user already exists
      final docRef = _firestore.collection(_usersCollection).doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // If user exists, update only basic auth fields without overwriting
        // coins and subscription status and achievements
        final existingData = docSnapshot.data() as Map<String, dynamic>;

        await docRef.update({
          'displayName': user.displayName ?? existingData['displayName'],
          'email': user.email ?? existingData['email'],
          'photoURL': user.photoURL ?? existingData['photoURL'],
          // Don't update coins or subscription and achievements status here
        });
      } else {
        // If user doesn't exist, create new document with default values
        await docRef.set(user.toMap());
      }
    } catch (e) {
      print('Error creating/updating user profile: $e');
      throw Exception('Failed to create or update user profile: $e');
    }
  }

  // Fetch user data with full profile from Firestore
  Future<UserModel> fetchFullUser(String uid) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;

        return UserModel(
          uid: uid,
          displayName: userData['displayName'],
          email: userData['email'],
          photoURL: userData['photoURL'],
          coins: userData['coins'] ?? 0,
          level: userData['level'] ?? 0,
          xp: userData['xp'] ?? 0,
          xpForNextLevel: userData['xpForNextLevel'] ?? 1000,
          hasActiveSubscription: userData['hasActiveSubscription'] ?? false,
          achievements: (userData['achievements'] as List<dynamic>?)?.cast<String>() ?? <String>[],
          subscription: SubscriptionModel.fromMap(userData['subscription']),
        );
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Update user coins
  Future<void> updateCoins(String uid, int coins) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'coins': coins,
      });
    } catch (e) {
      print('Error updating coins: $e');
      throw Exception('Failed to update coins: $e');
    }
  }

  // Add coins to user's current balance
  Future<UserModel> addCoins(String uid, int amount) async {
    try {
      // Get current user data
      final UserModel currentUser = await fetchFullUser(uid);
      final int newTotal = currentUser.coins + amount;

      // Update in Firestore
      await _firestore.collection(_usersCollection).doc(uid).update({
        'coins': newTotal,
      });

      // Return updated user model
      return currentUser.copyWith(coins: newTotal);
    } catch (e) {
      print('Error adding coins: $e');
      throw Exception('Failed to add coins: $e');
    }
  }

  // Update subscription status
  Future<void> updateSubscriptionStatus(String uid, bool hasActiveSubscription) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'hasActiveSubscription': hasActiveSubscription,
      });
    } catch (e) {
      print('Error updating subscription status: $e');
      throw Exception('Failed to update subscription status: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Stream user data for real-time updates
  Stream<UserModel> streamUserData(String uid) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return UserModel(
          uid: uid,
          displayName: data['displayName'],
          email: data['email'],
          photoURL: data['photoURL'],
          coins: data['coins'] ?? 0,
          level: data['level'] ?? 0,
          xp: data['xp'] ?? 0,
          xpForNextLevel: data['xpForNextLevel'] ?? 1000,
          hasActiveSubscription: data['hasActiveSubscription'] ?? false,
          achievements: (data['achievements'] as List<dynamic>?)?.cast<String>() ?? <String>[],
          subscription: SubscriptionModel.fromMap(data['subscription']),
        );
      } else {
        throw Exception('User document does not exist');
      }
    });
  }
}

extension XpExtension on UserService {
  /// Add [xpEarned] to the user, perform level‑up checks **looping** until the
  /// stored XP is strictly below the requirement for the next level.
  ///
  /// Firestore fields touched:
  ///   * xp               – remaining XP **inside** current level
  ///   * level            – absolute level (starting at 1)
  ///   * xpForNextLevel   – target XP for the *next* level‑up
  Future<void> addXpAndHandleLevelUp(String uid, int xpEarned) async {
    // 1️⃣  Get current snapshot
    final docRef = _firestore.collection(_usersCollection).doc(uid);
    final snap   = await docRef.get();
    if (!snap.exists) throw Exception('User not found');

    int level            = (snap['level']          ?? 1)  as int;
    int xp               = (snap['xp']             ?? 0)  as int;
    int xpForNextLevel   = (snap['xpForNextLevel'] ?? XpService.xpForNextLevel(level)) as int;

    // 2️⃣  Add freshly earned XP
    xp += xpEarned;

    // 3️⃣  While we have enough XP –> level‑up 🔁
    while (xp >= xpForNextLevel) {
      xp            -= xpForNextLevel;   // Remove spent XP
      level         += 1;                // Increment level
      xpForNextLevel = XpService.xpForNextLevel(level);
    }

    // 4️⃣  Persist back
    await docRef.update({
      'level'          : level,
      'xp'             : xp,
      'xpForNextLevel' : xpForNextLevel,
    });
  }
}
