import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiService {
  late ConfettiController _confettiController;

  ConfettiService({Duration duration = const Duration(seconds: 1)}) {
    _confettiController = ConfettiController(duration: duration);
  }

  ConfettiController get controller => _confettiController;

  void play() {
    _confettiController.play();
  }

  void stop() {
    _confettiController.stop();
  }
  
  void dispose() {
    _confettiController.dispose();
  }

  Widget buildConfettiWidget({
    BlastDirectionality blastDirectionality = BlastDirectionality.explosive,
    bool shouldLoop = false,
    List<Color> colors = const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
  }) {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: blastDirectionality,
      shouldLoop: shouldLoop,
      colors: colors,
    );
  }
}
