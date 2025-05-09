import 'dart:math';

/// A service for calculating XP requirements and earnings.
class XpService {
  // Base XP for level 1 ➔ 2
  static const int _baseXp = 100;
  // Growth exponent for level requirement
  static const double _alpha = 1.5;

  /// Calculates the XP required to advance from [level] to [level + 1].
  ///
  /// Formula:
  ///   XPReq(L) = ceil(BASE * L^α)
  ///
  /// Example:
  ///   Level 1 ➔ 2: ceil(100 * 1^1.5) = 100
  ///   Level 2 ➔ 3: ceil(100 * 2^1.5) ≈ 283
  static int xpForNextLevel(int level) {
    return (_baseXp * pow(level, _alpha)).ceil();
  }

  /// Calculates XP earned for a game session.
  ///
  /// - net = max(0, correctAnswers - (wrongAnswers ~/ 4))
  ///    * Every 4 wrong answers cancels 1 correct.
  /// - XP  = net * multiplier
  ///
  /// [correctAnswers]: number of correct responses
  /// [wrongAnswers]: number of incorrect responses
  /// [multiplier]:   category-based XP multiplier
  static int calculateGameXp({
    required int correctAnswers,
    required int wrongAnswers,
    required int multiplier,
  }) {
    final int net = correctAnswers - (wrongAnswers ~/ 4);
    return (net > 0 ? net : 0) * multiplier;
  }
}
