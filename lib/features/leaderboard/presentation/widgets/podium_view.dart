import 'package:flutter/material.dart';
import 'package:sibi_quest/features/leaderboard/domain/models/leaderboard_player.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';

class PodiumView extends StatelessWidget {
  final List<LeaderboardPlayer> players;

  const PodiumView({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const SizedBox.shrink();
    }

    const podiumOrder = [1, 0, 2];
    final indices = podiumOrder
        .where((index) => index < players.length)
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < indices.length; i++) ...[
          Expanded(
            child: _PodiumItem(
              player: players[indices[i]],
              position: indices[i],
            ),
          ),
          if (i != indices.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardPlayer player;
  final int position;

  const _PodiumItem({required this.player, required this.position});

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColorForPosition(position);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlayerAvatar(player: player, borderColor: iconColor),
        const SizedBox(height: 12),
        CustomText(
          text: player.displayName,
          type: CustomTextType.bodyBold,
          color: AppColors.text,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        CustomText(
          text: player.totalScore.toString(),
          type: CustomTextType.title,
          color: AppColors.complementary,
        ),
        const SizedBox(height: 16),
        _PodiumBase(position: position),
      ],
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final LeaderboardPlayer player;
  final Color borderColor;

  const _PlayerAvatar({required this.player, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final imageUrl = player.imageUrl;

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.muted,
        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : null,
        child: imageUrl == null || imageUrl.isEmpty
            ? const Icon(Icons.person, color: AppColors.placeholder, size: 28)
            : null,
      ),
    );
  }
}

class _PodiumBase extends StatelessWidget {
  final int position;

  const _PodiumBase({required this.position});

  @override
  Widget build(BuildContext context) {
    final double height = _heightForPosition(position);
    final Color baseColor = position == 0
        ? AppColors.accent
        : AppColors.primary;
    final Color iconColor = _iconColorForPosition(position);
    final IconData iconData = _iconDataForPosition(position);
    final BorderRadius borderRadius = _borderRadiusForPosition(position);

    return SizedBox(
      height: height + 52,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: borderRadius,
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(iconData, color: iconColor, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconDataForPosition(int position) {
  switch (position) {
    case 0:
      return Icons.looks_one;
    case 1:
      return Icons.looks_two;
    case 2:
      return Icons.looks_3;
    default:
      return Icons.emoji_events;
  }
}

Color _iconColorForPosition(int position) {
  switch (position) {
    case 0:
      return AppColors.complementary;
    case 1:
      return AppColors.secondary;
    case 2:
      return AppColors.primary;
    default:
      return AppColors.accent;
  }
}

double _heightForPosition(int position) {
  switch (position) {
    case 0:
      return 160;
    case 1:
      return 130;
    case 2:
      return 100;
    default:
      return 100;
  }
}

BorderRadius _borderRadiusForPosition(int position) {
  switch (position) {
    case 0:
      return const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      );
    case 1:
      return const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    case 2:
      return const BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    default:
      return const BorderRadius.all(Radius.circular(8));
  }
}
