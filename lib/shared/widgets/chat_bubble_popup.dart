import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';

enum ChatBubblePopupStyle {
  defaultStyle,
  inactive,
  completed;

  Color get textColor {
    switch (this) {
      case ChatBubblePopupStyle.defaultStyle:
        return AppColors.primary;
      case ChatBubblePopupStyle.inactive:
        return AppColors.accent;
      case ChatBubblePopupStyle.completed:
        return AppColors.text;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ChatBubblePopupStyle.defaultStyle:
        return AppColors.secondary;
      case ChatBubblePopupStyle.inactive:
        return AppColors.background;
      case ChatBubblePopupStyle.completed:
        return AppColors.primary;
    }
  }

  ButtonType get buttonStyle {
    switch (this) {
      case ChatBubblePopupStyle.defaultStyle:
        return ButtonType.primary;
      case ChatBubblePopupStyle.inactive:
        return ButtonType.muted;
      case ChatBubblePopupStyle.completed:
        return ButtonType.secondary;
    }
  }

  Color get outlineColor {
    switch (this) {
      case ChatBubblePopupStyle.defaultStyle:
      case ChatBubblePopupStyle.inactive:
      case ChatBubblePopupStyle.completed:
        return AppColors.accent;
    }
  }
}

class ChatBubblePopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonTitle;
  final ChatBubblePopupStyle style;
  final VoidCallback buttonAction;

  const ChatBubblePopup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonTitle,
    this.style = ChatBubblePopupStyle.defaultStyle,
    required this.buttonAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      child: CustomPaint(
        painter: ChatBubblePainter(
          backgroundColor: style.backgroundColor,
          outlineColor: style.outlineColor,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            14,
            16,
            14,
          ), // Extra left padding for triangle
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    type: CustomTextType.bodyBold,
                    color: style.textColor,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: subtitle,
                    type: CustomTextType.body,
                    color: style.textColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ActionButton(
                  label: buttonTitle,
                  type: style.buttonStyle,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  minimumSize: const Size.fromHeight(56),
                  onPressed: buttonAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubblePainter extends CustomPainter {
  final Color backgroundColor;
  final Color outlineColor;

  ChatBubblePainter({
    required this.backgroundColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = _createChatBubblePath(size);

    // Draw background
    canvas.drawPath(path, paint);

    // Draw outline
    canvas.drawPath(path, outlinePaint);
  }

  Path _createChatBubblePath(Size size) {
    final path = Path();
    const radius = 12.0;
    const triangleSize = 8.0;

    // Main bubble rectangle with rounded corners, offset to make room for triangle
    final rect = RRect.fromLTRBR(
      triangleSize,
      0,
      size.width,
      size.height,
      const Radius.circular(radius),
    );

    path.addRRect(rect);

    // Left triangle pointing left
    final trianglePath = Path();
    final triangleTop = size.height / 2 - triangleSize;
    final triangleBottom = size.height / 2 + triangleSize;

    trianglePath.moveTo(triangleSize, triangleTop); // Top of triangle base
    trianglePath.lineTo(0, size.height / 2); // Tip of triangle (pointing left)
    trianglePath.lineTo(
      triangleSize,
      triangleBottom,
    ); // Bottom of triangle base
    trianglePath.close();

    path.addPath(trianglePath, Offset.zero);

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! ChatBubblePainter ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.outlineColor != outlineColor;
  }
}
