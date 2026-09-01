import 'package:flutter/material.dart';
import 'package:zifromania/domain/entities/constant.dart';

class SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.leading,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(height: 32, width: 32, child: leading),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Scabber', fontSize: 18, color: lightBrownColor),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
