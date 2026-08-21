import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'game_stats.dart';
import 'subscription_model.dart';

class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final int coins;
  final int level;
  final int xp;
  final int xpForNextLevel;
  final bool hasActiveSubscription;
  final List<String> achievements;
  final List<String> completedTasks;
  final SubscriptionModel subscription;
  final List<String> playedDates;
  final int currentStreak;
  final int longestStreak;
  final GameStats gameStats;

  const UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.coins = 0,
    this.level = 1,
    this.xp = 0,
    this.xpForNextLevel = 10,
    this.hasActiveSubscription = false,
    this.achievements = const <String>[],
    this.completedTasks = const <String>[],
    required this.subscription,
    this.playedDates = const <String>[],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.gameStats = const GameStats(),
  });

  /// Firebase User + (isteğe bağlı) Firestore profil məlumatını birləşdirir
  factory UserModel.fromFirebase({
    required firebase.User user,
    Map<String, dynamic>? profileMap,
  }) {
    final map = profileMap ?? {};
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? map['displayName'],
      email: user.email ?? map['email'],
      photoURL: user.photoURL ?? map['photoURL'],
      coins: map['coins'] ?? 0,
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      xpForNextLevel: map['xpForNextLevel'] ?? 10,
      hasActiveSubscription: map['hasActiveSubscription'] ?? false,
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>() ?? const [],
      completedTasks: (map['completedTasks'] as List<dynamic>?)?.cast<String>() ?? const [],
      subscription: SubscriptionModel.fromMap(map['subscription'] ?? {}),
      playedDates: (map['playedDates'] as List<dynamic>?)?.cast<String>() ?? const [],
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      gameStats: GameStats.fromMap(map['gameStats'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
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

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
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
      photoURL: photoURL ?? this.photoURL,
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
