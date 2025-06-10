import 'package:firebase_auth/firebase_auth.dart';

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
  final List<String> achievements; // Earned titles
  final List<String> completedTasks; // IDs of tasks completed by user
  final SubscriptionModel subscription;

  // 🆕 New fields for game statistics
  final List<String> playedDates; // Format: "yyyy-MM-dd"
  final int currentStreak; // Current daily streak
  final int longestStreak; // Longest streak ever
  final GameStats gameStats; // Overall game statistics

  const UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.coins = 0,
    this.level = 1,
    this.xp = 0,
    this.xpForNextLevel = 1000,
    this.hasActiveSubscription = false,
    this.achievements = const <String>[],
    this.completedTasks = const <String>[],
    required this.subscription,
    this.playedDates = const <String>[],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.gameStats = const GameStats(),
  });

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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'],
      email: map['email'],
      photoURL: map['photoURL'],
      coins: map['coins'] ?? 0,
      level: map['level'] ?? 0,
      xp: map['xp'] ?? 0,
      xpForNextLevel: map['xpForNextLevel'] ?? 1000,
      hasActiveSubscription: map['hasActiveSubscription'] ?? false,
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      completedTasks: (map['completedTasks'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      subscription: SubscriptionModel.fromMap(map['subscription']),
      playedDates: (map['playedDates'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      gameStats: GameStats.fromMap(map['gameStats']),
    );
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

  /// Construct directly from a [firebase.User] when the profile is first created.
  /// This factory method initializes a new user with default values for game-related fields.
  factory UserModel.fromFirebaseUser(
    User user, {
    int coins = 0,
    int level = 1,
    int xp = 0,
    int xpForNextLevel = 1000,
    bool hasActiveSubscription = false,
    SubscriptionModel? subscription,
    List<String> achievements = const <String>[],
    List<String> completedTasks = const <String>[],
    List<String> playedDates = const <String>[],
    int currentStreak = 0,
    int longestStreak = 0,
    GameStats? gameStats,
  }) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      coins: coins,
      level: level,
      xp: xp,
      xpForNextLevel: xpForNextLevel,
      hasActiveSubscription: hasActiveSubscription,
      subscription: subscription ?? const SubscriptionModel(),
      achievements: achievements,
      completedTasks: completedTasks,
      playedDates: playedDates,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      gameStats: gameStats ?? const GameStats(),
    );
  }
}
