import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PshaNavShell extends StatelessWidget {
  final Widget child;

  const PshaNavShell({super.key, required this.child});

  static const _tabs = [
    _PshaTab('/psha/overview', Icons.dashboard_outlined,
        Icons.dashboard_rounded, 'Overview'),
    _PshaTab('/psha/members', Icons.apartment_outlined, Icons.apartment_rounded,
        'Members'),
    _PshaTab('/psha/impact', Icons.insights_outlined, Icons.insights_rounded,
        'Impact'),
    _PshaTab('/psha/profile', Icons.admin_panel_settings_outlined,
        Icons.admin_panel_settings_rounded, 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = _tabs.indexWhere((tab) => path.startsWith(tab.path));
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: selected < 0 ? 0 : selected,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFE3DF),
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

class _PshaTab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _PshaTab(this.path, this.icon, this.activeIcon, this.label);
}
