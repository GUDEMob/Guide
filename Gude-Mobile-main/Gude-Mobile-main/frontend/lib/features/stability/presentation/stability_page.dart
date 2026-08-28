import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const border = Color(0xFFEEEEEE);
  static const lightGrey = Color(0xFFF5F5F5);
}

// ─────────────────────────────────────────────
// QUESTIONNAIRE DATA
// ─────────────────────────────────────────────
class _Question {
  final String category;
  final String text;
  final IconData icon;
  final Color color;
  const _Question({
    required this.category,
    required this.text,
    required this.icon,
    required this.color,
  });
}

const _kQuestions = [
  _Question(
    category: 'Financial Life',
    text:
        'How are you managing your day-to-day expenses (food, transport, data, etc.)?',
    icon: Icons.account_balance_wallet_outlined,
    color: _C.primary,
  ),
  _Question(
    category: 'Financial Life',
    text:
        'How confident do you feel about your ability to pay for your studies (fees, materials, etc.)?',
    icon: Icons.account_balance_wallet_outlined,
    color: _C.primary,
  ),
  _Question(
    category: 'Academic Life',
    text: 'How are you coping with your coursework and academic workload?',
    icon: Icons.school_outlined,
    color: _C.blue,
  ),
  _Question(
    category: 'Academic Life',
    text:
        'How confident do you feel about your academic performance this term?',
    icon: Icons.school_outlined,
    color: _C.blue,
  ),
  _Question(
    category: 'Mental Wellness',
    text: 'How have you been feeling emotionally over the past few weeks?',
    icon: Icons.favorite_outline,
    color: Color(0xFF8B5CF6),
  ),
  _Question(
    category: 'Mental Wellness',
    text:
        'How well are you managing stress and balancing your personal and academic life?',
    icon: Icons.favorite_outline,
    color: Color(0xFF8B5CF6),
  ),
];

const _kAnswers = [
  'Doing Well',
  'Managing',
  'Having a Tough Time',
  'I Need Help'
];

// answer index 0,1 = positive; 2,3 = negative
bool _isPositive(int answerIndex) => answerIndex <= 1;

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
class _Signal {
  final String label, note, howItWorks;
  final int score;
  final IconData icon;
  bool expanded;
  _Signal(this.label, this.score, this.icon, this.note, this.howItWorks,
      {this.expanded = false});
}

class _SupportItem {
  final String title, description;
  final IconData icon;
  final Color color;
  final String? route;
  final String howItHelps;
  final String implementation;
  const _SupportItem(
      this.title, this.icon, this.color, this.description, this.route,
      {required this.howItHelps, required this.implementation});
}

class _CheckinRecord {
  final DateTime date;
  final String mood;
  final String moodLabel;
  final int scoreDelta;
  const _CheckinRecord({
    required this.date,
    required this.mood,
    required this.moodLabel,
    required this.scoreDelta,
  });
}

// ─────────────────────────────────────────────
// STABILITY PAGE
// ─────────────────────────────────────────────
class StabilityPage extends StatefulWidget {
  const StabilityPage({super.key});
  @override
  State<StabilityPage> createState() => _StabilityPageState();
}

class _StabilityPageState extends State<StabilityPage>
    with TickerProviderStateMixin {
  int _score = 62;
  bool _checkinDone = false;
  bool _scoreExpanded = false;

  late AnimationController _scoreAnim;
  late Animation<double> _scoreValue;

  final List<_CheckinRecord> _checkinHistory = [
    _CheckinRecord(
      date: DateTime.now().subtract(const Duration(days: 7)),
      mood: 'well',
      moodLabel: 'Doing well',
      scoreDelta: 5,
    ),
    _CheckinRecord(
      date: DateTime.now().subtract(const Duration(days: 14)),
      mood: 'stressed',
      moodLabel: 'A bit stressed',
      scoreDelta: -3,
    ),
    _CheckinRecord(
      date: DateTime.now().subtract(const Duration(days: 21)),
      mood: 'well',
      moodLabel: 'Doing well',
      scoreDelta: 5,
    ),
    _CheckinRecord(
      date: DateTime.now().subtract(const Duration(days: 28)),
      mood: 'struggling',
      moodLabel: 'Having a tough time',
      scoreDelta: -7,
    ),
  ];

  String get _scoreLabel {
    if (_score >= 75) return 'Thriving';
    if (_score >= 55) return 'Steady';
    if (_score >= 35) return 'Needs Attention';
    return "Let's Get You Support";
  }

  String get _scoreEmoji {
    if (_score >= 75) return '🟢';
    if (_score >= 55) return '🟡';
    if (_score >= 35) return '🟠';
    return '🔴';
  }

  String get _scoreMessage {
    if (_score >= 75)
      return 'You\'re doing great! Keep building those good habits.';
    if (_score >= 55)
      return 'You\'re on track — a few areas worth keeping an eye on.';
    if (_score >= 35)
      return 'Some signals suggest you could use a little extra support.';
    return 'We\'ve spotted some stress signals. You\'re not alone — let\'s help.';
  }

  Color get _scoreColor {
    if (_score >= 75) return _C.green;
    if (_score >= 55) return _C.amber;
    if (_score >= 35) return const Color(0xFFEF4444);
    return const Color(0xFFB91C1C);
  }

  static const String _overallExplanation =
      'Your Stability Score is calculated from four signals:\n\n'
      '• Financial Health — 35%\n'
      '  Based on your budget usage and spending patterns.\n\n'
      '• Marketplace Activity — 30%\n'
      '  How often you are earning through the marketplace.\n\n'
      '• App Engagement — 20%\n'
      '  How consistently you open and use the Gude app.\n\n'
      '• Wellbeing Check-ins — 15%\n'
      '  Your mood responses from weekly check-ins.\n\n'
      'Each signal has a score out of 100. The weighted average gives your final score. Higher scores reflect more financial stability and consistent engagement.';

  final List<_Signal> _signals = [
    _Signal(
        'Financial Health',
        55,
        Icons.account_balance_wallet_outlined,
        'R670 over budget this month',
        'This signal looks at your Gude Wallet spending against your set monthly budget. If you spend within budget, your score here increases. Overspending reduces it. Weight: 35% of your total score.'),
    _Signal(
        'Marketplace Activity',
        80,
        Icons.store_outlined,
        '3 active gigs this week',
        'This measures how frequently you list services or products, respond to buyers, and complete transactions. More marketplace activity signals financial hustle and stability. Weight: 30% of your total score.'),
    _Signal(
        'App Engagement',
        70,
        Icons.phone_android_outlined,
        'Active 5 of 7 days',
        'Consistent app usage signals that you are engaged with managing your finances and wellbeing. Weight: 20% of your total score.'),
    _Signal(
        'Wellbeing Check-ins',
        40,
        Icons.favorite_outline,
        'Missed last 2 check-ins',
        'Your responses to the weekly mood check-ins directly feed into this signal. Skipping check-ins lowers the signal due to missing data. Weight: 15% of your total score.'),
  ];

  final _supportItems = [
    const _SupportItem('Quick Income', Icons.bolt_rounded, _C.primary,
        'Fast-paying gigs near you', '/marketplace',
        howItHelps:
            'As a student, unexpected expenses or a tight month can be stressful. Quick Income connects you to short-term, fast-paying gigs that match your skills — things like tutoring, delivery, data capturing, or graphic design tasks posted by people nearby.',
        implementation: '• Browse gigs posted within 5 km of your campus\n'
            '• Filter by skill: writing, design, tutoring, tech\n'
            '• Accept a gig and get paid directly to your Gude Wallet\n'
            '• Most gigs pay within 24–48 hours of completion\n'
            '• Your Marketplace Activity score improves with each completed gig'),
    const _SupportItem('Budget Help', Icons.savings_outlined, _C.blue,
        'Restructure your budget', '/wallet/budget',
        howItHelps:
            'Feeling like money runs out before the month ends? Budget Help gives you a personalised plan based on your actual Gude Wallet spending. It identifies where you are overspending and suggests realistic adjustments so you can stay on top of essentials like food, transport, and data.',
        implementation:
            '• Gude analyses your last 30 days of wallet transactions\n'
            '• You receive a breakdown: needs vs wants vs savings\n'
            '• Set new category limits with one tap\n'
            '• Weekly nudges remind you when you are close to a limit\n'
            '• Your Financial Health signal improves as you stay within budget'),
    const _SupportItem('Food Support', Icons.fastfood_outlined, _C.green,
        'Affordable meals & food banks', null,
        howItHelps:
            'Food insecurity is one of the biggest hidden challenges for students. Food Support helps you locate nearby campus food banks, soup kitchens, community meal programmes, and subsidised cafeterias so that going hungry never gets in the way of your studies.',
        implementation: '• Map of food banks and meal programmes within 10 km\n'
            '• Campus dining discounts for qualifying students\n'
            '• Weekly community meal schedules updated in real time\n'
            '• Anonymous access — no forms or judgement required\n'
            '• Share a location tip with fellow students directly in the app'),
    const _SupportItem('Peer Tutoring', Icons.school_outlined,
        Color(0xFF8B5CF6), 'Free peer tutoring groups', '/marketplace',
        howItHelps:
            'Falling behind in a module or struggling with a concept? Peer Tutoring connects you with fellow students who have already passed those courses and are willing to help — either for free as a community contribution or for a small fee through the marketplace.',
        implementation: '• Search by module code or subject area\n'
            '• Book a one-on-one or group session via the marketplace\n'
            '• Sessions can be in person or online via a shared link\n'
            '• Rate your tutor after each session to build trust scores\n'
            '• Earn income yourself by listing as a tutor in your strong subjects'),
    const _SupportItem('Talk to Someone', Icons.psychology_outlined, _C.amber,
        'Campus counselling services', null,
        howItHelps:
            'Sometimes the pressure of studies, finances, and life all builds up at once. Talk to Someone connects you to trained campus counsellors and peer support groups where you can speak freely, get coping strategies, and feel heard — without any stigma.',
        implementation:
            '• Direct booking with your institution\'s counselling centre\n'
            '• Anonymous peer support chat available 24/7\n'
            '• Crisis line numbers displayed for urgent situations\n'
            '• Weekly virtual group check-in sessions you can join\n'
            '• Your Wellbeing Check-in score improves when you engage with support'),
    const _SupportItem('Mentorship', Icons.people_outline, Color(0xFFEC4899),
        'Connect with a student mentor', null,
        howItHelps:
            'Having someone a few years ahead of you who has navigated the same challenges can make a huge difference. Mentorship pairs you with a senior student or young professional who can guide you on academics, career choices, financial decisions, and life on campus.',
        implementation:
            '• Complete a short profile about your goals and challenges\n'
            '• Get matched with a mentor based on your field of study\n'
            '• Monthly one-on-one sessions via video or in person\n'
            '• Access a shared resource library curated by mentors\n'
            '• Become a mentor yourself once you reach your second year'),
  ];

  @override
  void initState() {
    super.initState();
    _scoreAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scoreValue = Tween<double>(begin: 0, end: _score / 100).animate(
        CurvedAnimation(parent: _scoreAnim, curve: Curves.easeOutCubic));
    _scoreAnim.forward();
  }

  @override
  void dispose() {
    _scoreAnim.dispose();
    super.dispose();
  }

  /// Called when the questionnaire completes.
  /// [answers] is a list of answer indices (0–3) for each of the 6 questions.
  void _onCheckinSubmitted(List<int> answers) {
    final positiveCount = answers.where(_isPositive).length;
    final total = answers.length;
    final majorityPositive = positiveCount >= (total / 2);

    final mood = majorityPositive ? 'well' : 'struggling';
    final moodLabel = majorityPositive ? 'Doing well' : 'Having a tough time';
    final delta = majorityPositive ? 5 : -7;

    setState(() {
      _checkinDone = true;
      _checkinHistory.insert(
        0,
        _CheckinRecord(
          date: DateTime.now(),
          mood: mood,
          moodLabel: moodLabel,
          scoreDelta: delta,
        ),
      );
      _score = (_score + delta).clamp(0, 100);
      _scoreAnim.reset();
      _scoreValue = Tween<double>(begin: _scoreValue.value, end: _score / 100)
          .animate(
              CurvedAnimation(parent: _scoreAnim, curve: Curves.easeOutCubic));
      _scoreAnim.forward();
    });
  }

  void _showScoreExplanationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('How your score is calculated',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: SingleChildScrollView(
            child: Text(_overallExplanation,
                style: const TextStyle(
                    fontSize: 13, height: 1.6, color: Color(0xFF444444)))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it',
                  style: TextStyle(
                      color: _C.primary, fontWeight: FontWeight.w700)))
        ],
      ),
    );
  }

  void _showCheckinModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckinModal(
        checkinDone: _checkinDone,
        checkinHistory: _checkinHistory,
        onSubmit: _onCheckinSubmitted,
        moodEmoji: _moodEmoji,
        moodColor: _moodColor,
        formatDate: _formatDate,
      ),
    );
  }

  void _showSupportDetail(_SupportItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SupportDetailSheet(item: item),
    );
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'well':
        return '😊';
      case 'stressed':
        return '😰';
      case 'struggling':
        return '😞';
      case 'help':
        return '🆘';
      default:
        return '😐';
    }
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'well':
        return _C.green;
      case 'stressed':
        return _C.amber;
      case 'struggling':
        return const Color(0xFFEF4444);
      case 'help':
        return const Color(0xFFB91C1C);
      default:
        return _C.grey;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 14) return '1 week ago';
    return '${(diff / 7).round()} weeks ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'checkin_fab',
            onPressed: _showCheckinModal,
            backgroundColor: _checkinDone ? _C.green : _C.primary,
            elevation: 4,
            icon: Icon(
              _checkinDone
                  ? Icons.check_circle_outline
                  : Icons.checklist_rtl_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              _checkinDone ? 'Check-in Done' : 'Weekly Check-in',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: _C.primary,
          elevation: 0,
          title: const Text('Support Hub',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          actions: [
            IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: _showScoreExplanationDialog)
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Support Hub ────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE30613), Color(0xFF7C4DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 26),
                      const SizedBox(height: 12),
                      const Text('You are not alone',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text('Practical support for money, food, studies and wellbeing.',
                          style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(
                        3,
                        (row) => Padding(
                              padding:
                                  EdgeInsets.only(bottom: row < 2 ? 12 : 0),
                              child: Row(children: [
                                Expanded(
                                  child: _SupportCard(
                                    item: _supportItems[row * 2],
                                    onTap: () => _showSupportDetail(
                                        _supportItems[row * 2]),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SupportCard(
                                    item: _supportItems[row * 2 + 1],
                                    onTap: () => _showSupportDetail(
                                        _supportItems[row * 2 + 1]),
                                  ),
                                ),
                              ]),
                            )),
                  ),
                ),

                // ── Score Card ─────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _scoreColor.withOpacity(0.18)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12)
                      ]),
                  child: Column(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: _showScoreExplanationDialog,
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Stability Score',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: _C.grey)),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.help_outline_rounded,
                                              size: 13, color: _C.grey),
                                        ]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Text(_scoreEmoji,
                                        style: const TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: AnimatedBuilder(
                                        animation: _scoreAnim,
                                        builder: (_, __) => Text(_scoreLabel,
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: _scoreColor)),
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(_scoreMessage,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF666666),
                                          height: 1.4)),
                                ]),
                          ),
                          const SizedBox(width: 16),
                          AnimatedBuilder(
                            animation: _scoreAnim,
                            builder: (_, __) => _ScoreRing(
                              value: _scoreValue.value,
                              color: _scoreColor,
                              score: (_scoreValue.value * 100).round(),
                            ),
                          ),
                        ]),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedBuilder(
                        animation: _scoreAnim,
                        builder: (_, __) => LinearProgressIndicator(
                          value: _scoreValue.value,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFEEEEEE),
                          valueColor: AlwaysStoppedAnimation(_scoreColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ScoreLegend(color: _C.green, label: 'Thriving 75+'),
                        _ScoreLegend(color: _C.amber, label: 'Steady 55+'),
                        _ScoreLegend(
                            color: const Color(0xFFEF4444),
                            label: 'Attention 35+'),
                        _ScoreLegend(
                            color: const Color(0xFFB91C1C), label: 'Support'),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      child: _scoreExpanded
                          ? Column(children: [
                              const SizedBox(height: 16),
                              const Divider(color: _C.border),
                              const SizedBox(height: 10),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Score Breakdown',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _C.dark)),
                              ),
                              const SizedBox(height: 4),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "Here's exactly how your score was calculated this week:",
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _C.grey,
                                        height: 1.4)),
                              ),
                              const SizedBox(height: 12),
                              _WeightedRow(
                                  label: 'Financial Health',
                                  score: _signals[0].score,
                                  weight: 35,
                                  color: _C.primary),
                              _WeightedRow(
                                  label: 'Marketplace Activity',
                                  score: _signals[1].score,
                                  weight: 30,
                                  color: _C.blue),
                              _WeightedRow(
                                  label: 'App Engagement',
                                  score: _signals[2].score,
                                  weight: 20,
                                  color: _C.green),
                              _WeightedRow(
                                  label: 'Wellbeing Check-ins',
                                  score: _signals[3].score,
                                  weight: 15,
                                  color: _C.amber),
                              const Divider(color: _C.border, height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Your Final Score',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _C.dark)),
                                  Text('$_score / 100',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: _scoreColor)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _showScoreExplanationDialog,
                                child: const Text(
                                  'Tap here to learn how each signal is measured →',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _C.primary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ])
                          : const SizedBox(height: 4),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _scoreExpanded = !_scoreExpanded),
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _scoreExpanded
                                    ? 'Hide breakdown'
                                    : 'See how this is calculated',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: _C.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                              Icon(
                                _scoreExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: _C.primary,
                              ),
                            ]),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// CHECK-IN MODAL — orchestrates quiz + summary
// ─────────────────────────────────────────────
class _CheckinModal extends StatefulWidget {
  final bool checkinDone;
  final List<_CheckinRecord> checkinHistory;
  final void Function(List<int> answers) onSubmit;
  final String Function(String) moodEmoji;
  final Color Function(String) moodColor;
  final String Function(DateTime) formatDate;

  const _CheckinModal({
    required this.checkinDone,
    required this.checkinHistory,
    required this.onSubmit,
    required this.moodEmoji,
    required this.moodColor,
    required this.formatDate,
  });

  @override
  State<_CheckinModal> createState() => _CheckinModalState();
}

class _CheckinModalState extends State<_CheckinModal> {
  List<int>? _completedAnswers;
  bool _historyExpanded = false;

  void _onQuizDone(List<int> answers) {
    setState(() => _completedAnswers = answers);
    widget.onSubmit(answers);
  }

  @override
  Widget build(BuildContext context) {
    double initialSize;
    if (_completedAnswers != null) {
      initialSize = 0.85;
    } else if (widget.checkinDone) {
      initialSize = 0.55;
    } else {
      initialSize = 0.90;
    }

    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: _completedAnswers != null
                ? _SummaryView(
                    answers: _completedAnswers!,
                    controller: controller,
                    onClose: () => Navigator.pop(context),
                  )
                : widget.checkinDone
                    ? _AlreadyDoneView(
                        checkinHistory: widget.checkinHistory,
                        controller: controller,
                        historyExpanded: _historyExpanded,
                        onToggleHistory: () => setState(
                            () => _historyExpanded = !_historyExpanded),
                        moodEmoji: widget.moodEmoji,
                        moodColor: widget.moodColor,
                        formatDate: widget.formatDate,
                        onClose: () => Navigator.pop(context),
                      )
                    : _QuizView(
                        controller: controller,
                        onDone: _onQuizDone,
                      ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUIZ VIEW — step through 6 questions
// ─────────────────────────────────────────────
class _QuizView extends StatefulWidget {
  final ScrollController controller;
  final void Function(List<int> answers) onDone;
  const _QuizView({required this.controller, required this.onDone});

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  int _step = 0;
  final List<int?> _answers = List.filled(6, null);

  void _select(int answerIndex) =>
      setState(() => _answers[_step] = answerIndex);

  void _next() {
    if (_answers[_step] == null) return;
    if (_step < 5) {
      setState(() => _step++);
    } else {
      widget.onDone(List<int>.from(_answers.map((a) => a ?? 0)));
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final q = _kQuestions[_step];
    final progress = (_step + 1) / _kQuestions.length;

    return ListView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // ── Header row ───────────────────────────────────────
        Row(children: [
          GestureDetector(
            onTap: _step > 0 ? _back : null,
            child: Icon(Icons.arrow_back_ios_rounded,
                size: 18, color: _step > 0 ? _C.grey : Colors.transparent),
          ),
          const Spacer(),
          Text(
            '${_step + 1} of ${_kQuestions.length}',
            style: const TextStyle(
                fontSize: 12, color: _C.grey, fontWeight: FontWeight.w600),
          ),
        ]),
        const SizedBox(height: 10),

        // ── Progress bar ─────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(q.color),
          ),
        ),
        const SizedBox(height: 22),

        // ── Category pill ─────────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: q.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(q.icon, size: 13, color: q.color),
              const SizedBox(width: 5),
              Text(q.category,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: q.color)),
            ]),
          ),
        ),
        const SizedBox(height: 10),

        // ── Question text ─────────────────────────────────────
        Text(q.text,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.dark,
                height: 1.4)),
        const SizedBox(height: 22),

        // ── Answer options ────────────────────────────────────
        ...List.generate(_kAnswers.length, (i) {
          final selected = _answers[_step] == i;
          final pos = _isPositive(i);
          final optColor = pos ? _C.green : _C.primary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _select(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? optColor.withOpacity(0.07)
                      : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? optColor : const Color(0xFFE8E8E8),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? optColor : Colors.transparent,
                      border: Border.all(
                        color: selected ? optColor : const Color(0xFFCCCCCC),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_kAnswers[i],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected ? optColor : _C.dark)),
                  ),
                  if (!pos)
                    Icon(Icons.warning_amber_rounded,
                        size: 15,
                        color: selected ? optColor : const Color(0xFFCCCCCC)),
                ]),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),

        // ── Next / Submit ─────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _answers[_step] != null ? _next : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: q.color,
              disabledBackgroundColor: const Color(0xFFEEEEEE),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              _step < 5 ? 'Next' : 'Submit Check-in',
              style: TextStyle(
                  color: _answers[_step] != null ? Colors.white : _C.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SUMMARY VIEW
// ─────────────────────────────────────────────
class _SummaryView extends StatelessWidget {
  final List<int> answers;
  final ScrollController controller;
  final VoidCallback onClose;

  const _SummaryView({
    required this.answers,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final positiveCount = answers.where(_isPositive).length;
    final total = answers.length;
    final majorityPositive = positiveCount >= (total / 2);

    bool catOk(List<int> a) => a.where(_isPositive).length >= (a.length / 2);
    final financialOk = catOk([answers[0], answers[1]]);
    final academicOk = catOk([answers[2], answers[3]]);
    final wellnessOk = catOk([answers[4], answers[5]]);

    final headerEmoji = majorityPositive ? '🎉' : '💙';
    final headerTitle =
        majorityPositive ? 'Great — keep it up!' : 'Thanks for sharing';
    final headerSub = majorityPositive
        ? 'Your check-in reflects that you\'re managing well overall. Your Wellbeing Check-in score has been updated.'
        : 'It sounds like things are tough right now — that\'s okay. We\'ve updated your score. Resources in the Support Hub are ready for you.';

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // ── Outcome banner ───────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: majorityPositive
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : [const Color(0xFFE30613), const Color(0xFFB0000E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(headerEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headerTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(headerSub,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, height: 1.5)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Positive score pill ──────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(children: [
            const Icon(Icons.bar_chart_rounded, color: _C.grey, size: 18),
            const SizedBox(width: 8),
            const Text('Positive responses',
                style: TextStyle(fontSize: 13, color: _C.grey)),
            const Spacer(),
            Text('$positiveCount / $total',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: majorityPositive ? _C.green : _C.primary)),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Category breakdown ───────────────────────────────
        const Text('Your Responses by Area',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: _C.dark)),
        const SizedBox(height: 12),
        _CategorySummaryRow(
          icon: Icons.account_balance_wallet_outlined,
          color: _C.primary,
          label: 'Financial Life',
          ok: financialOk,
          answers: [answers[0], answers[1]],
        ),
        const SizedBox(height: 10),
        _CategorySummaryRow(
          icon: Icons.school_outlined,
          color: _C.blue,
          label: 'Academic Life',
          ok: academicOk,
          answers: [answers[2], answers[3]],
        ),
        const SizedBox(height: 10),
        _CategorySummaryRow(
          icon: Icons.favorite_outline,
          color: const Color(0xFF8B5CF6),
          label: 'Mental Wellness',
          ok: wellnessOk,
          answers: [answers[4], answers[5]],
        ),
        const SizedBox(height: 20),

        // ── Support Hub nudge (majority negative only) ────────
        if (!majorityPositive) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Explore the Support Hub',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E))),
                      SizedBox(height: 4),
                      Text(
                        'Based on your responses, you might find valuable help in the Support Hub above. From quick income gigs and budget tools to counselling and tutoring — resources are ready for you.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF78350F),
                            height: 1.5),
                      ),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        // ── Full answers detail ───────────────────────────────
        const Text('Your Full Responses',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: _C.dark)),
        const SizedBox(height: 10),
        ...List.generate(_kQuestions.length, (i) {
          final q = _kQuestions[i];
          final a = answers[i];
          final pos = _isPositive(a);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: pos
                      ? _C.green.withOpacity(0.3)
                      : _C.primary.withOpacity(0.25)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(q.icon, size: 13, color: q.color),
                const SizedBox(width: 5),
                Text(q.category,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: q.color)),
              ]),
              const SizedBox(height: 4),
              Text(q.text,
                  style: const TextStyle(
                      fontSize: 12,
                      color: _C.dark,
                      fontWeight: FontWeight.w500,
                      height: 1.4)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pos
                      ? _C.green.withOpacity(0.10)
                      : _C.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_kAnswers[a],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: pos ? _C.green : _C.primary)),
              ),
            ]),
          );
        }),
        const SizedBox(height: 16),

        // ── Done button ───────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: majorityPositive ? _C.green : _C.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Done',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY SUMMARY ROW
// ─────────────────────────────────────────────
class _CategorySummaryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool ok;
  final List<int> answers;

  const _CategorySummaryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.ok,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final positiveCount = answers.where(_isPositive).length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok ? _C.green.withOpacity(0.06) : _C.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color:
                ok ? _C.green.withOpacity(0.25) : _C.primary.withOpacity(0.20)),
      ),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _C.dark)),
            Text('$positiveCount of ${answers.length} positive',
                style: const TextStyle(fontSize: 11, color: _C.grey)),
          ]),
        ),
        Icon(
          ok ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          color: ok ? _C.green : _C.primary,
          size: 20,
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// ALREADY DONE VIEW
// ─────────────────────────────────────────────
class _AlreadyDoneView extends StatelessWidget {
  final List<_CheckinRecord> checkinHistory;
  final ScrollController controller;
  final bool historyExpanded;
  final VoidCallback onToggleHistory;
  final String Function(String) moodEmoji;
  final Color Function(String) moodColor;
  final String Function(DateTime) formatDate;
  final VoidCallback onClose;

  const _AlreadyDoneView({
    required this.checkinHistory,
    required this.controller,
    required this.historyExpanded,
    required this.onToggleHistory,
    required this.moodEmoji,
    required this.moodColor,
    required this.formatDate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: const [
            Text('✅', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check-in recorded!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text('Your stability score has been updated.',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        if (checkinHistory.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(children: [
              GestureDetector(
                onTap: onToggleHistory,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Check-in History',
                          style: TextStyle(
                              color: _C.dark,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      Row(children: [
                        Text(
                          '${checkinHistory.length} record${checkinHistory.length != 1 ? 's' : ''}',
                          style: const TextStyle(color: _C.grey, fontSize: 11),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          historyExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _C.grey,
                          size: 18,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: historyExpanded
                    ? Column(children: [
                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                        ...checkinHistory.take(6).map((r) => _HistoryRowLight(
                              record: r,
                              moodEmoji: moodEmoji(r.mood),
                              moodColor: moodColor(r.mood),
                              dateLabel: formatDate(r.date),
                            )),
                        if (checkinHistory.length > 6)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 4),
                            child: Text(
                              '+ ${checkinHistory.length - 6} older records',
                              style:
                                  const TextStyle(color: _C.grey, fontSize: 11),
                            ),
                          ),
                        const SizedBox(height: 4),
                      ])
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _C.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Close',
                style: TextStyle(
                    color: _C.grey, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// HISTORY ROW (light theme)
// ─────────────────────────────────────────────
class _HistoryRowLight extends StatelessWidget {
  final _CheckinRecord record;
  final String moodEmoji;
  final Color moodColor;
  final String dateLabel;

  const _HistoryRowLight({
    required this.record,
    required this.moodEmoji,
    required this.moodColor,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = record.scoreDelta > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(children: [
        Text(moodEmoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record.moodLabel,
                style: const TextStyle(
                    color: _C.dark, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(dateLabel,
                style: const TextStyle(color: _C.grey, fontSize: 11)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isPositive
                ? _C.green.withOpacity(0.12)
                : const Color(0xFFEF4444).withOpacity(0.10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isPositive
                ? '+${record.scoreDelta} pts'
                : '${record.scoreDelta} pts',
            style: TextStyle(
                color: isPositive ? _C.green : const Color(0xFFEF4444),
                fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SUPPORT DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────
class _SupportDetailSheet extends StatelessWidget {
  final _SupportItem item;
  const _SupportDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Row(children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: item.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A1A))),
                          Text(item.description,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF888888))),
                        ]),
                  ),
                ]),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF0F0F0)),
                const SizedBox(height: 20),
                Row(children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: item.color, size: 18),
                  const SizedBox(width: 8),
                  Text('How it helps you',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: item.color)),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.color.withOpacity(0.15)),
                  ),
                  child: Text(item.howItHelps,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF444444), height: 1.6)),
                ),
                const SizedBox(height: 22),
                Row(children: [
                  Icon(Icons.checklist_rounded, color: item.color, size: 18),
                  const SizedBox(width: 8),
                  Text('How it works',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: item.color)),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Text(item.implementation,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF444444), height: 1.8)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (item.route != null) {
                        context.push(item.route!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.title} — coming soon!'),
                            backgroundColor: _C.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      item.route != null ? 'Get Started' : 'Notify Me',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCORE RING
// ─────────────────────────────────────────────
class _ScoreRing extends StatelessWidget {
  final double value;
  final Color color;
  final int score;
  const _ScoreRing(
      {required this.value, required this.color, required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 82,
          height: 82,
          child: CircularProgressIndicator(
              value: 1.0, strokeWidth: 9, color: const Color(0xFFEEEEEE)),
        ),
        SizedBox(
          width: 82,
          height: 82,
          child: CircularProgressIndicator(
              value: value,
              strokeWidth: 9,
              color: color,
              strokeCap: StrokeCap.round),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$score',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.0)),
          Text('/100',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.7),
                  height: 1.2)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// WEIGHTED ROW
// ─────────────────────────────────────────────
class _WeightedRow extends StatelessWidget {
  final String label;
  final int score, weight;
  final Color color;
  const _WeightedRow(
      {required this.label,
      required this.score,
      required this.weight,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final contribution = (score * weight / 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _C.dark))),
          Text('$score/100 × $weight% = ',
              style: const TextStyle(fontSize: 11, color: _C.grey)),
          Text('$contribution pts',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 5,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SUPPORT CARD
// ─────────────────────────────────────────────
class _SupportCard extends StatelessWidget {
  final _SupportItem item;
  final VoidCallback onTap;
  const _SupportCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 95,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: item.color.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(item.icon, size: 16, color: item.color),
            ),
            const Spacer(),
            Text(item.title,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _C.dark)),
            const SizedBox(height: 2),
            Text(item.description,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF999999), height: 1.3),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────
// SCORE LEGEND
// ─────────────────────────────────────────────
class _ScoreLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ScoreLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 9, color: Color(0xFF888888))),
      ]);
}
