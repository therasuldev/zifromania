import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String? title; // Title artık optional
  final Widget? icon; // Icon da optional
  final Color color;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double fontSize;
  final String fontFamily;
  final EdgeInsets padding;
  final double borderRadius;
  final bool useGradient;
  final bool usePerspective;

  const AnimatedButton({
    super.key,
    this.title,
    this.icon,
    required this.color,
    required this.onTap,
    this.width,
    this.height,
    this.fontSize = 22,
    this.fontFamily = 'Onacona',
    this.padding = const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
    this.borderRadius = 12,
    this.useGradient = true,
    this.usePerspective = false,
  }) : assert((title == null) != (icon == null), "Either title or icon must be provided, but not both");

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Color _buttonColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _buttonColor = widget.color;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _animationController.reverse();
    setState(() => _buttonColor = widget.color.withValues(alpha: 0.9));
  }

  void _onTapUp(TapUpDetails _) {
    _animationController.forward();
    setState(() => _buttonColor = widget.color);
    widget.onTap();
  }

  void _onTapCancel() {
    _animationController.animateTo(1.0);
    setState(() => _buttonColor = widget.color);
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
          child: _ButtonContent(
            title: widget.title,
            icon: widget.icon,
            color: _buttonColor,
            width: widget.width,
            height: widget.height,
            fontSize: widget.fontSize,
            fontFamily: widget.fontFamily,
            padding: widget.padding,
            borderRadius: widget.borderRadius,
            useGradient: widget.useGradient,
            usePerspective: widget.usePerspective,
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String? title;
  final Widget? icon;
  final Color color;
  final double? width;
  final double? height;
  final double fontSize;
  final String fontFamily;
  final EdgeInsets padding;
  final double borderRadius;
  final bool useGradient;
  final bool usePerspective;

  const _ButtonContent({
    this.title,
    this.icon,
    required this.color,
    this.width,
    this.height,
    required this.fontSize,
    required this.fontFamily,
    required this.padding,
    required this.borderRadius,
    required this.useGradient,
    required this.usePerspective,
  });

  @override
  Widget build(BuildContext context) {
    // Eğer icon sağlanmışsa onu, aksi halde title'ı göster
    Widget contentChild = icon != null
        ? Center(child: icon)
        : Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: fontFamily,
              color: Colors.white,
            ),
          );

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.1),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              )
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
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
        padding: padding,
        child: contentChild,
      ),
    );

    if (usePerspective) {
      content = Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.009)
          ..rotateX(0.1)
          ..rotateY(0.05)
          ..translate(0.0, -5.0, -10.0),
        alignment: Alignment.center,
        child: content,
      );
    }

    return content;
  }
}
