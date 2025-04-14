import 'package:equation_quest/presentation/screens/game_screen.dart';
import 'package:equation_quest/presentation/state_managment/game_bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/enums.dart';
import 'dialogs/rules_dialog.dart';

class DifficultyButton extends StatefulWidget {
  final String title;
  final Color color;
  final GameDifficulty difficulty;

  const DifficultyButton({
    super.key,
    required this.title,
    required this.color,
    required this.difficulty,
  });

  @override
  State<DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<DifficultyButton> with SingleTickerProviderStateMixin {
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
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RulesDialog(difficulty: widget.difficulty),
    );

    // Əgər istifadəçi oyuna başlamağı seçibsə:
    if (result == true && mounted) {
      // Create the UnifiedGameBloc provider and navigate to the game screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => GameBloc(),
            child: GameScreen(difficulty: widget.difficulty),
          ),
        ),
      );
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
  final DifficultyButton widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Konteynerlə düyməyə əlavə kölgə və kənar radius veririk
      decoration: BoxDecoration(
        color: _buttonColor,
        gradient: LinearGradient(
          colors: [
            _buttonColor,
            _buttonColor.withOpacity(0.8),
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(5, 5),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.009) // Perspektiv effekti
          ..rotateX(0.1) // X oxu ətrafında əyilmə
          ..rotateY(0.05) // Y oxu ətrafında yüngül dönmə
          ..translate(0.0, -5.0, -10.0), // Bir az geri və yuxarı hərəkət
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              letterSpacing: 1.5,
              fontFamily: 'Onacona',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
