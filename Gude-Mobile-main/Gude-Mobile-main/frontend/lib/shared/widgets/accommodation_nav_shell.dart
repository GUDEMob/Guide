import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccommodationNavShell extends StatelessWidget {
  final Widget child;

  const AccommodationNavShell({super.key, required this.child});

  static const _tabs = [
    _Tab('/accommodation/overview', Icons.dashboard_outlined,
        Icons.dashboard_rounded, 'Overview'),
    _Tab('/accommodation/community', Icons.campaign_outlined,
        Icons.campaign_rounded, 'Community'),
    _Tab('/accommodation/opportunities', Icons.work_outline_rounded,
        Icons.work_rounded, 'Jobs'),
    _Tab('/accommodation/profile', Icons.apartment_outlined,
        Icons.apartment_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _tabs.indexWhere((tab) => path.startsWith(tab.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        indicatorColor: const Color(0xFFFFE3DF),
        backgroundColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon:
                  Icon(tab.activeIcon, color: const Color(0xFFE30613)),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _Tab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _Tab(this.path, this.icon, this.activeIcon, this.label);
}
