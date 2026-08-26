import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
// SHARED THEME COLORS
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const primaryDark = Color(0xFFB0000E);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFE8E8E8);
}

// ─────────────────────────────────────────────
// BUYER ONBOARDING WELCOME PAGE
// Route: /buyer-onboarding/welcome
// ─────────────────────────────────────────────
class BuyerOnboardingWelcomePage extends StatefulWidget {
  const BuyerOnboardingWelcomePage({super.key});

  @override
  State<BuyerOnboardingWelcomePage> createState() =>
      _BuyerOnboardingWelcomePageState();
}

class _BuyerOnboardingWelcomePageState extends State<BuyerOnboardingWelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Red hero ──────────────────────────────────
          _RedHero(
            title: 'Welcome to Gude',
            subtitle:
                'You\'re one step away from\nunlocking the key to a better\nstudent life.',
            showBack: false,
          ),

          // ── Content ───────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'As a buyer you can:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _C.dark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FeatureTile(
                        icon: Icons.search_rounded,
                        color: _C.primary,
                        title: 'Discover Student Talent',
                        subtitle:
                            'Browse verified students offering tutoring, design, coding, and more.',
                      ),
                      const SizedBox(height: 14),
                      _FeatureTile(
                        icon: Icons.handshake_rounded,
                        color: const Color(0xFF2563EB),
                        title: 'Hire & Pay Securely',
                        subtitle:
                            'Post jobs, hire students, and pay safely through the Gude Wallet.',
                      ),
                      const SizedBox(height: 14),
                      _FeatureTile(
                        icon: Icons.star_rounded,
                        color: const Color(0xFFF59E0B),
                        title: 'Build Lasting Relationships',
                        subtitle:
                            'Rate students, leave reviews, and find your go-to service providers.',
                      ),
                      const SizedBox(height: 14),
                      _FeatureTile(
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFF10B981),
                        title: 'Support Student Success',
                        subtitle:
                            'Every hire directly funds a student\'s education and stability.',
                      ),
                      const SizedBox(height: 36),

                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                            shadowColor: _C.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => context.go('/buyer-onboarding/type'),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(
                                color: _C.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER TYPE SELECTION PAGE
// Route: /buyer-onboarding/type
// ─────────────────────────────────────────────
class BuyerTypePage extends StatefulWidget {
  const BuyerTypePage({super.key});

  @override
  State<BuyerTypePage> createState() => _BuyerTypePageState();
}

class _BuyerTypePageState extends State<BuyerTypePage>
    with SingleTickerProviderStateMixin {
  String? _selected;
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _types = [
    {
      'key': 'business',
      'emoji': '🏢',
      'label': 'Business',
      'sub': 'Hire student talent for your company projects and campaigns.',
    },
    {
      'key': 'parent',
      'emoji': '👨‍👩‍👧',
      'label': 'Parent / Guardian',
      'sub': 'Find tutors and academic support for your child.',
    },
    {
      'key': 'ngo',
      'emoji': '🌍',
      'label': 'NGO / Non-profit',
      'sub': 'Partner with students for community-impact projects.',
    },
    {
      'key': 'student',
      'emoji': '🎓',
      'label': 'Student (Buyer)',
      'sub': 'Hire fellow students for tutoring, editing, and more.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _RedHero(
            title: 'Who are you?',
            subtitle:
                'Tell us how you\'ll be using\nGude so we can personalise\nyour experience.',
            showBack: true,
            onBack: () => context.go('/buyer-onboarding/welcome'),
            step: 1,
            totalSteps: 3,
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select your buyer type',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _C.dark,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This helps us show you the most relevant students.',
                      style: TextStyle(fontSize: 13, color: _C.grey),
                    ),
                    const SizedBox(height: 20),
                    ...(_types.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TypeCard(
                            emoji: t['emoji']!,
                            label: t['label']!,
                            sub: t['sub']!,
                            selected: _selected == t['key'],
                            onTap: () => setState(() => _selected = t['key']),
                          ),
                        ))),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selected == null
                              ? const Color(0xFFDDDDDD)
                              : _C.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: _selected == null ? 0 : 4,
                          shadowColor: _C.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _selected == null
                            ? null
                            : () => context.go('/buyer-onboarding/interests',
                                extra: {'buyerType': _selected}),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selected == null
                                  ? 'Select a type to continue'
                                  : 'Continue',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2),
                            ),
                            if (_selected != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER INTERESTS PAGE
// Route: /buyer-onboarding/interests
// ─────────────────────────────────────────────
class BuyerInterestsPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const BuyerInterestsPage({super.key, this.extra});

  @override
  State<BuyerInterestsPage> createState() => _BuyerInterestsPageState();
}

class _BuyerInterestsPageState extends State<BuyerInterestsPage>
    with SingleTickerProviderStateMixin {
  final Set<String> _selected = {};
  late AnimationController _ctrl;
  late Animation<double> _fade;

  static const _categories = [
    {'key': 'tutoring', 'emoji': '📚', 'label': 'Tutoring'},
    {'key': 'design', 'emoji': '🎨', 'label': 'Graphic Design'},
    {'key': 'coding', 'emoji': '💻', 'label': 'Coding & Dev'},
    {'key': 'writing', 'emoji': '✍️', 'label': 'Writing & Editing'},
    {'key': 'photography', 'emoji': '📷', 'label': 'Photography'},
    {'key': 'marketing', 'emoji': '📣', 'label': 'Marketing'},
    {'key': 'translation', 'emoji': '🌐', 'label': 'Translation'},
    {'key': 'admin', 'emoji': '📋', 'label': 'Admin & Office'},
    {'key': 'delivery', 'emoji': '🚚', 'label': 'Delivery & Errands'},
    {'key': 'events', 'emoji': '🎉', 'label': 'Events & Catering'},
    {'key': 'accounting', 'emoji': '📊', 'label': 'Accounting'},
    {'key': 'internship', 'emoji': '🏆', 'label': 'Micro Internships'},
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _RedHero(
            title: 'What do you need?',
            subtitle:
                'Select the services you\'re\ninterested in hiring students\nfor.',
            showBack: true,
            onBack: () => context.go('/buyer-onboarding/type'),
            step: 2,
            totalSteps: 3,
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pick your interests',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _C.dark,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selected.isEmpty
                          ? 'Select at least one category'
                          : '${_selected.length} selected',
                      style: TextStyle(
                        fontSize: 13,
                        color: _selected.isEmpty ? _C.grey : _C.primary,
                        fontWeight: _selected.isEmpty
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories
                          .map((c) => _InterestChip(
                                emoji: c['emoji']!,
                                label: c['label']!,
                                selected: _selected.contains(c['key']),
                                onTap: () => setState(() {
                                  if (_selected.contains(c['key'])) {
                                    _selected.remove(c['key']);
                                  } else {
                                    _selected.add(c['key']!);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canContinue
                              ? _C.primary
                              : const Color(0xFFDDDDDD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: canContinue ? 4 : 0,
                          shadowColor: _C.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: canContinue
                            ? () =>
                                context.go('/buyer-onboarding/profile', extra: {
                                  ...?widget.extra,
                                  'interests': _selected.toList(),
                                })
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              canContinue ? 'Continue' : 'Select at least one',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2),
                            ),
                            if (canContinue) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER PROFILE SETUP PAGE
// Route: /buyer-onboarding/profile
// ─────────────────────────────────────────────
class BuyerProfileSetupPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const BuyerProfileSetupPage({super.key, this.extra});

  @override
  State<BuyerProfileSetupPage> createState() => _BuyerProfileSetupPageState();
}

class _BuyerProfileSetupPageState extends State<BuyerProfileSetupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _companyName = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  bool _loading = false;

  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _displayName.dispose();
    _companyName.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  bool get _isBusiness =>
      widget.extra?['buyerType'] == 'business' ||
      widget.extra?['buyerType'] == 'ngo';

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _loading = false);
      context.go('/buyer-onboarding/complete');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _RedHero(
            title: 'Set up your profile',
            subtitle:
                'Complete your profile so\nstudents know who they\'re\nworking with.',
            showBack: true,
            onBack: () => context.go('/buyer-onboarding/interests'),
            step: 3,
            totalSteps: 3,
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your details',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _C.dark,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'This information is visible to students you hire.',
                        style: TextStyle(fontSize: 13, color: _C.grey),
                      ),
                      const SizedBox(height: 24),

                      // Avatar picker (decorative)
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: _C.primary.withOpacity(0.3),
                                    width: 2),
                              ),
                              child: const Center(
                                child: Icon(Icons.person_rounded,
                                    size: 40, color: _C.primary),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _C.primary,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    size: 13, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _label('Display Name *'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _displayName,
                        hint: 'e.g. John Doe',
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Display name is required'
                            : null,
                        capitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 14),

                      if (_isBusiness) ...[
                        _label('Company / Organisation Name *'),
                        const SizedBox(height: 6),
                        _field(
                          controller: _companyName,
                          hint: 'e.g. Acme Corp',
                          icon: Icons.business_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Company name is required'
                              : null,
                          capitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 14),
                      ],

                      _label('Phone Number (optional)'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _phone,
                        hint: 'e.g. 071 234 5678',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),

                      _label('City / Location *'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _location,
                        hint: 'e.g. Johannesburg',
                        icon: Icons.location_on_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Location is required'
                            : null,
                        capitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                            shadowColor: _C.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Complete Setup',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.check_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _C.grey,
            letterSpacing: 0.2),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: _C.dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// BUYER ONBOARDING COMPLETE PAGE
// Route: /buyer-onboarding/complete
// ─────────────────────────────────────────────
class BuyerOnboardingCompletePage extends StatefulWidget {
  const BuyerOnboardingCompletePage({super.key});

  @override
  State<BuyerOnboardingCompletePage> createState() =>
      _BuyerOnboardingCompletePageState();
}

class _BuyerOnboardingCompletePageState
    extends State<BuyerOnboardingCompletePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _C.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _C.primary.withOpacity(0.3), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle_rounded,
                          size: 56, color: _C.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const Text(
                      'You\'re all set! 🎉',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _C.dark,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your buyer profile is ready.\nStart discovering student talent on the Gude Marketplace.',
                      style:
                          TextStyle(fontSize: 15, color: _C.grey, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // What's next cards
                    _NextCard(
                      icon: Icons.search_rounded,
                      title: 'Browse the Marketplace',
                      subtitle: 'Find students with the skills you need.',
                    ),
                    const SizedBox(height: 12),
                    _NextCard(
                      icon: Icons.post_add_rounded,
                      title: 'Post a Job',
                      subtitle:
                          'Describe what you need and let students apply.',
                    ),
                    const SizedBox(height: 12),
                    _NextCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Set Up Payments',
                      subtitle:
                          'Add funds to your Gude Wallet to hire securely.',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: _C.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => context.go('/marketplace'),
                        child: const Text(
                          'Explore Marketplace',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.dark,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: _C.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => context.go('/home'),
                        child: const Text(
                          'Go to Home',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════

// ── Red Hero Header ───────────────────────────────────
class _RedHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final int? step;
  final int? totalSteps;

  const _RedHero({
    required this.title,
    required this.subtitle,
    required this.showBack,
    this.onBack,
    this.step,
    this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          // Red gradient bg
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE30613), Color(0xFFB0000E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Positioned(
            top: 50,
            right: 40,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06)),
            ),
          ),
          // Wave
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _WavePainter(),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: back + progress
                  Row(
                    children: [
                      if (showBack)
                        GestureDetector(
                          onTap: onBack,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white, size: 15),
                          ),
                        )
                      else
                        // G logo
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: const Center(
                            child: Text('G',
                                style: TextStyle(
                                    color: _C.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5)),
                          ),
                        ),
                      const Spacer(),
                      if (step != null && totalSteps != null)
                        _StepIndicator(step: step!, total: totalSteps!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int step;
  final int total;
  const _StepIndicator({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$step of $total',
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Feature Tile ──────────────────────────────────────
class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _FeatureTile(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.dark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: _C.grey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Type Card ─────────────────────────────────────────
class _TypeCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  const _TypeCard(
      {required this.emoji,
      required this.label,
      required this.sub,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _C.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _C.primary : const Color(0xFFEEEEEE),
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: _C.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 6)
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? _C.primary.withOpacity(0.1)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected ? _C.primary : _C.dark)),
                  const SizedBox(height: 3),
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 12, color: _C.grey, height: 1.4)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? _C.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _C.primary : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Interest Chip ─────────────────────────────────────
class _InterestChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _InterestChip(
      {required this.emoji,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _C.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? _C.primary : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: _C.primary.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _C.primary : _C.dark,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded,
                  size: 14, color: _C.primary),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Next Card (complete screen) ───────────────────────
class _NextCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _NextCard(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _C.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.dark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: _C.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC), size: 20),
        ],
      ),
    );
  }
}

// ── Wave Painter ──────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path();
    path.moveTo(0, size.height * 0.55);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1,
        size.width * 0.5, size.height * 0.45);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.8, size.width, size.height * 0.35);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
