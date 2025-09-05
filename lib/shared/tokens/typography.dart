import 'package:flutter/material.dart';
import 'fonts.dart';

class FontSizes {
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double display = 32;
}

class AppText {
  static TextStyle of(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? height,
    Color? color,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: AppFonts.inter,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get body => of(FontSizes.md);
  static TextStyle get bodyBold => of(FontSizes.md, weight: FontWeight.w600);
  static TextStyle get title => of(FontSizes.lg, weight: FontWeight.w600);
  static TextStyle get display =>
      of(FontSizes.display, weight: FontWeight.w700);
}
