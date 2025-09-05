import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/typography.dart';

enum CustomTextType {
  body,
  bodyBold,
  title,
  display,
}

class CustomText extends StatelessWidget {
  final String text;
  final CustomTextType type;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomText({
    super.key,
    required this.text,
    this.type = CustomTextType.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _mapTypeToStyle(type).copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _mapTypeToStyle(CustomTextType type) {
    switch (type) {
      case CustomTextType.body:
        return AppText.body;
      case CustomTextType.bodyBold:
        return AppText.bodyBold;
      case CustomTextType.title:
        return AppText.title;
      case CustomTextType.display:
        return AppText.display;
    }
  }
}
