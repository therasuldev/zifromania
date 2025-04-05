import 'package:flutter/material.dart';

import '../screens/game_screen.dart';
import '../../domain/entities/enums.dart';

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

  void _onTapUp(TapUpDetails _) {
    _animationController.forward(); // Buraxanda böyüyür
    setState(() => _buttonColor = widget.color); // Normal rəngə qayıdır

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 2, 104, 120),
                  Color.fromRGBO(9, 37, 29, 1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
                    color: Colors.white.withOpacity(0.1),
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
                          const Icon(
                            Icons.gamepad_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          Text(
                            "QAYDALAR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Brawler',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Image.asset('assets/icons/delete.png'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/timer.png'),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Oyun 1 dəqiqə davam edəcək. Bu vaxt ərzində mümkün qədər çox sualı cavablandırın.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'rimouskisb',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/info.png'),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Hər 4 səhv cavabdan sonra qazanılan xallardan biri çıxılacaq.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'rimouskisb',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/right-arrow.png'),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Suala cavab verildikdən sonra avtomatik digər suala keçilir və əvvəlki suala qayıdılmır.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'rimouskisb',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      builder(BuildContext context) => GameScreen(difficulty: widget.difficulty);
                      Navigator.push(context, MaterialPageRoute(builder: builder));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Tamam",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Onacona',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
