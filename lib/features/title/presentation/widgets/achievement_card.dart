import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:zifromania/features/title/presentation/widgets/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color subTextColor;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: achievement.isUnlocked ? Border.all(color: achievement.color.withValues(alpha: 0.5), width: 2) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background pattern
            if (achievement.isUnlocked)
              Positioned(
                right: -30,
                top: -30,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: achievement.color.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),

            // Achievement content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Achievement icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: achievement.isUnlocked ? achievement.color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                        achievement.isUnlocked
                            ? ClipOval(
                                child: Image.asset(
                                  getTitleIconAsset(achievement.titleKey!),
                                  width: 80,
                                  height: 80,
                                ),
                              )
                            : Icon(
                                Icons.lock,
                                size: 32,
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                        if (achievement.isUnlocked && achievement.score != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: achievement.color,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: achievement.color.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                achievement.score!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Scabber',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Achievement title
                    Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Scabber',
                        color: achievement.isUnlocked ? achievement.color : Colors.grey.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        achievement.description,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Scabber',
                          color: subTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Earned/Locked label
                    if (achievement.isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              achievement.color.withValues(alpha: 0.8),
                              achievement.color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: achievement.color.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'achievements.earned'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Scabber',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'achievements.locked'.tr(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontFamily: 'Scabber',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
