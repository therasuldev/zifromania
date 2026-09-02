import 'package:flutter/material.dart';

/// Simple UI model shared by title-based and task-based achievements so
/// [AchievementCard] / [AchievementDetailsSheet] don't need to know about
/// `TitleEntity` or `TaskModel` directly.
class Achievement {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final bool isUnlocked;
  final String? score;
  final String? titleKey;
  final DateTime? unlockedDate;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.isUnlocked,
    this.score,
    this.unlockedDate,
  });
}

String getTitleIconAsset(String titleKey) {
  return "assets/title-avatars/$titleKey.png";
}
