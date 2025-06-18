import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> spendCoins(String uid, int amountToSpend) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(uid).get();
      final currentCoins = userDoc.data()?['coins'] ?? 0;

      if (currentCoins < amountToSpend) {
        throw Exception('Not enough coins');
      }

      await _firestore.collection(_usersCollection).doc(uid).update({
        'coins': currentCoins - amountToSpend,
      });

      
    } catch (e) {
      print('Error spending coins: $e');
      throw Exception('Failed to spend coins: $e');
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
      final today = DateTime.now().toIso8601String().split('T')[0]; // yyyy-MM-dd
      final docRef = _firestore.collection(_usersCollection).doc(uid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final playedDates = List<String>.from(data['playedDates'] ?? []);

      // Artıq bu gün oynayıbsa, heç nə etmirik
      if (playedDates.contains(today)) return;

      // Add today to played dates
      playedDates.add(today);

      // Calculate new streak
      final newStreak = _calculateStreak(playedDates);
      final currentLongestStreak = data['longestStreak'] ?? 0;
      final longestStreak = newStreak > currentLongestStreak ? newStreak : currentLongestStreak;

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

      final userData = userDoc.data()!;
      final gameStatsData = userData['gameStats'] as Map<String, dynamic>? ?? {};

      // Get current category stats
      final categoryStatsData = gameStatsData['categoryStats'] as Map<String, dynamic>? ?? {};
      final currentCategoryStats = categoryStatsData[category] as Map<String, dynamic>? ?? {};

      // Current category values
      final currentGamesPlayed = currentCategoryStats['gamesPlayed'] ?? 0;
      final currentQuestionsAnswered = currentCategoryStats['questionsAnswered'] ?? 0;
      final currentCorrectAnswers = currentCategoryStats['correctAnswers'] ?? 0;
      final currentBestScore = currentCategoryStats['bestScore'] ?? 0;
      final currentTotalTimeSpent = currentCategoryStats['totalTimeSpent'] ?? 0;

      // Calculate average time per question for this game
      final avgTimeThisGame = questionsAnswered > 0 ? gameTimeInSeconds / questionsAnswered : 0.0;

      // Update category statistics
      final newGamesPlayed = currentGamesPlayed + 1;
      final newQuestionsAnswered = currentQuestionsAnswered + questionsAnswered;
      final newCorrectAnswers = currentCorrectAnswers + correctAnswers;
      final newBestScore = score > currentBestScore ? score : currentBestScore;
      final newTotalTimeSpent = currentTotalTimeSpent + gameTimeInSeconds;
      final newAverageTimePerQuestion = newQuestionsAnswered > 0 ? newTotalTimeSpent / newQuestionsAnswered : 0.0;

      final updatedCategoryStats = {
        'gamesPlayed': newGamesPlayed,
        'questionsAnswered': newQuestionsAnswered,
        'correctAnswers': newCorrectAnswers,
        'bestScore': newBestScore,
        'totalTimeSpent': newTotalTimeSpent,
        'averageTimePerQuestion': newAverageTimePerQuestion,
      };

      // Get current overall stats
      final currentTotalGamesPlayed = gameStatsData['totalGamesPlayed'] ?? 0;
      final currentTotalQuestionsAnswered = gameStatsData['totalQuestionsAnswered'] ?? 0;
      final currentTotalCorrectAnswers = gameStatsData['totalCorrectAnswers'] ?? 0;
      final currentOverallAvgTime = gameStatsData['averageTimePerQuestion'] ?? 0.0;
      final categoriesPlayedData = gameStatsData['categoriesPlayed'] as Map<String, dynamic>? ?? {};

      // Update overall statistics
      final newTotalQuestions = currentTotalQuestionsAnswered + questionsAnswered;
      final totalTime = (currentOverallAvgTime * currentTotalQuestionsAnswered) + (avgTimeThisGame * questionsAnswered);
      final newOverallAverage = newTotalQuestions > 0 ? totalTime / newTotalQuestions : 0.0;

      // Update categories played count
      final newCategoriesPlayed = Map<String, dynamic>.from(categoriesPlayedData);
      newCategoriesPlayed[category] = (newCategoriesPlayed[category] ?? 0) + 1;

      // Update category stats map
      final newCategoryStatsMap = Map<String, dynamic>.from(categoryStatsData);
      newCategoryStatsMap[category] = updatedCategoryStats;

      final updatedGameStats = {
        'categoriesPlayed': newCategoriesPlayed,
        'categoryStats': newCategoryStatsMap,
        'totalGamesPlayed': currentTotalGamesPlayed + 1,
        'totalQuestionsAnswered': newTotalQuestions,
        'totalCorrectAnswers': currentTotalCorrectAnswers + correctAnswers,
        'averageTimePerQuestion': newOverallAverage,
      };

      // Update in Firestore
      await _firestore.collection(_usersCollection).doc(uid).update({
        'gameStats': updatedGameStats,
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

      final userData = userDoc.data()!;
      return userData['currentStreak'] ?? 0;
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

      final userData = userDoc.data()!;
      return userData['gameStats']['categoriesPlayed']?.keys.toSet() ?? <String>{};
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

      final userData = userDoc.data()!;
      final gameStatsData = userData['gameStats'] as Map<String, dynamic>? ?? {};
      final categoryStatsData = gameStatsData['categoryStats'] as Map<String, dynamic>? ?? {};
      final specificCategoryStats = categoryStatsData[category] as Map<String, dynamic>? ?? {};

      return (specificCategoryStats['averageTimePerQuestion'] ?? 0.0).toDouble();
    } catch (e) {
      print('Error getting category average time: $e');
      return 0.0;
    }
  }
}

extension XpExtension on UserService {
  /// Adds XP to user and handles leveling up until XP is under threshold.
  ///
  /// XP reset to 0 after each level up.
  /// Updates Firestore fields:
  /// - 'xp'
  /// - 'level'
  /// - 'xpForNextLevel'
  Future<void> addXpAndHandleLevelUp(String uid, int xpEarned) async {
    final docRef = _firestore.collection(_usersCollection).doc(uid);
    final snap = await docRef.get();
    if (!snap.exists) throw Exception('User not found');

    // Read existing data or use defaults
    int level = (snap['level'] ?? 1) as int;
    int xp = (snap['xp'] ?? 0) as int;
    int xpForNextLevel = (snap['xpForNextLevel'] ?? XpService.xpForNextLevel(level)) as int;

    // Add earned XP
    xp += xpEarned;

    // Level up loop
    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel;
      level += 1;
      xpForNextLevel = XpService.xpForNextLevel(level);
    }

    // Persist updated values
    await docRef.update({
      'level': level,
      'xp': xp,
      'xpForNextLevel': xpForNextLevel,
    });
  }
}
