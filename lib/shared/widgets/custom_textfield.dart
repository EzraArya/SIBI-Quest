import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

enum TextFieldType { primary, secondary, danger, muted }

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextFieldType type;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final int? maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.type = TextFieldType.primary,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.textInputAction,
    this.maxLines = 1,
  });

  Color _bg() {
    switch (type) {
      case TextFieldType.primary:
        return AppColors.textbox;
      case TextFieldType.secondary:
        return AppColors.secondary.withValues(alpha: 0.15);
      case TextFieldType.danger:
        return AppColors.error.withValues(alpha: 0.15);
      case TextFieldType.muted:
        return AppColors.muted;
    }
  }

  Color _fg() {
    switch (type) {
      case TextFieldType.primary:
        return AppColors.text;
      case TextFieldType.secondary:
        return AppColors.text;
      case TextFieldType.danger:
        return AppColors.text;
      case TextFieldType.muted:
        return AppColors.placeholder;
    }
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(28)), // Stadium-like
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    final bg = _bg();
    final fg = _fg();
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      textInputAction: textInputAction,
      style: TextStyle(color: fg),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.placeholder),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: bg,
        enabledBorder: _border(AppColors.line),
        focusedBorder: _border(AppColors.primary),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error),
      ),
      cursorColor: AppColors.primary,
    );
  }
}
