import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/features/history/history_screen.dart';
import 'package:weather_cup/features/home/home_screen.dart';
import 'package:weather_cup/features/home/navigation_provider.dart';
import 'package:weather_cup/features/profile_setup/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: const [
              HomeScreen(),
              HistoryScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) {
              navigationProvider.setIndex(index);
            },
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: NavItemIcon(icon: CupertinoIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: NavItemIcon(icon: CupertinoIcons.chart_bar),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: NavItemIcon(icon: CupertinoIcons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class NavItemIcon extends StatelessWidget {
  final IconData icon;

  const NavItemIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        Icon(icon),
        const SizedBox(height: 4),
      ],
    );
  }
}

