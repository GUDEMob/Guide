// lib/shared/widgets/bottom_nav_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'walkthrough_overlay.dart';

class BottomNavShell extends StatelessWidget {
  final Widget child;
  const BottomNavShell({super.key, required this.child});

  static const _tabs = [
    _Tab('/home', Icons.home_outlined, Icons.home_rounded, 'Home'),
    _Tab('/marketplace', Icons.storefront_outlined, Icons.storefront_rounded,
        'Market'),
    _Tab('/wallet', Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded, 'Wallet'),
    _Tab('/stability', Icons.favorite_outline, Icons.favorite_rounded,
        'Support Hub'),
  ];

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final idx = _tabs.indexWhere((t) => loc.startsWith(t.path));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex(context);
    return Scaffold(
      body: WalkthroughOverlay(child: child),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 62,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final sel = i == active;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go(tab.path),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                            horizontal: sel ? 14 : 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFFFFE8EB)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          sel ? tab.activeIcon : tab.icon,
                          size: 21,
                          color: sel
                              ? const Color(0xFFE30613)
                              : const Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel
                              ? const Color(0xFFE30613)
                              : const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String path, label;
  final IconData icon, activeIcon;
  const _Tab(this.path, this.icon, this.activeIcon, this.label);
}
