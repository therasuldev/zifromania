import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/models/category_stats.dart';
import 'package:zifromania/models/subscription_model.dart';
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
          completedTasks: (userData['completedTasks'] as List<dynamic>?)?.cast<String>() ?? <String>[],
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
          completedTasks: (data['completedTasks'] as List<dynamic>?)?.cast<String>() ?? <String>[],
          subscription: SubscriptionModel.fromMap(data['subscription']),
        );
      } else {
        throw Exception('User document does not exist');
      }
    });
  }

  // Add a completed task to user
  Future<void> completeTask(String uid, String taskId, int xpReward, int coinsReward) async {
    try {
      // Get current user data
      final UserModel currentUser = await fetchFullUser(uid);

      // Check if task is already completed
      if (currentUser.completedTasks.contains(taskId)) {
        return; // Task already completed, no action needed
      }

      // Add taskId to completed tasks
      final List<String> updatedTasks = List.from(currentUser.completedTasks)..add(taskId);

      // Update in Firestore
      await _firestore.collection(_usersCollection).doc(uid).update({
        'completedTasks': updatedTasks,
      });

      // Add rewards
      if (xpReward > 0) {
        await addXpAndHandleLevelUp(uid, xpReward);
      }

      if (coinsReward > 0) {
        await addCoins(uid, coinsReward);
      }
    } catch (e) {
      print('Error completing task: $e');
      throw Exception('Failed to complete task: $e');
    }
  }

  // Add achievement/title to user
  Future<void> addAchievement(String uid, String titleId) async {
    try {
      // Get current user data
      final UserModel currentUser = await fetchFullUser(uid);

      // Check if achievement is already added
      if (currentUser.achievements.contains(titleId)) {
        return; // Achievement already added, no action needed
      }

      // Add titleId to achievements
      final List<String> updatedAchievements = List.from(currentUser.achievements)..add(titleId);

      // Update in Firestore
      await _firestore.collection(_usersCollection).doc(uid).update({
        'achievements': updatedAchievements,
      });
    } catch (e) {
      print('Error adding achievement: $e');
      throw Exception('Failed to add achievement: $e');
    }
  }

  /// Update daily streak when user plays a game
  Future<void> updateDailyStreak(String uid) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0]; // yyyy-MM-dd format
      final userDoc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!userDoc.exists) return;

      final user = UserModel.fromMap(userDoc.data()!);
      final playedDates = List<String>.from(user.playedDates);

      // If already played today, no need to update
      if (playedDates.contains(today)) return;

      // Add today to played dates
      playedDates.add(today);

      // Calculate new streak
      final newStreak = _calculateStreak(playedDates);
      final longestStreak = newStreak > user.longestStreak ? newStreak : user.longestStreak;

      // Update user data
      await _firestore.collection(_usersCollection).doc(uid).update({
        'playedDates': playedDates,
        'currentStreak': newStreak,
        'longestStreak': longestStreak,
      });
    } catch (e) {
      print('Error updating daily streak: $e');
      throw Exception('Failed to update daily streak: $e');
    }
  }

  /// Calculate current streak from played dates
  int _calculateStreak(List<String> playedDates) {
    if (playedDates.isEmpty) return 0;

    // Sort dates in descending order
    final sortedDates = playedDates.map((date) => DateTime.parse(date)).toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Check if played today or yesterday (to account for timezone differences)
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Start from most recent date
    for (int i = 0; i < sortedDates.length; i++) {
      final playDate = DateTime(sortedDates[i].year, sortedDates[i].month, sortedDates[i].day);
      final expectedDate = today.subtract(Duration(days: i));

      // If this date matches the expected consecutive date
      if (playDate == expectedDate || (i == 0 && playDate == yesterday)) {
        streak++;
      } else {
        break; // Streak is broken
      }
    }

    return streak;
  }

  /// Update game statistics after a game ends
  Future<void> updateGameStatistics({
    required String uid,
    required String category,
    required int score,
    required int questionsAnswered,
    required int correctAnswers,
    required int gameTimeInSeconds,
  }) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!userDoc.exists) return;

      final user = UserModel.fromMap(userDoc.data()!);
      final currentStats = user.gameStats;
      final currentCategoryStats = currentStats.categoryStats[category] ?? const CategoryStats();

      // Calculate average time per question for this game
      final avgTimeThisGame = questionsAnswered > 0 ? gameTimeInSeconds / questionsAnswered : 0.0;

      // Update category statistics
      final updatedCategoryStats = currentCategoryStats.copyWith(
        gamesPlayed: currentCategoryStats.gamesPlayed + 1,
        questionsAnswered: currentCategoryStats.questionsAnswered + questionsAnswered,
        correctAnswers: currentCategoryStats.correctAnswers + correctAnswers,
        bestScore: score > currentCategoryStats.bestScore ? score : currentCategoryStats.bestScore,
        totalTimeSpent: currentCategoryStats.totalTimeSpent + gameTimeInSeconds,
        averageTimePerQuestion: currentCategoryStats.questionsAnswered + questionsAnswered > 0
            ? (currentCategoryStats.totalTimeSpent + gameTimeInSeconds) / (currentCategoryStats.questionsAnswered + questionsAnswered)
            : 0.0,
      );

      // Update overall statistics
      final totalQuestions = currentStats.totalQuestionsAnswered + questionsAnswered;
      final totalTime = (currentStats.averageTimePerQuestion * currentStats.totalQuestionsAnswered) + (avgTimeThisGame * questionsAnswered);
      final newOverallAverage = totalQuestions > 0 ? totalTime / totalQuestions : 0.0;

      final updatedStats = currentStats.copyWith(
        categoriesPlayed: {
          ...currentStats.categoriesPlayed,
          category: (currentStats.categoriesPlayed[category] ?? 0) + 1,
        },
        categoryStats: {
          ...currentStats.categoryStats,
          category: updatedCategoryStats,
        },
        totalGamesPlayed: currentStats.totalGamesPlayed + 1,
        totalQuestionsAnswered: totalQuestions,
        totalCorrectAnswers: currentStats.totalCorrectAnswers + correctAnswers,
        averageTimePerQuestion: newOverallAverage,
      );

      // Update in Firestore
      await _firestore.collection(_usersCollection).doc(uid).update({
        'gameStats': updatedStats.toMap(),
      });
    } catch (e) {
      print('Error updating game statistics: $e');
      throw Exception('Failed to update game statistics: $e');
    }
  }

  /// Get user's current streak
  Future<int> getCurrentStreak(String uid) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!userDoc.exists) return 0;

      final user = UserModel.fromMap(userDoc.data()!);
      return user.currentStreak;
    } catch (e) {
      print('Error getting current streak: $e');
      return 0;
    }
  }

  /// Get distinct categories played by user
  Future<Set<String>> getDistinctCategoriesPlayed(String uid) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!userDoc.exists) return <String>{};

      final user = UserModel.fromMap(userDoc.data()!);
      return user.gameStats.categoriesPlayed.keys.toSet();
    } catch (e) {
      print('Error getting distinct categories: $e');
      return <String>{};
    }
  }

  /// Get average time per question for a specific category
  Future<double> getCategoryAverageTime(String uid, String category) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!userDoc.exists) return 0.0;

      final user = UserModel.fromMap(userDoc.data()!);
      final categoryStats = user.gameStats.categoryStats[category];

      return categoryStats?.averageTimePerQuestion ?? 0.0;
    } catch (e) {
      print('Error getting category average time: $e');
      return 0.0;
    }
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
    final snap = await docRef.get();
    if (!snap.exists) throw Exception('User not found');

    int level = (snap['level'] ?? 1) as int;
    int xp = (snap['xp'] ?? 0) as int;
    int xpForNextLevel = (snap['xpForNextLevel'] ?? XpService.xpForNextLevel(level)) as int;

    // 2️⃣  Add freshly earned XP
    xp += xpEarned;

    // 3️⃣  While we have enough XP –> level‑up 🔁
    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel; // Remove spent XP
      level += 1; // Increment level
      xpForNextLevel = XpService.xpForNextLevel(level);
    }

    // 4️⃣  Persist back
    await docRef.update({
      'level': level,
      'xp': xp,
      'xpForNextLevel': xpForNextLevel,
    });
  }
}
