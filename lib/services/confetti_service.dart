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
  
  void reset() {
    _confettiController.dispose();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }
  
  void dispose() {
    _confettiController.dispose();
  }
  
  Widget buildConfettiWidget({
    // Alignment alignment = Alignment.center,
    BlastDirectionality blastDirectionality = BlastDirectionality.explosive,
    bool shouldLoop = true,
    List<Color> colors = const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
  }) {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: blastDirectionality,
      shouldLoop: shouldLoop,
      colors: colors,
      // alignment: alignment,
    );
  }
}