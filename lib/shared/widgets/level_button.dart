import 'package:flutter/material.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/chat_bubble_popup.dart';

enum LevelButtonStyle {
  defaultStyle,
  completed,
  locked;

  Color get textColor {
    switch (this) {
      case LevelButtonStyle.defaultStyle:
      case LevelButtonStyle.locked:
        return AppColors.text;
      case LevelButtonStyle.completed:
        return AppColors.primary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LevelButtonStyle.defaultStyle:
        return AppColors.primary;
      case LevelButtonStyle.completed:
        return AppColors.complementary;
      case LevelButtonStyle.locked:
        return AppColors.muted;
    }
  }

  String get popupSubtitle {
    switch (this) {
      case LevelButtonStyle.defaultStyle:
        return "Complete this level to earn rewards";
      case LevelButtonStyle.completed:
        return "You have completed this level";
      case LevelButtonStyle.locked:
        return "This level is locked";
    }
  }

  String get popupButtonTitle {
    switch (this) {
      case LevelButtonStyle.defaultStyle:
        return "Start";
      case LevelButtonStyle.completed:
        return "Completed";
      case LevelButtonStyle.locked:
        return "Locked";
    }
  }
}

class LevelButton extends StatelessWidget {
  final String level;
  final LevelButtonStyle style;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final ValueNotifier<String?> activePopupNotifier;

  const LevelButton({
    super.key,
    required this.level,
    this.style = LevelButtonStyle.defaultStyle,
    this.title = "Level",
    this.subtitle = "Complete this level",
    required this.activePopupNotifier,
    this.action,
  });

  String get _effectiveSubtitle {
    if (style == LevelButtonStyle.defaultStyle) {
      return subtitle;
    } else {
      return style.popupSubtitle;
    }
  }

  void _onTap() {
    if (activePopupNotifier.value == level) {
      // Close popup if it's already open
      activePopupNotifier.value = null;
    } else {
      // Open this popup, closing any others
      activePopupNotifier.value = level;
    }
  }

  ChatBubblePopupStyle _getChatBubbleStyle() {
    switch (style) {
      case LevelButtonStyle.locked:
        return ChatBubblePopupStyle.inactive;
      case LevelButtonStyle.completed:
        return ChatBubblePopupStyle.completed;
      case LevelButtonStyle.defaultStyle:
        return ChatBubblePopupStyle.defaultStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: activePopupNotifier,
      builder: (context, activePopup, child) {
        final isPopupVisible = activePopup == level;

        return SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Level Button
              GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.30),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomText(
                      text: level,
                      type: CustomTextType.bodyBold,
                      color: style.textColor,
                    ),
                  ),
                ),
              ),

              // Popup
              if (isPopupVisible)
                Positioned(
                  left: 75,
                  child: AnimatedScale(
                    scale: isPopupVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedOpacity(
                      opacity: isPopupVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: ChatBubblePopup(
                        title: title,
                        subtitle: _effectiveSubtitle,
                        buttonTitle: style.popupButtonTitle,
                        style: _getChatBubbleStyle(),
                        buttonAction: () {
                          activePopupNotifier.value = null;
                          action?.call();
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
