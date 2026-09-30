import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TechMateLogo extends StatelessWidget {
  final double size;

  const TechMateLogo({
    super.key,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.memory,
        size: size * 0.55,
        color: AppColors.logo,
      ),
    );
  }
}