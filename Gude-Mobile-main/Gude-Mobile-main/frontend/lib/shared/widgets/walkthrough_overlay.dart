// lib/shared/widgets/walkthrough_overlay.dart
//
// Usage — in bottom_nav_shell.dart, wrap `child` with WalkthroughOverlay:
//
//   body: WalkthroughOverlay(child: child),
//
// That's it. The overlay auto-detects the current route and shows the right
// steps. It only shows once (persisted via a simple in-memory flag — swap for
// SharedPreferences in production).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────
//  Singleton state — tracks whether the user has seen each page tour
// ─────────────────────────────────────────────────────────────
class _WalkthroughState {
  static final _WalkthroughState _i = _WalkthroughState._();
  factory _WalkthroughState() => _i;
  _WalkthroughState._();

  // Swap these bools for SharedPreferences in production
  bool homeDone = false;
  bool marketDone = false;
  bool walletDone = false;
  bool supportDone = false;

  bool isDone(String route) {
    if (route.startsWith('/home')) return homeDone;
    if (route.startsWith('/marketplace')) return marketDone;
    if (route.startsWith('/wallet')) return walletDone;
    if (route.startsWith('/stability')) return supportDone;
    return true;
  }

  void markDone(String route) {
    if (route.startsWith('/home')) homeDone = true;
    if (route.startsWith('/marketplace')) marketDone = true;
    if (route.startsWith('/wallet')) walletDone = true;
    if (route.startsWith('/stability')) supportDone = true;
  }
}

// ─────────────────────────────────────────────────────────────
//  Step model
// ─────────────────────────────────────────────────────────────
class _Step {
  final String title;
  final String body;
  final IconData icon;
  final Color color;

  /// Where on screen the spotlight should point.
  /// null = no spotlight (full-screen modal style).
  /// Alignment values: x/y range -1.0 → 1.0 relative to screen centre.
  final Alignment? spotAlignment;

  const _Step({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    this.spotAlignment,
  });
}

// ─────────────────────────────────────────────────────────────
//  Per-page step definitions
// ─────────────────────────────────────────────────────────────
const _homeSteps = [
  _Step(
    title: 'Welcome to Gude 👋',
    body:
        'Gude helps you manage your money, track your wellbeing, and thrive as a student. This quick tour shows you what\'s on each screen.',
    icon: Icons.waving_hand_rounded,
    color: Color(0xFFE30613),
  ),
  _Step(
    title: 'Your Account Balance',
    body:
        'Your monthly income (e.g. NSFAS or bursary) shows here. Tap the eye icon to hide or reveal the amount. Tap the card to go straight to your Wallet.',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF1A1A1A),
    spotAlignment: Alignment(0, -0.55),
  ),
  _Step(
    title: 'Quick Actions',
    body:
        'Pin shortcuts to things you use most — log an expense, check your budget, open the AI coach, and more. Tap "Customise" to choose your favourites.',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF3B82F6),
    spotAlignment: Alignment(0, 0.0),
  ),
  _Step(
    title: 'AI Money Coach 🤖',
    body:
        'Tap the robot button (bottom-right) to chat with your personal AI coach. Ask it anything — budget advice, savings tips, or help surviving month-end.',
    icon: Icons.smart_toy_outlined,
    color: Color(0xFF8B5CF6),
    spotAlignment: Alignment(0.88, 0.82),
  ),
  _Step(
    title: 'Tips & Challenges',
    body:
        'Scroll down to find personalised financial challenges. Complete them to build better money habits and earn rewards.',
    icon: Icons.emoji_events_outlined,
    color: Color(0xFFF59E0B),
    spotAlignment: Alignment(0, 0.55),
  ),
];

const _marketSteps = [
  _Step(
    title: 'Student Marketplace 🛒',
    body:
        'Buy and sell products or offer your skills as services — all within the student community. Great prices, zero middleman.',
    icon: Icons.storefront_outlined,
    color: Color(0xFFE30613),
  ),
  _Step(
    title: 'Search & Filter',
    body:
        'Use the search bar to find specific items, or tap a category chip (Electronics, Service, Stationery) to browse by type.',
    icon: Icons.search_rounded,
    color: Color(0xFF1A1A1A),
    spotAlignment: Alignment(0, -0.35),
  ),
  _Step(
    title: 'List Your Own',
    body:
        'Tap "List a Product" to sell physical items, or "List a Service" to offer your skills (tutoring, design, photography) and earn extra income.',
    icon: Icons.add_box_outlined,
    color: Color(0xFF3B82F6),
    spotAlignment: Alignment(0, -0.55),
  ),
  _Step(
    title: 'Wishlist & Cart',
    body:
        'Tap the ♡ on any item to save it to your wishlist. Add items to your cart and checkout when ready — multiple payment methods supported.',
    icon: Icons.favorite_border_rounded,
    color: Color(0xFFE30613),
    spotAlignment: Alignment(0.88, -0.88),
  ),
  _Step(
    title: 'Chat with Sellers',
    body:
        'Open any listing and tap the chat bubble to message the seller directly. Negotiate, ask questions, or arrange delivery — all in-app.',
    icon: Icons.chat_bubble_outline_rounded,
    color: Color(0xFF10B981),
  ),
];

const _walletSteps = [
  _Step(
    title: 'Your Wallet 💳',
    body:
        'Your Gude Wallet is the heart of your finances. Swipe through the cards to switch between your main account and any pockets you\'ve created.',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFFE30613),
  ),
  _Step(
    title: 'Main Account Card',
    body:
        'Your primary account holds your monthly income. The card shows your current balance, total income received, and total spent this period.',
    icon: Icons.credit_card_outlined,
    color: Color(0xFF1A1A1A),
    spotAlignment: Alignment(0, -0.65),
  ),
  _Step(
    title: 'Create Pockets',
    body:
        'Tap the + icon in the top bar to create a pocket — a sub-wallet for a specific purpose like transport, food, or rent. Allocate money from your main account.',
    icon: Icons.add_card_rounded,
    color: Color(0xFF3B82F6),
    spotAlignment: Alignment(0.88, -0.88),
  ),
  _Step(
    title: 'Budget, Goals & Transfers',
    body:
        'The three quick-action buttons let you set spending budgets, track savings goals, or move money between pockets — all in a few taps.',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFF10B981),
    spotAlignment: Alignment(0, -0.12),
  ),
  _Step(
    title: 'Financial Health Score',
    body:
        'Scroll to the bottom to see your Financial Health score. It tracks how much of your balance you\'ve used and warns you when spending gets risky.',
    icon: Icons.monitor_heart_outlined,
    color: Color(0xFFF59E0B),
    spotAlignment: Alignment(0, 0.72),
  ),
];

const _supportSteps = [
  _Step(
    title: 'Your Support Hub 💙',
    body:
        'This page tracks your overall student stability — financial, academic, and emotional. Everything here is private and designed to help, not judge.',
    icon: Icons.favorite_outline,
    color: Color(0xFFE30613),
  ),
  _Step(
    title: 'Support Resources',
    body:
        'Six cards link to real support: quick income gigs, budget help, food banks, peer tutoring, counselling, and mentorship. Tap any card for full details.',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF3B82F6),
    spotAlignment: Alignment(0, -0.48),
  ),
  _Step(
    title: 'Stability Score',
    body:
        'Your score (0–100) is calculated from four signals: financial health, marketplace activity, app engagement, and wellbeing check-ins. Tap the info icon to learn more.',
    icon: Icons.bar_chart_rounded,
    color: Color(0xFF10B981),
    spotAlignment: Alignment(0, 0.25),
  ),
  _Step(
    title: 'Weekly Check-in',
    body:
        'Tap the "Weekly Check-in" button to answer 6 quick questions about your finances, studies, and mood. Your Stability Score updates after each check-in.',
    icon: Icons.checklist_rtl_rounded,
    color: Color(0xFFF59E0B),
    spotAlignment: Alignment(0.55, 0.82),
  ),
];

List<_Step> _stepsForRoute(String route) {
  if (route.startsWith('/home')) return _homeSteps;
  if (route.startsWith('/marketplace')) return _marketSteps;
  if (route.startsWith('/wallet')) return _walletSteps;
  if (route.startsWith('/stability')) return _supportSteps;
  return [];
}

// ─────────────────────────────────────────────────────────────
//  WalkthroughOverlay
//  Wrap the `child` inside BottomNavShell's body with this widget.
// ─────────────────────────────────────────────────────────────
class WalkthroughOverlay extends StatefulWidget {
  final Widget child;
  const WalkthroughOverlay({super.key, required this.child});

  @override
  State<WalkthroughOverlay> createState() => _WalkthroughOverlayState();
}

class _WalkthroughOverlayState extends State<WalkthroughOverlay>
    with SingleTickerProviderStateMixin {
  final _state = _WalkthroughState();
  List<_Step> _steps = [];
  int _currentStep = 0;
  bool _active = false;
  String _activeRoute = '';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkRoute();
  }

  void _checkRoute() {
    final loc = GoRouterState.of(context).uri.path;
    if (loc == _activeRoute) return;
    _activeRoute = loc;

    if (!_state.isDone(loc)) {
      final steps = _stepsForRoute(loc);
      if (steps.isNotEmpty) {
        // Delay so the page renders before the overlay appears
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _steps = steps;
            _currentStep = 0;
            _active = true;
          });
          _animCtrl.forward(from: 0);
        });
      }
    }
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      _animCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _currentStep++);
        _animCtrl.forward(from: 0);
      });
    } else {
      _dismiss();
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      _animCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _currentStep--);
        _animCtrl.forward(from: 0);
      });
    }
  }

  void _dismiss() {
    _animCtrl.reverse().then((_) {
      if (!mounted) return;
      _state.markDone(_activeRoute);
      setState(() => _active = false);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_active && _steps.isNotEmpty) _buildOverlay(context),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final step = _steps[_currentStep];
    final size = MediaQuery.of(context).size;

    final hasSpot = step.spotAlignment != null;
    final spotX = hasSpot
        ? (size.width / 2) + (step.spotAlignment!.x * size.width / 2)
        : size.width / 2;
    final spotY = hasSpot
        ? (size.height / 2) + (step.spotAlignment!.y * size.height / 2)
        : size.height / 2;

    return GestureDetector(
      onTap: _next, // tap backdrop to advance
      child: AnimatedBuilder(
        animation: _animCtrl,
        builder: (_, __) => Opacity(
          opacity: _fadeAnim.value,
          child: Stack(
            children: [
              // ── Scrim with spotlight cutout ──────────────
              CustomPaint(
                size: Size(size.width, size.height),
                painter: _ScrimPainter(
                  spotX: spotX,
                  spotY: spotY,
                  spotRadius: hasSpot ? 78.0 : 0.0,
                ),
              ),

              // ── Card ─────────────────────────────────────
              Positioned(
                bottom: 96,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {}, // absorb so backdrop tap doesn't double-fire
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: _WalkthroughCard(
                      step: step,
                      currentIndex: _currentStep,
                      total: _steps.length,
                      isLast: _currentStep == _steps.length - 1,
                      showPrev: _currentStep > 0,
                      onNext: _next,
                      onPrev: _prev,
                      onSkip: _dismiss,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Scrim painter — dark overlay with circular spotlight cutout
// ─────────────────────────────────────────────────────────────
class _ScrimPainter extends CustomPainter {
  final double spotX, spotY, spotRadius;
  const _ScrimPainter(
      {required this.spotX, required this.spotY, required this.spotRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xCC0D0D0D);

    if (spotRadius > 0) {
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(Rect.fromCircle(
            center: Offset(spotX, spotY), radius: spotRadius + 14))
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, paint);

      // Glowing ring around spotlight
      canvas.drawCircle(
        Offset(spotX, spotY),
        spotRadius + 14,
        Paint()
          ..color = Colors.white.withOpacity(0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.spotX != spotX || old.spotY != spotY || old.spotRadius != spotRadius;
}

// ─────────────────────────────────────────────────────────────
//  Walkthrough card
// ─────────────────────────────────────────────────────────────
class _WalkthroughCard extends StatelessWidget {
  final _Step step;
  final int currentIndex, total;
  final bool isLast, showPrev;
  final VoidCallback onNext, onPrev, onSkip;

  const _WalkthroughCard({
    required this.step,
    required this.currentIndex,
    required this.total,
    required this.isLast,
    required this.showPrev,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Coloured header ────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: step.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(step.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSkip,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ]),
          ),

          // ── Description ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Text(
              step.body,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF444444),
                height: 1.55,
              ),
            ),
          ),

          // ── Step counter + navigation ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Row(
              children: [
                // Progress dots
                Row(
                  children: List.generate(total, (i) {
                    final active = i == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(right: 5),
                      width: active ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? step.color : const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const Spacer(),

                // Back button
                if (showPrev)
                  GestureDetector(
                    onTap: onPrev,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 15, color: Color(0xFF888888)),
                    ),
                  ),

                // Next / Done button
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: step.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isLast ? 'Done 🎉' : 'Next →',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
