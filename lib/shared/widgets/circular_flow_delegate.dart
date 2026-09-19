import 'package:flutter/material.dart';
import 'dart:math' show cos, pi, sin;

class CircularFlowDelegate extends FlowDelegate {
  final Alignment startingPoint;
  final double radius;
  final double openFraction;

  CircularFlowDelegate({
    this.startingPoint = Alignment.bottomRight,
    this.radius = 100.0,
    this.openFraction = 1.0,
  });

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the center based on startingPoint
    final size = context.size;
    late final Offset center;

    // Position based on alignment
    if (startingPoint == Alignment.bottomRight) {
      center = Offset(size.width - radius / 2, size.height - radius / 2);
    } else if (startingPoint == Alignment.bottomLeft) {
      center = Offset(radius / 2, size.height - radius / 2);
    } else if (startingPoint == Alignment.topRight) {
      center = Offset(size.width - radius / 2, radius / 2);
    } else if (startingPoint == Alignment.topLeft) {
      center = Offset(radius / 2, radius / 2);
    } else {
      // Default to center
      center = Offset(size.width / 2, size.height / 2);
    }

    // Calculate the arc range based on the number of children
    const double arcLength = pi; // Half circle by default

    for (int i = 0; i < context.childCount; i++) {
      final childSize = context.getChildSize(i)!;
      final childRadius = radius * openFraction;

      // Calculate angle (distributing buttons across the arc)
      final angle = (i * arcLength / (context.childCount - 1)) - pi / 2;

      // Calculate position
      final childOffset = Offset(
        center.dx + childRadius * cos(angle) - childSize.width / 2,
        center.dy + childRadius * sin(angle) - childSize.height / 2,
      );

      context.paintChild(
        i,
        transform: Matrix4.translationValues(childOffset.dx, childOffset.dy, 0.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircularFlowDelegate oldDelegate) {
    return oldDelegate.startingPoint != startingPoint || oldDelegate.radius != radius || oldDelegate.openFraction != openFraction;
  }
}
