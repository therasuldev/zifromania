import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/user/data/helpers/game_statistics_calculator.dart';
import 'package:zifromania/features/user/data/models/game_update_data.dart';
import 'package:zifromania/features/user/domain/entities/subscription_entity.dart';
import 'package:zifromania/core/services/xp_service.dart';

import '../models/subscription_model.dart';
import '../models/user_model.dart';
import 'user_remote_datasource.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final GameStatisticsCalculator calculator;

  const UserRemoteDataSourceImpl({required this.firestore, required this.calculator});

  static const String usersCollection = 'users';

  CollectionReference<Map<String, dynamic>> get _users => firestore.collection(usersCollection);

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _users.doc(uid);
  }

  @override
  Future<void> createUserProfile({required UserModel user}) async {
    final docRef = _userDoc(user.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;

      await docRef.update({
        'displayName': user.displayName ?? data['displayName'],
        'email': user.email ?? data['email'],
        'photoURL': user.photoUrl ?? data['photoURL'],
      });

      return;
    }

    await docRef.set(user.toMap());
  }

  @override
  Future<UserModel> getUser({required String uid}) async {
    final snapshot = await _userDoc(uid).get();

    if (!snapshot.exists) {
      throw const ServerException('User not found');
    }

    final data = snapshot.data();

    if (data == null) {
      throw const ServerException('User data is null');
    }

    return UserModel.fromMap({...data, 'uid': uid});
  }

  @override
  Stream<UserModel> watchUser({required String uid}) {
    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw const ServerException('User not found');
      }

      final data = snapshot.data();

      if (data == null) {
        throw const ServerException('User data is null');
      }

      return UserModel.fromMap({...data, 'uid': uid});
    });
  }

  @override
  Future<void> deleteUser({required String uid}) async {
    await _userDoc(uid).delete();
  }

  @override
  Future<UserModel> addCoins({
    required String uid,
    required int amount,
  }) async {
    await _userDoc(uid).update({
      'coins': FieldValue.increment(amount),
    });

    return getUser(uid: uid);
  }

  @override
  Future<UserModel> spendCoins({required String uid, required int amount}) async {
    final user = await getUser(uid: uid);

    if (user.coins < amount) {
      throw const ServerException('Not enough coins');
    }

    await _userDoc(uid).update({
      'coins': FieldValue.increment(-amount),
    });

    return getUser(uid: uid);
  }

  @override
  Future<UserModel> addXp({required String uid, required int xpEarned}) async {
    await _applyXp(uid: uid, xpEarned: xpEarned);

    return getUser(uid: uid);
  }

  Future<void> _applyXp({
    required String uid,
    required int xpEarned,
  }) async {
    final docRef = _userDoc(uid);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw const ServerException('User not found');
    }

    final data = snapshot.data()!;

    int level = data['level'] ?? 1;
    int xp = data['xp'] ?? 0;

    int xpForNextLevel = data['xpForNextLevel'] ?? XpService.xpForNextLevel(level);

    xp += xpEarned;

    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel;
      level++;

      xpForNextLevel = XpService.xpForNextLevel(level);
    }

    await docRef.update({
      'level': level,
      'xp': xp,
      'xpForNextLevel': xpForNextLevel,
    });
  }

  @override
  Future<void> updateSubscriptionDetails({
    required String uid,
    required SubscriptionModel subscription,
  }) async {
    await _userDoc(uid).update({
      'subscription': subscription.toMap(),
      'hasActiveSubscription': true,
    });
  }

  @override
  Future<void> updateSubscriptionStatus({
    required String uid,
    required bool isActive,
  }) async {
    await _userDoc(uid).update({'hasActiveSubscription': isActive});
  }

  @override
  Future<void> expireSubscription({required String uid}) async {
    await _userDoc(uid).update({
      'hasActiveSubscription': false,
      'subscription': const SubscriptionModel(type: SubscriptionTypeEntity.free).toMap(),
    });
  }

  @override
  Future<void> completeTask({
    required String uid,
    required String taskId,
    required int xpReward,
    required int coinsReward,
  }) async {
    await _userDoc(uid).update({
      'completedTasks': FieldValue.arrayUnion([
        taskId,
      ]),
    });

    if (xpReward > 0) {
      await _applyXp(
        uid: uid,
        xpEarned: xpReward,
      );
    }

    if (coinsReward > 0) {
      await addCoins(
        uid: uid,
        amount: coinsReward,
      );
    }
  }

  @override
  Future<void> addAchievement({
    required String uid,
    required String achievementId,
  }) async {
    await _userDoc(uid).update({
      'achievements': FieldValue.arrayUnion([achievementId]),
    });
  }

  @override
  Future<void> updateDailyStreak({required String uid}) async {
    final today = _todayString();

    final snapshot = await _userDoc(uid).get();

    if (!snapshot.exists) {
      return;
    }

    final data = snapshot.data()!;

    final playedDates = List<String>.from(
      data['playedDates'] ?? [],
    );

    if (playedDates.contains(today)) {
      return;
    }

    playedDates.add(today);

    final currentStreak = _calculateStreak(
      playedDates,
    );

    final longestStreak = currentStreak > (data['longestStreak'] ?? 0) ? currentStreak : data['longestStreak'] ?? 0;

    await _userDoc(uid).update({
      'playedDates': playedDates,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    });
  }

  String _todayString() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  int _calculateStreak(List<String> playedDates) {
    if (playedDates.isEmpty) {
      return 0;
    }

    final dates = playedDates.map(DateTime.parse).toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();

    final normalizedToday = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final yesterday = normalizedToday.subtract(const Duration(days: 1));
    var streak = 0;

    for (var i = 0; i < dates.length; i++) {
      final played = DateTime(
        dates[i].year,
        dates[i].month,
        dates[i].day,
      );

      final expected = normalizedToday.subtract(Duration(days: i));

      if (played == expected || (i == 0 && played == yesterday)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Future<int> getCurrentStreak({required String uid}) async {
    final snapshot = await _userDoc(uid).get();

    if (!snapshot.exists) {
      return 0;
    }

    return snapshot.data()?['currentStreak'] ?? 0;
  }

  @override
  Future<void> updateGameStatistics({
    required String uid,
    required GameUpdateData data,
  }) async {
    final user = await getUser(uid: uid);

    final updatedStats = calculator.update(
      current: user.gameStats,
      data: data,
    );

    await _userDoc(uid).update({
      'gameStats': updatedStats.toMap(),
    });
  }

  @override
  Future<Set<String>> getDistinctCategoriesPlayed({required String uid}) async {
    final snapshot = await _userDoc(uid).get();

    if (!snapshot.exists) {
      return {};
    }

    final data = snapshot.data();
    final gameStats = data?['gameStats'] as Map<String, dynamic>?;
    final categoriesPlayed = gameStats?['categoriesPlayed'] as Map<String, dynamic>?;

    return categoriesPlayed?.keys.toSet() ?? {};
  }

  @override
  Future<double> getCategoryAverageTime({
    required String uid,
    required String category,
  }) async {
    final snapshot = await _userDoc(uid).get();

    if (!snapshot.exists) {
      return 0.0;
    }

    final data = snapshot.data();

    final gameStats = data?['gameStats'] as Map<String, dynamic>?;
    final categoryStats = gameStats?['categoryStats'] as Map<String, dynamic>?;
    final currentCategory = categoryStats?[category] as Map<String, dynamic>?;

    return (currentCategory?['averageTimePerQuestion'] ?? 0.0).toDouble();
  }
}
