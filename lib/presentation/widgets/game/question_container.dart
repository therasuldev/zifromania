import 'package:flutter/material.dart';
import '../../common/grid_painter.dart';

class QuestionContainer extends StatelessWidget {
  final String question;

  const QuestionContainer({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Animated Background Pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CustomPaint(
                painter: GridPainter(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
          // Glowing Effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Question Text with Animation
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    letterSpacing: 2,
                    fontFamily: 'Brawler',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                      Shadow(
                        color: Colors.white.withOpacity(0.2),
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Decorative Elements
          Positioned(
            top: 10,
            left: 10,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.star_rounded,
                color: Colors.amber.shade300,
                size: 24,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                Icons.star_rounded,
                color: Colors.amber.shade300,
                size: 24,
              ),
            ),
          ),
          // Corner Decorations
          _buildCornerDecoration(top: true, left: true),
          _buildCornerDecoration(top: true, left: false),
          _buildCornerDecoration(top: false, left: true),
          _buildCornerDecoration(top: false, left: false),
        ],
      ),
    );
  }
  
  Widget _buildCornerDecoration({required bool top, required bool left}) {
    return Positioned(
      top: top ? 0 : null,
      left: left ? 0 : null,
      bottom: top ? null : 0,
      right: left ? null : 0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(25) : Radius.zero,
            topRight: top && !left ? const Radius.circular(25) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(25) : Radius.zero,
            bottomRight: !top && !left ? const Radius.circular(25) : Radius.zero,
          ),
        ),
      ),
    );
  }
}