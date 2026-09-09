import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InstitutionNavShell extends StatelessWidget {
  final Widget child;

  const InstitutionNavShell({super.key, required this.child});

  static const _tabs = [
    _InstitutionTab(
      path: '/institution/browse',
      icon: Icons.manage_search_outlined,
      activeIcon: Icons.manage_search_rounded,
      label: 'Talent',
    ),
    _InstitutionTab(
      path: '/institution/marketplace',
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'Jobs',
    ),
    _InstitutionTab(
      path: '/institution/profile',
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance_rounded,
      label: 'Profile',
    ),
  ];

  static const _primary = Color(0xFFE50914);
  static const _orange = Color(0xFFFF6B00);
  static const _ink = Color(0xFF211815);
  static const _muted = Color(0xFF9B8175);
  static const _line = Color(0xFFF0D8CE);

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final currentIndex = _tabs.indexWhere((tab) => path.startsWith(tab.path));
    final activeIndex = currentIndex < 0 ? 0 : currentIndex;

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
                                  colors: [_primary, _orange],
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
                                    fontSize: 12,
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

class _InstitutionTab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _InstitutionTab({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
