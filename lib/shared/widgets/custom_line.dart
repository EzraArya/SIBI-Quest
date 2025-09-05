import 'package:flutter/material.dart';

class CustomLine extends StatelessWidget {
  final Axis axis;

  final double thickness;

  final double length;

  final Color? color;

  final BorderRadius? radius;

  const CustomLine({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1.0,
    this.length = double.infinity,
    this.color,
    this.radius,
  });

  const CustomLine.horizontal({
    super.key,
    this.thickness = 1.0,
    this.length = double.infinity,
    this.color,
    this.radius,
  }) : axis = Axis.horizontal;

  const CustomLine.vertical({
    super.key,
    this.thickness = 1.0,
    this.length = double.infinity,
    this.color,
    this.radius,
  }) : axis = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? Theme.of(context).dividerColor;

    return SizedBox(
      width: axis == Axis.horizontal ? length : thickness,
      height: axis == Axis.horizontal ? thickness : length,
      child: DecoratedBox(
        decoration: BoxDecoration(color: lineColor, borderRadius: radius),
      ),
    );
  }
}
