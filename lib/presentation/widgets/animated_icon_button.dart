import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final Widget? icon;
  final VoidCallback onTap;

  const AnimatedIconButton({
    super.key,
    this.icon,
    required this.onTap,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.85,
      upperBound: 1.0,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _animationController.reverse();
  }

  void _onTapUp(TapUpDetails _) {
    _animationController.forward();
    widget.onTap();
  }

  void _onTapCancel() {
    _animationController.animateTo(1.0);
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
          child: widget.icon,
        ),
      ),
    );
  }
}
