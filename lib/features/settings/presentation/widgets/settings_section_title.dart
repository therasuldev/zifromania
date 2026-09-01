import 'package:flutter/material.dart';
import 'package:zifromania/domain/entities/constant.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Scabber',
              color: transparentIndigoColor,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
