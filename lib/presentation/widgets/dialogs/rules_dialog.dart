import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/presentation/widgets/animated_button.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:zifromania/services/game_limit_service.dart';

class RulesDialog extends StatelessWidget {
  const RulesDialog({super.key, required this.gameCategory});

  final GameCategory gameCategory;

  /// The limit displays the maximum allowed count for the category and how many items are currently played.

  @override
  Widget build(BuildContext context) {
    // Get the appropriate rules based on category
    final List<Map<String, String>> rules = _getRulesForCategory(gameCategory, context: context);
    final stats = locator.get<GameLimitService>().getCategoryStats(gameCategory);
    final current = stats['dailyRequestCount'] as int;
    final baseLimit = stats['categoryLimit'] as int;
    final flexibleGames = stats['flexibleGamesAvailable'] as int;

    // Limit text-ini düzgün format et
    String limitText;
    if (flexibleGames > 0) {
      limitText = '($current/$baseLimit + $flexibleGames)';
    } else {
      limitText = '($current/$baseLimit)';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            context.tr('game_categories.${gameCategory.toTextWithUnderscores()}'),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade200.withValues(alpha: 0.7),
                              fontFamily: 'Scabber',
                              overflow: TextOverflow.ellipsis,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedIconButton(
                        onTap: () => Navigator.of(context).pop(),
                        icon: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/delete.png')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rules.map((rule) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 32, width: 32, child: Image.asset(rule['icon']!)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rule['text']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white60,
                                fontFamily: 'Scabber',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            AnimatedButton(
              width: 200,
              title: '${context.tr('button.start_game')}\n$limitText',
              color: Colors.transparent,
              onTap: () => Navigator.of(context).pop({'isTrue': true, 'paidWithCoin': false}),
              fontSize: 22,
              fontFamily: 'Scabber',
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            if (current == baseLimit) ...[
              const SizedBox(height: 20),
              AnimatedButton(
                width: 200,
                title: context.tr('subscription.spend_coins_for_games'),
                color: Colors.transparent,
                onTap: () => Navigator.of(context).pop({'isTrue': true, 'paidWithCoin': true}),
                fontSize: 18,
                fontFamily: 'Scabber',
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              )
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getRulesForCategory(GameCategory gameCategory, {required BuildContext context}) {
    final icons = [
      'assets/icons/timer.png',
      'assets/icons/info.png',
      'assets/icons/right-arrow.png',
    ];

    final keys = List.generate(3, (i) => 'rules.${gameCategory.toTextWithUnderscores()}.$i');
    return List.generate(3, (i) => {'icon': icons[i], 'text': context.tr(keys[i])});
  }
}
