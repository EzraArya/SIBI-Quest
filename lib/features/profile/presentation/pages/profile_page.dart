import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/auth/auth_router.dart';
import 'package:sibi_quest/features/auth/domain/auth_failure.dart';
import 'package:sibi_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:sibi_quest/features/profile/profile_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';
import 'package:sibi_quest/shared/widgets/action_button.dart';
import 'package:sibi_quest/shared/widgets/app_alert.dart';
import 'package:sibi_quest/shared/widgets/app_system_icon.dart';
import 'package:sibi_quest/shared/widgets/custom_text.dart';
import 'package:sibi_quest/shared/widgets/image_text_box.dart';
import 'package:sibi_quest/cores/models/user.dart' as core;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = false;
  bool _showDeleteAlert = false;

  @override
  void initState() {
    super.initState();
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is AuthFailure
              ? error.message
              : 'Authentication action failed. Please try again.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });
  }

  final List<_OverviewItem> _overviewItems = const [
    _OverviewItem(
      icon: Icons.stacked_bar_chart_rounded,
      value: '24',
      label: 'Lessons Completed',
    ),
    _OverviewItem(
      icon: Icons.emoji_events_rounded,
      value: '12',
      label: 'Badges Earned',
    ),
    _OverviewItem(
      icon: Icons.schedule_rounded,
      value: '48h',
      label: 'Practice Time',
    ),
    _OverviewItem(
      icon: Icons.favorite_rounded,
      value: 'Top 5%',
      label: 'Leaderboard',
    ),
  ];

  void _navigateToEditProfile() {
    context.pushNamed(ProfileRoutes.editProfileName);
  }

  void _navigateToEditProfilePicture() {
    context.pushNamed(ProfileRoutes.editProfilePictureName);
  }

  void _handleLogout() {
    ref.read(authControllerProvider.notifier).signOut();
  }

  void _handleDeleteAccount() {
    setState(() {
      _showDeleteAlert = true;
    });
  }

  void _confirmDeleteAccount() {
    setState(() {
      _showDeleteAlert = false;
    });

    context.pushNamed(AuthRoutes.loginName);
  }

  void _dismissAlert() {
    setState(() {
      _showDeleteAlert = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final core.User? user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    final bool isAuthProcessing = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.textbox,
              onRefresh: () async {
                setState(() {
                  _isLoading = true;
                });
                await Future<void>.delayed(const Duration(milliseconds: 600));
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, user),
                    const SizedBox(height: 24),
                    _buildOverviewSection(),
                    const SizedBox(height: 24),
                    _buildActionsSection(isAuthProcessing),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (_showDeleteAlert) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: _dismissAlert,
                  child: Container(color: Colors.black.withValues(alpha: 0.65)),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: AnimatedScale(
                    scale: _showDeleteAlert ? 1 : 0.9,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AppAlert(
                        title: 'Delete Account',
                        message:
                            'Are you sure you want to delete your account? This action cannot be undone.',
                        primaryButtonLabel: 'Delete',
                        secondaryButtonLabel: 'Cancel',
                        onPrimaryPressed: _confirmDeleteAccount,
                        onSecondaryPressed: _dismissAlert,
                        primaryButtonType: ButtonType.danger,
                        secondaryButtonType: ButtonType.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, core.User? user) {
    final profileImageUrl = user?.image;
    final displayName = (() {
      if (user == null) {
        return 'Explorer';
      }
      final name = user.fullName.trim();
      return name.isEmpty ? 'Explorer' : name;
    })();

    final emailText = (user?.email ?? '').isEmpty
        ? 'No email linked yet'
        : user!.email;
    final joinDateText = user?.createdAt != null
        ? 'Joined ${_formatJoinDate(user!.createdAt!)}'
        : null;
    final subtitle = joinDateText != null
        ? '$emailText • $joinDateText'
        : emailText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _navigateToEditProfilePicture,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.muted,
                child: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _fallbackHeaderImage(),
                      )
                    : _fallbackHeaderImage(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomText(
            text: displayName,
            type: CustomTextType.title,
            color: AppColors.text,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: subtitle,
            type: CustomTextType.body,
            color: AppColors.placeholder,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: 'Edit Profile',
              onPressed: _navigateToEditProfile,
              type: ButtonType.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Overview',
            type: CustomTextType.bodyBold,
            color: AppColors.text,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _overviewItems
                .map((item) => _OverviewCard(item: item))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(bool isAuthProcessing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: 'Logout',
              onPressed: _handleLogout,
              type: ButtonType.secondary,
              isLoading: isAuthProcessing,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: 'Delete Account',
              onPressed: _handleDeleteAccount,
              type: ButtonType.danger,
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthIndex = date.month - 1;
    final monthName =
        monthNames[(monthIndex < 0 || monthIndex > 11) ? 0 : monthIndex];
    return '$monthName ${date.year}';
  }

  Widget _fallbackHeaderImage() {
    return Container(
      color: AppColors.muted,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 72,
          color: AppColors.placeholder,
        ),
      ),
    );
  }
}

class _OverviewItem {
  final IconData icon;
  final String value;
  final String label;

  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class _OverviewCard extends StatelessWidget {
  final _OverviewItem item;

  const _OverviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64, maxWidth: 168),
      child: ImageTextBox(
        icon: AppSystemIcon(
          icon: item.icon,
          width: 24,
          height: 24,
          color: AppColors.accent,
        ),
        title: item.value,
        description: item.label,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        spacing: 12,
        borderColor: AppColors.line.withValues(alpha: 0.5),
        borderRadius: 16,
        borderWidth: 1.5,
        backgroundColor: AppColors.textbox,
        titleColor: AppColors.text,
        descriptionColor: AppColors.placeholder,
        titleType: CustomTextType.bodyBold,
        descriptionType: CustomTextType.body,
        descriptionMaxLines: 3,
      ),
    );
  }
}
