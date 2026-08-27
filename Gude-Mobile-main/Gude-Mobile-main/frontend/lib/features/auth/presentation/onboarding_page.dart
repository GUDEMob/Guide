// lib/features/auth/presentation/onboarding_page.dart
// Financial Coach onboarding flow — 6 steps matching PDF wireframes.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/user_role_service.dart';
import 'package:gude_app/services/wallet_service.dart';

// ── Colours (matching app palette) ──────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const green = Color(0xFF10B981);
}

// ── Data models ───────────────────────────────────────────────
enum _FundingType { nsfas, bursary, hustle, familySupport }

enum _LivingType { res, home, renting }

extension _FundingExt on _FundingType {
  String get label => const {
        _FundingType.nsfas: 'NSFAS',
        _FundingType.bursary: 'Bursary',
        _FundingType.hustle: 'Hustle / Side Income',
        _FundingType.familySupport: 'Family Support',
      }[this]!;
  String get emoji => const {
        _FundingType.nsfas: '🏛️',
        _FundingType.bursary: '🎓',
        _FundingType.hustle: '💼',
        _FundingType.familySupport: '👨‍👩‍👧',
      }[this]!;
}

extension _LivingExt on _LivingType {
  String get label => const {
        _LivingType.res: 'Residence / Digs',
        _LivingType.home: 'Living at Home',
        _LivingType.renting: 'Renting',
      }[this]!;
  String get emoji => const {
        _LivingType.res: '🏠',
        _LivingType.home: '🏡',
        _LivingType.renting: '🔑',
      }[this]!;
}

const _painPoints = [
  ('Food', '🍔', Color(0xFFE30613)),
  ('Transport', '🚌', Color(0xFF3B82F6)),
  ('Data', '📶', Color(0xFF8B5CF6)),
  ('Debt', '💳', Color(0xFFF59E0B)),
];

// ════════════════════════════════════════════════════════════════
//  OnboardingPage (renamed from CoachOnboardingPage)
// ════════════════════════════════════════════════════════════════
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _step = 0; // 0-5

  // Collected answers
  _FundingType? _funding;
  final _incomeCtrl = TextEditingController();
  _LivingType? _living;
  final Set<String> _painSelected = {};

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const _totalSteps =
      6; // 0=welcome,1=funding,2=income,3=living,4=pain,5=summary

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _incomeCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _incomeCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _animCtrl.reset();
      _animCtrl.forward();
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _step++);
    } else {
      // Save onboarding answers so the AI coach can use them
      final userService = UserRoleService();
      userService.fundingType = _funding?.label ?? '';
      userService.monthlyIncome = double.tryParse(_incomeCtrl.text.trim()) ?? 0;
      userService.livingType = _living?.label ?? '';
      userService.painPoints = _painSelected.toList();
      WalletService().initFromOnboarding();

      context.go('/home'); // ← was '/login'
    }
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return true;
      case 1:
        return _funding != null;
      case 2:
        final amount = double.tryParse(_incomeCtrl.text.trim()) ?? 0;
        return amount >= 1000;
      case 3:
        return _living != null;
      case 4:
        return _painSelected.isNotEmpty;
      case 5:
        return true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_step > 0)
                        GestureDetector(
                          onTap: () {
                            _pageCtrl.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                            setState(() => _step--);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _C.lightGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                size: 16, color: _C.dark),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                      Text(
                        'Step ${_step + 1} of $_totalSteps',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _C.grey,
                            fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _totalSteps,
                      minHeight: 5,
                      backgroundColor: _C.border,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_C.primary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page content ─────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WelcomeStep(onNext: _next),
                    _FundingStep(
                      selected: _funding,
                      onSelect: (v) => setState(() => _funding = v),
                    ),
                    _IncomeStep(controller: _incomeCtrl),
                    _LivingStep(
                      selected: _living,
                      onSelect: (v) => setState(() => _living = v),
                    ),
                    _PainStep(
                      selected: _painSelected,
                      onToggle: (v) => setState(() {
                        _painSelected.contains(v)
                            ? _painSelected.remove(v)
                            : _painSelected.add(v);
                      }),
                    ),
                    _SummaryStep(
                      funding: _funding,
                      income: _incomeCtrl.text,
                      living: _living,
                      pain: _painSelected,
                    ),
                  ],
                ),
              ),
            ),

            // ── CTA button ────────────────────────────────────
            if (_step != 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _next : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.dark,
                      disabledBackgroundColor: _C.border,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _step == _totalSteps - 1
                          ? 'Continue to Dashboard 🚀'
                          : 'Next',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 0 — Welcome
// ─────────────────────────────────────────────
class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('💸', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "Let's fix your\nmoney game 💸",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _C.dark,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your personal AI Financial Coach will help you budget smarter, '
            'save more and stress less — tailored just for your student life.',
            style: TextStyle(
              fontSize: 15,
              color: _C.grey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Start',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Takes less than 2 minutes',
              style: TextStyle(fontSize: 12, color: _C.grey.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 1 — Funding type
// ─────────────────────────────────────────────
class _FundingStep extends StatelessWidget {
  final _FundingType? selected;
  final ValueChanged<_FundingType> onSelect;
  const _FundingStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How do you get money?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _C.dark,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Select your primary funding source.',
              style: TextStyle(fontSize: 14, color: _C.grey)),
          const SizedBox(height: 28),
          ...(_FundingType.values.map((f) => _OptionTile(
                emoji: f.emoji,
                label: f.label,
                selected: selected == f,
                color: _C.primary,
                onTap: () => onSelect(f),
              ))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 2 — Monthly income
// ─────────────────────────────────────────────
class _IncomeStep extends StatelessWidget {
  final TextEditingController controller;
  const _IncomeStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How much do you\nreceive monthly?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _C.dark,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text('This helps your coach set realistic budgets for you.',
              style: TextStyle(fontSize: 14, color: _C.grey)),
          const SizedBox(height: 36),
          Container(
            decoration: BoxDecoration(
              color: _C.lightGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border),
            ),
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: _C.dark),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixText: 'R  ',
                prefixStyle: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: _C.grey),
                hintText: '0.00',
                hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 22),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.lock_outline, size: 16, color: _C.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your data stays private. We never share your financial info.',
                  style: TextStyle(
                      fontSize: 12, color: _C.primary.withOpacity(0.85)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          const Text(
            'Minimum R1,000 to continue',
            style: TextStyle(fontSize: 11, color: _C.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 3 — Living situation
// ─────────────────────────────────────────────
class _LivingStep extends StatelessWidget {
  final _LivingType? selected;
  final ValueChanged<_LivingType> onSelect;
  const _LivingStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where are you\nliving?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _C.dark,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Your accommodation affects your monthly costs.',
              style: TextStyle(fontSize: 14, color: _C.grey)),
          const SizedBox(height: 28),
          ...(_LivingType.values.map((l) => _OptionTile(
                emoji: l.emoji,
                label: l.label,
                selected: selected == l,
                color: const Color(0xFF3B82F6),
                onTap: () => onSelect(l),
              ))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 4 — Pain points
// ─────────────────────────────────────────────
class _PainStep extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _PainStep({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What stresses\nyou most?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _C.dark,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Pick all that apply — your coach will focus here.',
              style: TextStyle(fontSize: 14, color: _C.grey)),
          const SizedBox(height: 28),
          ...(_painPoints.map((p) {
            final (label, emoji, color) = p;
            final sel = selected.contains(label);
            return GestureDetector(
              onTap: () => onToggle(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? color.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? color : _C.border,
                    width: sel ? 1.8 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: sel ? color : _C.dark)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: sel ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: sel ? color : _C.border, width: 1.5),
                    ),
                    child: sel
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ]),
              ),
            );
          })),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 5 — Summary / "Here's your plan"
// ─────────────────────────────────────────────
class _SummaryStep extends StatelessWidget {
  final _FundingType? funding;
  final String income;
  final _LivingType? living;
  final Set<String> pain;

  const _SummaryStep({
    required this.funding,
    required this.income,
    required this.living,
    required this.pain,
  });

  String get _savingsTip {
    final amt = double.tryParse(income) ?? 0;
    if (amt > 5000)
      return 'Save at least R${(amt * 0.15).toStringAsFixed(0)} monthly.';
    if (amt > 2000)
      return 'Aim to save R${(amt * 0.1).toStringAsFixed(0)} monthly.';
    return 'Even saving R50/week adds up fast.';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Center(child: Text('🎯', style: TextStyle(fontSize: 30))),
          ),
          const SizedBox(height: 20),
          const Text(
            "Here's your plan 🎉",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _C.dark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
              'Your AI Coach has built a personalised money plan for you.',
              style: TextStyle(fontSize: 14, color: _C.grey, height: 1.5)),
          const SizedBox(height: 24),

          // Summary cards
          _SummaryRow(
            icon: Icons.account_balance_outlined,
            label: 'Funding',
            value: funding?.label ?? '—',
            color: _C.primary,
          ),
          _SummaryRow(
            icon: Icons.payments_outlined,
            label: 'Monthly income',
            value: income.isNotEmpty ? 'R $income' : '—',
            color: _C.green,
          ),
          _SummaryRow(
            icon: Icons.home_outlined,
            label: 'Living',
            value: living?.label ?? '—',
            color: const Color(0xFF3B82F6),
          ),
          _SummaryRow(
            icon: Icons.warning_amber_outlined,
            label: 'Focus areas',
            value: pain.isEmpty ? '—' : pain.join(', '),
            color: const Color(0xFFF59E0B),
          ),

          const SizedBox(height: 20),

          // Coach tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF333333)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🤖', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coach says:',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        _savingsTip,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
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

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _SummaryRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: _C.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _C.dark)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable option tile
// ─────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.07) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : _C.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : _C.dark)),
          ),
          if (selected)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
        ]),
      ),
    );
  }
}
