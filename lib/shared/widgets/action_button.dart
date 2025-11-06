import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

enum ButtonType {
  primary,
  secondary,
  danger,
  muted,
  incorrect;

  Color background(BuildContext context) {
    switch (this) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.muted:
        return AppColors.muted;
      case ButtonType.incorrect:
        return AppColors.error;
    }
  }

  Color foreground(BuildContext context) {
    switch (this) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return Colors.black87; // secondary is light; use dark text
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.muted:
        return AppColors.placeholder;
      case ButtonType.incorrect:
        return Colors.white;
    }
  }

  ButtonStyle toStyle(BuildContext context) {
    return FilledButton.styleFrom(
      backgroundColor: background(context),
      foregroundColor: foreground(context),
      shape: const StadiumBorder(),
    );
  }

  EdgeInsets padding() {
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final ButtonType type;
  final int width;
  final int height;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width = 244,
    this.height = 244,
    this.padding,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: type.background(context),
        foregroundColor: type.foreground(context),
        padding: padding ?? type.padding(),
        minimumSize: minimumSize,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
