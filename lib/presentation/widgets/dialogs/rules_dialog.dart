import 'package:easy_localization/easy_localization.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/presentation/widgets/animated_button.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';
import 'package:flutter/material.dart';

class RulesDialog extends StatelessWidget {
  const RulesDialog({super.key, required this.gameCategory});

  final GameCategory gameCategory;

  @override
  Widget build(BuildContext context) {
    // Get the appropriate rules based on category
    final List<Map<String, String>> rules = _getRulesForCategory(gameCategory, context: context);

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
                            _getTitleForCategory(gameCategory, context: context),
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
              title: context.tr('button.start_game'),
              color: Colors.transparent,
              onTap: () => Navigator.of(context).pop(true),
              fontSize: 25,
              fontFamily: 'Scabber',
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper function to get the title based on category
  String _getTitleForCategory(GameCategory gameCategory, {required BuildContext context}) {
    return switch (gameCategory) {
      GameCategory.quickThinking => context.tr('title.quick_thinking'),
      GameCategory.multiplyDivide => context.tr('title.multiply_divide'),
      GameCategory.trueOrFalse => context.tr('title.true_or_false'),
      GameCategory.expert => context.tr('title.expert'),
      GameCategory.training => context.tr('title.training'),
    };
  }

  List<Map<String, String>> _getRulesForCategory(GameCategory gameCategory, {required BuildContext context}) {
    final icons = [
      'assets/icons/timer.png',
      'assets/icons/info.png',
      'assets/icons/right-arrow.png',
    ];

    final keys = List.generate(3, (i) => 'rules.${_categoryKey(gameCategory)}.$i');
    return List.generate(3, (i) => {'icon': icons[i], 'text': context.tr(keys[i])});
  }

// Helper to convert enum to key string
  String _categoryKey(GameCategory category) {
    switch (category) {
      case GameCategory.quickThinking:
        return 'quick_thinking';
      case GameCategory.multiplyDivide:
        return 'multiply_divide';
      case GameCategory.trueOrFalse:
        return 'true_or_false';
      case GameCategory.expert:
        return 'expert';
      case GameCategory.training:
        return 'training';
    }
  }
}
