import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:zifromania/core/router/route_names.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/presentation/widgets/dialogs/rules_dialog.dart';

class GameCategoryButton extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  final GameCategory category;

  const GameCategoryButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.category,
  });

  @override
  State<GameCategoryButton> createState() => _GameCategoryButtonState();
}

class _GameCategoryButtonState extends State<GameCategoryButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Color _buttonColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.9, // Kiçilmə dərəcəsi
      upperBound: 1.0, // Normal ölçü
    );
    _buttonColor = widget.color; // Əsas rəng
    _animationController.forward(); // Başda böyüyür
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _animationController.reverse(); // Basanda kiçilir
    setState(() => _buttonColor = widget.color.withValues(alpha: 0.9));
  }

  void _onTapUp(TapUpDetails _) async {
    _animationController.forward();
    setState(() => _buttonColor = widget.color);

    // Qaydalar pəncərəsini göstər və nəticəni gözlə
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RulesDialog(gameCategory: widget.category),
    );

    // Əgər istifadəçi oyuna başlamağı seçibsə:
    if ((result?['isTrue'] as bool?) ?? false) {
      // Create the UnifiedGameBloc provider and navigate to the game screen
      final paidWithCoin = result?['paidWithCoin'] as bool? ?? false;
      context.push('${RouteNames.game}/${widget.category.name}?paidWithCoin=$paidWithCoin');
    }
  }

  void _onTapCancel() {
    _animationController.animateTo(1.0); // Əgər toxunub çıxarsa, normal ölçüyə qayıdır
    setState(() => _buttonColor = widget.color); // Normal rəngə qayıdır
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _animationController.value,
          child: ChildWidget(
            buttonColor: _buttonColor,
            widget: widget,
          ),
        ),
      ),
    );
  }
}

class ChildWidget extends StatelessWidget {
  const ChildWidget({
    super.key,
    required Color buttonColor,
    required this.widget,
  }) : _buttonColor = buttonColor;

  final Color _buttonColor;
  final GameCategoryButton widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Konteynerlə düyməyə əlavə kölgə və kənar radius veririk
      decoration: BoxDecoration(
        color: _buttonColor,
        gradient: LinearGradient(
          colors: [
            _buttonColor,
            _buttonColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(5, 5),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                // letterSpacing: 1.5,
                fontFamily: 'Scabber',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(height: 32, width: 32, child: Image.asset(widget.icon)),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
