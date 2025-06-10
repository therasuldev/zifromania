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

class PressableFilledButton extends StatefulWidget {
  const PressableFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  State<PressableFilledButton> createState() => _PressableFilledButtonState();
}

class _PressableFilledButtonState extends State<PressableFilledButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.7,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spring() async {
    await _controller.reverse();
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) async => await _spring(),
      onTapCancel: () => _controller.forward(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: widget.style,
          child: widget.child,
        ),
      ),
    );
  }
}
