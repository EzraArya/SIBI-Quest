import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sibi_quest/features/leaderboard/domain/models/leaderboard_player.dart';
import 'package:sibi_quest/features/leaderboard/presentation/providers/leaderboard_providers.dart';
import 'package:sibi_quest/features/leaderboard/presentation/widgets/podium_view.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/utils/image_url_validator.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate the provider to trigger a refresh
          ref.invalidate(leaderboardProvider);
          // Wait for the new data to load
          await ref.read(leaderboardProvider.future);
        },
        color: AppColors.primary,
        child: SafeArea(
          child: leaderboardAsync.when(
            data: (players) {
              if (players.isEmpty) {
                return const _LeaderboardEmptyState();
              }
              return _LeaderboardContent(players: players);
            },
            loading: () => const _LeaderboardLoadingSkeleton(),
            error: (error, _) => _LeaderboardError(
              onRetry: () => ref.invalidate(leaderboardProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  final List<LeaderboardPlayer> players;

  const _LeaderboardContent({required this.players});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPodium = players.length >= 3;
    final podiumPlayers = hasPodium
        ? players.sublist(0, 3)
        : const <LeaderboardPlayer>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'Leaderboard',
            type: CustomTextType.display,
            color: AppColors.text,
          ),
          const SizedBox(height: 24),
          if (hasPodium) ...[
            PodiumView(players: podiumPlayers),
            const SizedBox(height: 32),
            CustomText(
              text: 'Runners-up',
              type: CustomTextType.title,
              color: AppColors.placeholder,
            ),
            const SizedBox(height: 16),
          ],
          ...players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final hasValidAvatar = isValidNetworkImageUrl(player.imageUrl);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textbox,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 8),
                      blurRadius: 24,
                      spreadRadius: -16,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    _RankBadge(rank: index + 1),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: player.displayName,
                            type: CustomTextType.bodyBold,
                            color: AppColors.text,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            text: '${player.totalScore} pts',
                            type: CustomTextType.body,
                            color: AppColors.placeholder,
                          ),
                        ],
                      ),
                    ),
                    hasValidAvatar
                        ? ClipOval(
                            child: Image.network(
                              player.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                // Skeleton loader while image is loading
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.muted,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.muted,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: AppColors.placeholder,
                                  ),
                                );
                              },
                            ),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.muted,
                            child: const Icon(
                              Icons.person,
                              size: 20,
                              color: AppColors.placeholder,
                            ),
                          ),
                  ],
                ),
              ),
            );
          }),
          if (!hasPodium)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CustomText(
                text: 'Invite more friends to see the full leaderboard!',
                type: CustomTextType.body,
                color: theme.colorScheme.secondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaderboardLoadingSkeleton extends StatelessWidget {
  const _LeaderboardLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: _SkeletonBox(height: 220)),
              const SizedBox(width: 16),
              const Expanded(child: _SkeletonBox(height: 240)),
              const SizedBox(width: 16),
              const Expanded(child: _SkeletonBox(height: 200)),
            ],
          ),
          const SizedBox(height: 32),
          for (var i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;

  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _LeaderboardEmptyState extends StatelessWidget {
  const _LeaderboardEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: AppColors.placeholder,
            ),
            SizedBox(height: 16),
            CustomText(
              text: 'Papan peringkat masih kosong',
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            SizedBox(height: 8),
            CustomText(
              text:
                  'Mainkan beberapa level untuk mulai bersaing dengan teman-temanmu!',
              type: CustomTextType.body,
              color: AppColors.placeholder,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LeaderboardError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.placeholder),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Unable to load leaderboard',
              type: CustomTextType.title,
              color: AppColors.text,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: 'Please check your connection and try again.',
              type: CustomTextType.body,
              color: AppColors.placeholder,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ActionButton(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final color = rank <= 3 ? AppColors.accent : AppColors.muted;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: CustomText(
        text: '$rank',
        type: CustomTextType.bodyBold,
        color: AppColors.text,
      ),
    );
  }
}
