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

  static const _primary = Color(0xFF16875D);
  static const _secondary = Color(0xFF3F63D9);
  static const _ink = Color(0xFF211815);
  static const _muted = Color(0xFF80665C);
  static const _line = Color(0xFFF0D8CE);

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _tabs.indexWhere((tab) => path.startsWith(tab.path));
    final activeIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _line)),
          boxShadow: [
            BoxShadow(
              color: _ink.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final selected = index == activeIndex;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.go(tab.path),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected ? null : Colors.transparent,
                          gradient: selected
                              ? const LinearGradient(
                                  colors: [_primary, _secondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selected ? tab.activeIcon : tab.icon,
                              color: selected ? Colors.white : _muted,
                              size: 21,
                            ),
                            if (selected) ...[
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  tab.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
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
