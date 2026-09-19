import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String? title; // Title artık optional
  final Widget? icon; // Icon da optional
  final Color color;
  final Color? borderColor; // Varsayılan border rengi
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double fontSize;
  final String fontFamily;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final bool useGradient;
  final bool usePerspective;

  const AnimatedButton({
    super.key,
    this.title,
    this.icon,
    required this.color,
    this.borderColor,
    this.onTap,
    this.width,
    this.height,
    this.fontSize = 22,
    this.fontFamily = 'Onacona',
    this.padding = const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.useGradient = true,
    this.usePerspective = false,
  }) : assert((title == null) != (icon == null), "Either title or icon must be provided, but not both");

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.9,
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
    widget.onTap?.call();
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
          child: _ButtonContent(
            title: widget.title,
            icon: widget.icon,
            color: widget.color,
            borderColor: widget.borderColor?.withValues(alpha: 0.3) ?? Colors.brown.shade100.withValues(alpha: 0.3),
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
  final Color borderColor;
  final double? width;
  final double? height;
  final double fontSize;
  final String fontFamily;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final bool useGradient;
  final bool usePerspective;

  const _ButtonContent({
    this.title,
    this.icon,
    required this.color,
    required this.borderColor,
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
        : FittedBox(
            child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 2.5,
              fontSize: fontSize,
              fontFamily: fontFamily,
              color: Colors.grey.shade200.withValues(alpha: 0.7),
            ),
          ));

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: borderRadius,
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
