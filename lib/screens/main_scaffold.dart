import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_routes.dart';
import '../core/firebase_service.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Widget? fab;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex.clamp(0, 3);

    return Scaffold(
      backgroundColor: AppColors.surface2,
      body: SafeArea(child: child),
      floatingActionButton: fab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.gdgBlue,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w500),
        elevation: 8,
        onTap: (index) {
          // Guard: redirect to login if not authenticated
          if (FirebaseService.currentUser == null) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (_) => false);
            return;
          }

          final routes = [
            AppRoutes.dashboard,
            AppRoutes.meetings,
            AppRoutes.events,
            AppRoutes.profile,
          ];
          if (index != currentIndex) {
            Navigator.pushNamedAndRemoveUntil(
                context, routes[index], (route) => route.isFirst);
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: safeIndex == 2
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: AppColors.gdgBlueLight,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.star,
                        color: AppColors.gdgBlue, size: 18),
                  )
                : const Icon(Icons.star_border),
            activeIcon: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: AppColors.gdgBlueLight,
                  shape: BoxShape.circle),
              child: const Icon(Icons.star,
                  color: AppColors.gdgBlue, size: 18),
            ),
            label: 'Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}