import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class AppSystemIcon extends StatelessWidget {
  final IconData icon;
  final double? width;
  final double? height;
  final Color color;

  const AppSystemIcon({
    super.key,
    required this.icon,
    this.width = 24,
    this.height = 24,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (width ?? height ?? 24).toDouble();

    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
