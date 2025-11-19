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
        return "Selesaikan level ini untuk mendapatkan hadiah";
      case LevelButtonStyle.completed:
        return "Kamu telah menyelesaikan level ini";
      case LevelButtonStyle.locked:
        return "Level ini masih terkunci";
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

class LevelButton extends StatefulWidget {
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

  @override
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String get _effectiveSubtitle => widget.style == LevelButtonStyle.defaultStyle
      ? widget.subtitle
      : widget.style.popupSubtitle;

  @override
  void initState() {
    super.initState();
    widget.activePopupNotifier.addListener(_handlePopupChange);
  }

  @override
  void didUpdateWidget(LevelButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activePopupNotifier != oldWidget.activePopupNotifier) {
      oldWidget.activePopupNotifier.removeListener(_handlePopupChange);
      widget.activePopupNotifier.addListener(_handlePopupChange);
    }
    // If the widget updates while overlay is open, we might want to rebuild the overlay
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    widget.activePopupNotifier.removeListener(_handlePopupChange);
    _removeOverlay();
    super.dispose();
  }

  void _handlePopupChange() {
    final isActive = widget.activePopupNotifier.value == widget.identifier;
    if (isActive && _overlayEntry == null) {
      _showOverlay();
    } else if (!isActive && _overlayEntry != null) {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onTap() {
    final isActive = widget.activePopupNotifier.value == widget.identifier;
    if (isActive) {
      // If active, just close it (toggle behavior)
      widget.activePopupNotifier.value = null;
      return;
    }
    // If not active, open it
    widget.activePopupNotifier.value = widget.identifier;
  }

  void _invokeAction() {
    if (widget.style == LevelButtonStyle.locked) {
      return;
    }
    widget.action?.call();
    Future.microtask(() => widget.activePopupNotifier.value = null);
  }

  ChatBubblePopupStyle _getChatBubbleStyle() {
    switch (widget.style) {
      case LevelButtonStyle.locked:
        return ChatBubblePopupStyle.inactive;
      case LevelButtonStyle.completed:
        return ChatBubblePopupStyle.completed;
      case LevelButtonStyle.defaultStyle:
        return ChatBubblePopupStyle.defaultStyle;
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 280, // Max width constraint from original
          child: CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.centerLeft,
            followerAnchor: Alignment.centerLeft,
            offset: const Offset(96, 0),
            showWhenUnlinked: false,
            child: Material(
              color: Colors.transparent,
              child: ChatBubblePopup(
                title: widget.title,
                subtitle: _effectiveSubtitle,
                buttonTitle: widget.style.popupButtonTitle,
                style: _getChatBubbleStyle(),
                buttonAction: _invokeAction,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.translucent,
          child: Container(
            width: 140,
            height: 60,
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.style.backgroundColor,
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
                  text: widget.level,
                  type: CustomTextType.bodyBold,
                  color: widget.style.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
