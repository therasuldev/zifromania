import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/models/game_stats.dart';
import 'package:zifromania/models/subscription_model.dart';
import 'package:zifromania/models/user_model.dart';

class RankService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  /// Fetch top ranked users by level (Returns UserModel list)
  /// Note: This requires UserModel.fromMap() constructor to exist
  Future<List<UserModel>> fetchTopRankedUsers({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('level', descending: true)
          .orderBy('xp', descending: true) // Secondary sort by XP
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure uid is included in the data
        if (!data.containsKey('uid')) {
          data['uid'] = doc.id;
        }

        // Create UserModel with minimal required fields
        return UserModel(
          uid: doc.id,
          displayName: data['displayName'],
          email: data['email'],
          photoURL: data['photoURL'],
          coins: data['coins'] ?? 0,
          level: data['level'] ?? 1,
          xp: data['xp'] ?? 0,
          xpForNextLevel: data['xpForNextLevel'] ?? 1000,
          hasActiveSubscription: data['hasActiveSubscription'] ?? false,
          achievements: (data['achievements'] as List<dynamic>?)?.cast<String>() ?? const [],
          completedTasks: (data['completedTasks'] as List<dynamic>?)?.cast<String>() ?? const [],
          subscription: SubscriptionModel.fromMap(data['subscription'] ?? {}),
          playedDates: (data['playedDates'] as List<dynamic>?)?.cast<String>() ?? const [],
          currentStreak: data['currentStreak'] ?? 0,
          longestStreak: data['longestStreak'] ?? 0,
          gameStats: GameStats.fromMap(data['gameStats'] ?? {}),
        );
      }).toList();
    } catch (e) {
      print('Error fetching top ranked users: $e');
      throw Exception('Failed to fetch top ranked users: $e');
    }
  }

  /// Stream top ranked users as UserModel objects (if needed)
  Stream<List<UserModel>> streamTopRankedUsersAsUserModel({int limit = 50}) {
    return _firestore
        .collection(_usersCollection)
        .orderBy('level', descending: true)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final uid = doc.id;

        return UserModel(
          uid: uid,
          displayName: data['displayName'],
          email: data['email'],
          photoURL: data['photoURL'],
          coins: data['coins'] ?? 0,
          level: data['level'] ?? 1,
          xp: data['xp'] ?? 0,
          xpForNextLevel: data['xpForNextLevel'] ?? 1000,
          hasActiveSubscription: data['hasActiveSubscription'] ?? false,
          achievements: (data['achievements'] as List<dynamic>?)?.cast<String>() ?? const [],
          completedTasks: (data['completedTasks'] as List<dynamic>?)?.cast<String>() ?? const [],
          subscription: SubscriptionModel.fromMap(data['subscription'] ?? {}),
          playedDates: (data['playedDates'] as List<dynamic>?)?.cast<String>() ?? const [],
          currentStreak: data['currentStreak'] ?? 0,
          longestStreak: data['longestStreak'] ?? 0,
          gameStats: GameStats.fromMap(data['gameStats'] ?? {}),
        );
      }).toList();
    }).handleError((error) {
      print('Error in stream: $error');
      return <UserModel>[];
    });
  }

  /// Get the current user's rank position
  Future<int> getUserRankPosition(String userId) async {
    try {
      // First get the user's level and XP
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userLevel = userData['level'] ?? 0;
      final userXp = userData['xp'] ?? 0;

      // Count how many users have a higher level or same level but higher XP
      final higherLevelQuery = await _firestore.collection(_usersCollection).where('level', isGreaterThan: userLevel).count().get();

      final sameLevelHigherXpQuery =
          await _firestore.collection(_usersCollection).where('level', isEqualTo: userLevel).where('xp', isGreaterThan: userXp).count().get();

      // Rank is 1-based (position 1 is the highest rank)
      return (higherLevelQuery.count ?? 0) + (sameLevelHigherXpQuery.count ?? 0) + 1;
    } catch (e) {
      print('Error getting user rank position: $e');
      throw Exception('Failed to get user rank position: $e');
    }
  }

  /// Get users around the current user's rank (for context)
  // Future<List<UserModel>> getUsersAroundRank(String userId, {int range = 2}) async {
  //   try {
  //     final int userRank = await getUserRankPosition(userId);

  //     // Get users slightly above and below the current user's rank
  //     final startRank = userRank - range > 0 ? userRank - range : 1;
  //     final endRank = userRank + range;

  //     // Due to Firestore limitations, we'll fetch a bit more and filter
  //     final int fetchLimit = range * 2 + 3; // Extra buffer

  //     final querySnapshot = await _firestore
  //         .collection(_usersCollection)
  //         .orderBy('level', descending: true)
  //         .orderBy('xp', descending: true)
  //         .limit(endRank + 2) // Fetch up to the end rank + buffer
  //         .get();

  //     final allUsers = querySnapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

  //     // If we have fewer users than the start rank, return all
  //     if (allUsers.length < startRank) {
  //       return allUsers;
  //     }

  //     // Get the slice of users around the rank
  //     final startIndex = startRank - 1; // 0-based index
  //     final endIndex = endRank < allUsers.length ? endRank : allUsers.length;

  //     return allUsers.sublist(startIndex, endIndex);
  //   } catch (e) {
  //     print('Error getting users around rank: $e');
  //     throw Exception('Failed to get users around rank: $e');
  //   }
  // }
}
