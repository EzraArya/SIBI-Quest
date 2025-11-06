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
  final String identifier;
  final LevelButtonStyle style;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final ValueNotifier<String?> activePopupNotifier;

  const LevelButton({
    super.key,
    required this.level,
    String? identifier,
    this.style = LevelButtonStyle.defaultStyle,
    this.title = "Level",
    this.subtitle = "Complete this level",
    required this.activePopupNotifier,
    this.action,
  }) : identifier = identifier ?? level;

  String get _effectiveSubtitle =>
      style == LevelButtonStyle.defaultStyle ? subtitle : style.popupSubtitle;

  void _onTap() {
    final isActive = activePopupNotifier.value == identifier;
    if (isActive) {
      if (style == LevelButtonStyle.locked) {
        activePopupNotifier.value = null;
        return;
      }
      _invokeAction();
      return;
    }
    activePopupNotifier.value = identifier;
  }

  void _invokeAction() {
    if (style == LevelButtonStyle.locked) {
      return;
    }
    action?.call();
    Future.microtask(() => activePopupNotifier.value = null);
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
      builder: (context, activePopup, _) {
        final isPopupVisible = activePopup == identifier;

        return SizedBox(
          width: double.infinity,
          height: 60,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              GestureDetector(
                onTap: _onTap,
                behavior: HitTestBehavior.translucent,
                child: SizedBox(
                  width: 140,
                  height: 60,
                  child: Align(
                    alignment: Alignment.centerLeft,
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
                      alignment: Alignment.center,
                      child: CustomText(
                        text: level,
                        type: CustomTextType.bodyBold,
                        color: style.textColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Popup floats outside
              if (isPopupVisible)
                Positioned(
                  left: 96, // distance from circle
                  child: IgnorePointer(
                    ignoring: false,
                    child: AnimatedOpacity(
                      opacity: isPopupVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: AnimatedSlide(
                        offset: isPopupVisible
                            ? Offset.zero
                            : const Offset(-0.2, 0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: ChatBubblePopup(
                          title: title,
                          subtitle: _effectiveSubtitle,
                          buttonTitle: style.popupButtonTitle,
                          style: _getChatBubbleStyle(),
                          buttonAction: () {
                            _invokeAction();
                          },
                        ),
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
