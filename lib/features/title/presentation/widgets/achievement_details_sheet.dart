import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:zifromania/features/title/presentation/widgets/achievement.dart';

class AchievementDetailsSheet extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onShare;
  final GlobalKey shareCardKey;
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subTextColor;

  const AchievementDetailsSheet({
    super.key,
    required this.achievement,
    required this.onShare,
    required this.shareCardKey,
    required this.backgroundColor,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/scaffold.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pull indicator
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Shareable card (for screenshot)
          RepaintBoundary(
            key: shareCardKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cardBackgroundColor,
                    achievement.isUnlocked ? achievement.color.withValues(alpha: 0.1) : cardBackgroundColor,
                  ],
                ),
                border: Border.all(color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.5) : Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy/Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Halo effect
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Icon container
                      achievement.isUnlocked
                          ? ClipOval(
                              child: Image.asset(
                                achievement.icon,
                                width: 80,
                                height: 80,
                              ),
                            )
                          : Icon(
                              Icons.lock,
                              size: 48,
                              color: Colors.grey.withValues(alpha: 0.7),
                            ),

                      if (achievement.isUnlocked && achievement.score != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: achievement.color,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: achievement.color.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              achievement.score!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Scabber',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Scabber',
                      color: achievement.isUnlocked ? achievement.color : Colors.grey.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Scabber',
                      color: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Earned/Locked badge
                  if (achievement.isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            achievement.color.withValues(alpha: 0.8),
                            achievement.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: achievement.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'achievements.earned'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Scabber',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'achievements.locked'.tr(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: 'Scabber',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Earned date (only for unlocked achievements)
                  if (achievement.isUnlocked && achievement.unlockedDate != null)
                    Text(
                      'achievements.earned_date'.tr(
                        args: ['${achievement.unlockedDate!.day}/${achievement.unlockedDate!.month}/${achievement.unlockedDate!.year}'],
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Scabber',
                        color: subTextColor,
                      ),
                    ),

                  // Game logo
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/zifromania.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ZifroMania',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontFamily: 'Scabber',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Paylaşım butonu (sadece kazanılan başarılar için)
          if (achievement.isUnlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: achievement.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.share),
                  label: Text(
                    'achievements.share.title'.tr(),
                    style: const TextStyle(
                      fontFamily: 'Scabber',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'achievements.close'.tr(),
                    style: const TextStyle(
                      fontFamily: 'Scabber',
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu başarıyı kazanmak için oyuna devam edin!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Scabber',
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
