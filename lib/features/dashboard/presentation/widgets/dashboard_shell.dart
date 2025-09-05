import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sibi_quest/shared/tokens/colors.dart';

class DashboardShell extends StatefulWidget {
  final Widget child;
  final int selectedIndex;

  const DashboardShell({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard/home');
        break;
      case 1:
        context.go('/dashboard/leaderboard');
        break;
      case 2:
        context.go('/dashboard/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.placeholder,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
