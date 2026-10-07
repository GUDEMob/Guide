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

  static const _primary = Color(0xFF0F8A5F);
  static const _secondary = Color(0xFF168C84);
  static const _ink = Color(0xFF19241F);
  static const _muted = Color(0xFF63746B);
  static const _line = Color(0xFFD7E8DF);

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = _tabs.indexWhere((tab) => path.startsWith(tab.path));
    final activeIndex = selected < 0 ? 0 : selected;
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
                final isSelected = index == activeIndex;
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
                          color: isSelected ? null : Colors.transparent,
                          gradient: isSelected
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
                              isSelected ? tab.activeIcon : tab.icon,
                              color: isSelected ? Colors.white : _muted,
                              size: 21,
                            ),
                            if (isSelected) ...[
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

class _PshaTab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _PshaTab(this.path, this.icon, this.activeIcon, this.label);
}
