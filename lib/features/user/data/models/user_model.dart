import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:zifromania/features/user/domain/entities/user_entity.dart';

import 'package:zifromania/features/user/data/models/game_stats.dart';
import 'package:zifromania/features/user/data/models/subscription_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.displayName,
    super.email,
    super.photoUrl,
    super.coins = 0,
    super.level = 1,
    super.xp = 0,
    super.xpForNextLevel = 10,
    super.hasActiveSubscription = false,
    super.achievements = const <String>[],
    super.completedTasks = const <String>[],
    required super.subscription,
    super.playedDates = const <String>[],
    super.currentStreak = 0,
    super.longestStreak = 0,
    super.gameStats = const GameStats(),
  });

  @override
  GameStats get gameStats => super.gameStats as GameStats;

  /// Firebase User + (isteğe bağlı) Firestore profil məlumatını birləşdirir
  factory UserModel.fromFirebase({
    required firebase.User user,
    Map<String, dynamic>? profileMap,
  }) {
    final map = profileMap ?? {};
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? map['displayName'] as String? ?? 'username',
      email: user.email ?? map['email'] as String? ?? 'user@example.com',
      photoUrl: user.photoURL ?? map['photoUrl'] as String? ?? '',
      coins: map['coins'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      xpForNextLevel: map['xpForNextLevel'] as int? ?? 10,
      hasActiveSubscription: map['hasActiveSubscription'] as bool? ?? false,
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>() ?? const [],
      completedTasks: (map['completedTasks'] as List<dynamic>?)?.cast<String>() ?? const [],
      subscription: SubscriptionModel.fromMap(map['subscription'] as Map<String, dynamic>? ?? {}),
      playedDates: (map['playedDates'] as List<dynamic>?)?.cast<String>() ?? const [],
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      gameStats: GameStats.fromMap(map['gameStats'] as Map<String, dynamic>? ?? {}),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      coins: entity.coins,
      level: entity.level,
      xp: entity.xp,
      xpForNextLevel: entity.xpForNextLevel,
      hasActiveSubscription: entity.hasActiveSubscription,
      achievements: entity.achievements,
      completedTasks: entity.completedTasks,
      subscription: SubscriptionModel.fromEntity(entity.subscription),
      playedDates: entity.playedDates,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      gameStats: GameStats.fromEntity(entity.gameStats),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'coins': coins,
      'level': level,
      'xp': xp,
      'xpForNextLevel': xpForNextLevel,
      'hasActiveSubscription': hasActiveSubscription,
      'achievements': achievements,
      'completedTasks': completedTasks,
      'subscription': subscription.toMap(),
      'playedDates': playedDates,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'gameStats': gameStats.toMap(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      coins: map['coins'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      xpForNextLevel: map['xpForNextLevel'] as int? ?? 10,
      hasActiveSubscription: map['hasActiveSubscription'] as bool? ?? false,
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>() ?? const [],
      completedTasks: (map['completedTasks'] as List<dynamic>?)?.cast<String>() ?? const [],
      subscription: SubscriptionModel.fromMap(map['subscription'] as Map<String, dynamic>? ?? {}),
      playedDates: (map['playedDates'] as List<dynamic>?)?.cast<String>() ?? const [],
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      gameStats: GameStats.fromMap(map['gameStats'] as Map<String, dynamic>? ?? {}),
    );
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    int? coins,
    int? level,
    int? xp,
    int? xpForNextLevel,
    bool? hasActiveSubscription,
    List<String>? achievements,
    List<String>? completedTasks,
    SubscriptionModel? subscription,
    List<String>? playedDates,
    int? currentStreak,
    int? longestStreak,
    GameStats? gameStats,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      achievements: achievements ?? this.achievements,
      completedTasks: completedTasks ?? this.completedTasks,
      subscription: subscription ?? this.subscription,
      playedDates: playedDates ?? this.playedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      gameStats: gameStats ?? this.gameStats,
    );
  }
}
