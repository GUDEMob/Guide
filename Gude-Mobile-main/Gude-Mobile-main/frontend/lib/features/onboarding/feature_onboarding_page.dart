import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Slide {
  final String emoji, title, description;
  final List<Color> gradient;
  const _Slide({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

const _slides = [
  _Slide(
    emoji: '🤖',
    title: 'AI Buddy',
    description:
        'Your personal financial mentor. Get real-time advice on budgeting, investing, and student life hacks.',
    gradient: [Color(0xFFE30613), Color(0xFF8B000A)],
  ),
  _Slide(
    emoji: '🛍️',
    title: 'Marketplace',
    description:
        'Buy or list services. From tutoring to tech help, find everything you need from fellow students.',
    gradient: [Color(0xFFD0000C), Color(0xFF7A0008)],
  ),
  _Slide(
    emoji: '🆘',
    title: 'Support Hub',
    description:
        'Access to our support network for academic, financial, and mental health guidance.',
    gradient: [Color(0xFFBF0010), Color(0xFF6B0007)],
  ),
  _Slide(
    emoji: '💸',
    title: 'Spend & Earn',
    description:
        'Track every cent and unlock opportunities to earn directly through the platform.',
    gradient: [Color(0xFFE30613), Color(0xFF950010)],
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
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
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
      backgroundColor: Colors.white,
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
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFE30613)
                            : const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Next / Get Started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30613),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: const Color(0xFFE30613).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _next,
                    child: Text(
                      _current == _slides.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Skip
                if (_current < _slides.length - 1)
                  GestureDetector(
                    onTap: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w500),
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

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero gradient card
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child:
                        Text(slide.emoji, style: const TextStyle(fontSize: 60)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Text content
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 36, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
