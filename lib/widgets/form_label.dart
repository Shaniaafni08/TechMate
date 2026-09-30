import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FormLabel extends StatelessWidget {
  final String text;

  const FormLabel(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
        left: 4,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}