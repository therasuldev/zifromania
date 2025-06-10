import 'package:flutter/material.dart';

class PartialModalRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  PartialModalRoute({required this.child})
      : super(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (ctx, anim, secAnim) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: FractionallySizedBox(
                  heightFactor: .99,
                  widthFactor: 1,
                  child: child,
                ),
              ),
            );
          },
          transitionsBuilder: (ctx, anim, secAnim, child) {
            final tween = Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
            return SlideTransition(
              position: anim.drive(tween),
              child: child,
            );
          },
        );
}
