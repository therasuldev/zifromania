import 'game_stats_entity.dart';
import 'subscription_entity.dart';

class UserEntity {
  final String uid;

  final String? displayName;
  final String? email;
  final String? photoUrl;

  final int coins;
  final int level;
  final int xp;
  final int xpForNextLevel;

  final bool hasActiveSubscription;

  final List<String> achievements;
  final List<String> completedTasks;

  final SubscriptionEntity subscription;

  final List<String> playedDates;

  final int currentStreak;
  final int longestStreak;

  final GameStatsEntity gameStats;

  const UserEntity({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.coins,
    required this.level,
    required this.xp,
    required this.xpForNextLevel,
    required this.hasActiveSubscription,
    required this.achievements,
    required this.completedTasks,
    required this.subscription,
    required this.playedDates,
    required this.currentStreak,
    required this.longestStreak,
    required this.gameStats,
  });
}
