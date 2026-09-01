import 'dart:math';

/// Service for XP calculations and level logic.
final class XpService {
  // XP required to go from level 1 ➔ 2
  static const int _baseXp = 10;
  // XP growth rate per level
  static const double _growthFactor = 1.5;

  /// Calculates XP needed to go from [level] to [level + 1].
  static int xpForNextLevel(int level) {
    return (_baseXp * pow(level, _growthFactor)).ceil();
  }

  /// Calculates earned XP based on game performance.
  ///
  /// Each 4 wrong answers cancel out 1 correct.
  /// Minimum earned XP is 0.
  static int calculateGameXp({
    required int correctAnswers,
    required int wrongAnswers,
    required int multiplier,
  }) {
    final int netCorrect = max(0, correctAnswers - (wrongAnswers ~/ 4));
    return netCorrect * multiplier;
  }
}
