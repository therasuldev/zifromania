import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Image.asset('assets/icons/back.png', height: 24, width: 24, color: Colors.black54),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
