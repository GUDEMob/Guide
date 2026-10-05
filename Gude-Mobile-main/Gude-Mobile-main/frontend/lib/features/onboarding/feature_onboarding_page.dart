import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Slide {
  final IconData icon;
  final IconData supportIcon;
  final String eyebrow, title, description;
  final List<String> chips;
  final List<Color> gradient;
  final Color accent;
  final Color softAccent;

  const _Slide({
    required this.icon,
    required this.supportIcon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.chips,
    required this.gradient,
    required this.accent,
    required this.softAccent,
  });
}

const _slides = [
  _Slide(
    icon: Icons.auto_awesome_rounded,
    supportIcon: Icons.chat_bubble_rounded,
    eyebrow: 'Smart guidance',
    title: 'AI Buddy',
    description:
        'Get quick money advice, budget nudges, and student-life tips when you need them.',
    chips: ['Budget help', 'Money tips', 'Fast answers'],
    gradient: [Color(0xFFE30613), Color(0xFFB00012)],
    accent: Color(0xFFFFB000),
    softAccent: Color(0xFFFFE7B0),
  ),
  _Slide(
    icon: Icons.shopping_bag_rounded,
    supportIcon: Icons.storefront_rounded,
    eyebrow: 'Student deals',
    title: 'Marketplace',
    description:
        'Buy products, book services, or list your own skills for other students to discover.',
    chips: ['Products', 'Services', 'Student sellers'],
    gradient: [Color(0xFFE30613), Color(0xFFC2185B)],
    accent: Color(0xFF2F6BFF),
    softAccent: Color(0xFFDDE8FF),
  ),
  _Slide(
    icon: Icons.volunteer_activism_rounded,
    supportIcon: Icons.health_and_safety_rounded,
    eyebrow: 'Real support',
    title: 'Support Hub',
    description:
        'Find academic, financial, and wellbeing resources from people who can actually help.',
    chips: ['Guidance', 'Emergency help', 'Campus links'],
    gradient: [Color(0xFFE30613), Color(0xFFFF7A1A)],
    accent: Color(0xFF16A085),
    softAccent: Color(0xFFDDF8EF),
  ),
  _Slide(
    icon: Icons.payments_rounded,
    supportIcon: Icons.trending_up_rounded,
    eyebrow: 'Money moves',
    title: 'Spend & Earn',
    description:
        'Track your wallet, spot better habits, and unlock earning opportunities in one place.',
    chips: ['Wallet', 'Rewards', 'Earn more'],
    gradient: [Color(0xFFE30613), Color(0xFF8B000A)],
    accent: Color(0xFFFFC400),
    softAccent: Color(0xFFFFF1B8),
  ),
];

class FeatureOnboardingPage extends StatefulWidget {
  const FeatureOnboardingPage({super.key});

  @override
  State<FeatureOnboardingPage> createState() => _FeatureOnboardingPageState();
}

class _FeatureOnboardingPageState extends State<FeatureOnboardingPage> {
  final _pageCtrl = PageController();
  int _current = 0;

  void _next() {
    if (_current < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/signup');
    }
  }

  void _skip() => context.go('/signup');

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 34),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFE30613)
                            : const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 26),
                _PrimaryActionButton(
                  label:
                      _current == _slides.length - 1 ? 'Get Started' : 'Next',
                  onPressed: _next,
                ),
                const SizedBox(height: 12),
                if (_current < _slides.length - 1)
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8A8A8A),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 57,
          child: _FeatureHero(slide: slide),
        ),
        Expanded(
          flex: 43,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 14),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: slide.softAccent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    slide.eyebrow,
                    style: TextStyle(
                      color: slide.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    height: 1.04,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.48,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final chip in slide.chips)
                      _InfoChip(
                        label: chip,
                        color: slide.accent,
                        background: slide.softAccent,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureHero extends StatelessWidget {
  final _Slide slide;

  const _FeatureHero({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 64,
            right: -56,
            child: Transform.rotate(
              angle: -0.32,
              child: Container(
                width: 190,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
          Positioned(
            left: -34,
            bottom: 58,
            child: Transform.rotate(
              angle: 0.42,
              child: Container(
                width: 142,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 280,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 16,
                    right: 6,
                    child: _MiniTile(
                      icon: slide.supportIcon,
                      color: slide.accent,
                      background: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 6,
                    child: _MiniTile(
                      icon: Icons.check_rounded,
                      color: const Color(0xFFE30613),
                      background: slide.softAccent,
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 22,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Icon(
                          slide.icon,
                          color: const Color(0xFFE30613),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 38,
            right: 38,
            bottom: 32,
            child: const _HeroDecorRail(),
          ),
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _MiniTile({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _HeroDecorRail extends StatelessWidget {
  const _HeroDecorRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _InfoChip({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE30613), Color(0xFFFF7A1A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE30613).withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
