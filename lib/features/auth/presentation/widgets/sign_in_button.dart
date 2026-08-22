import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onTap;
  final bool enabled;

  const SignInButton({
    super.key,
    required this.text,
    required this.iconPath,
    this.onTap,
    this.enabled = true,
  });

  static const double _buttonHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.6,
      child: Material(
        color: enabled ? Colors.white : Colors.white60,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: _buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled ? Colors.grey.shade300 : Colors.grey.shade400,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: enabled ? 0.05 : 0.02),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(iconPath, height: 24),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Scabber',
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.black87 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
