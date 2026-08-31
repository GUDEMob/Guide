// lib/features/home/presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:gude_app/services/user_role_service.dart';
import 'package:gude_app/services/wallet_service.dart';

class _ExtraColors {
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
}

class _QAData {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  const _QAData(this.icon, this.label, this.color, [this.route]);
}

const _allActions = [
  _QAData(Icons.add_circle_outline, 'Log Expense', AppColors.primary),
  _QAData(Icons.pie_chart_outline, 'View Budget', _ExtraColors.blue,
      '/wallet/budget'),
  _QAData(Icons.savings_outlined, 'Save Money', _ExtraColors.green,
      '/wallet/savings'),
  _QAData(Icons.account_balance_wallet_outlined, 'Wallet', AppColors.textDark,
      '/wallet'),
  _QAData(
      Icons.smart_toy_outlined, 'Coach', _ExtraColors.purple, '/coach/chat'),
  _QAData(
      Icons.emoji_events_outlined, 'Rewards', _ExtraColors.amber, '/rewards'),
  _QAData(Icons.storefront_outlined, 'Marketplace', _ExtraColors.blue,
      '/marketplace'),
  _QAData(
      Icons.bar_chart_outlined, 'Stability', _ExtraColors.green, '/stability'),
];

// ════════════════════════════════════════════════════════════
//  HomePage
// ════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _balVisible = true;
  final int _streak = 1;
  late final WalletService _walletService;

  // Useful defaults keep the dashboard productive on first launch.
  final List<_QAData> _activeActions = [
    _allActions[0],
    _allActions[1],
    _allActions[2],
    _allActions[6],
  ];

  double get _balance => _walletService.gudeEarningsBalance;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService()..initFromOnboarding();
    _walletService.addListener(_refreshWallet);
  }

  void _refreshWallet() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _walletService.removeListener(_refreshWallet);
    super.dispose();
  }

  int get _daysLeft {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day;
  }

  String get _greetingLine {
    final name = UserRoleService().userName;
    final hour = DateTime.now().hour;
    final time = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final first = name.isNotEmpty ? ', ${name.split(' ').first}' : '';
    return '$time$first ';
  }

  void _openCustomise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomiseSheet(
        all: _allActions,
        active: _activeActions,
        onSave: (updated) => setState(() {
          _activeActions
            ..clear()
            ..addAll(updated);
        }),
      ),
    );
  }

  void _showAddExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExpenseSheet(
        onSave: (amount, category, note) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Logged: R${amount.toStringAsFixed(2)} on $category'),
              backgroundColor: _ExtraColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  void _handleAction(_QAData qa) {
    if (qa.label == 'Log Expense') {
      _showAddExpense();
    } else if (qa.route != null) {
      context.push(qa.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: Row(children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    'assets/images/gude_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _greetingLine,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ]),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _ExtraColors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  const Text('⚡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('$_streak',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _ExtraColors.amber)),
                ]),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => context.push('/profile'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // ── 1. Account card ────────────────────────────
                _AccountCard(
                  balance: _balance,
                  points: _walletService.gudePoints,
                  daysLeft: _daysLeft,
                  visible: _balVisible,
                  onToggle: () => setState(() => _balVisible = !_balVisible),
                  onTap: () => context.push('/wallet'),
                ),

                const SizedBox(height: 16),

                // ── 2. Quick Actions ───────────────────────────────────
                _QuickActionsSection(
                  actions: _activeActions,
                  onCustomise: _openCustomise,
                  onAction: _handleAction,
                ),

                const SizedBox(height: 16),

                // ── 3. Tips & Challenges ───────────────────────────────
                _TipsAndChallenges(
                  onTap: () => context.push('/challenges'),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),

      // ── FABs — all same size ───────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'aibuddy',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () => context.push('/coach/chat'),
        icon: const Icon(Icons.auto_awesome_rounded, size: 20),
        label: const Text('Ask Gude',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Account Card
// ════════════════════════════════════════════════════════════
class _AccountCard extends StatelessWidget {
  final double balance;
  final int points;
  final int daysLeft;
  final bool visible;
  final VoidCallback onToggle, onTap;

  const _AccountCard({
    required this.balance,
    required this.points,
    required this.daysLeft,
    required this.visible,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF9B0010)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
        children: [
          // "My Account -->"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Gude Wallet',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2),
              ),
              SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 12),

          // Balance + eye icon — centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                visible ? 'R ${balance.toStringAsFixed(2)}' : 'R ••••••',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white60,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Earned from your Gude sales and services',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),

          const SizedBox(height: 8),

          // Days left pill — centered
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              '⏳  $daysLeft days left this month',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD166).withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.5)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 15),
              const SizedBox(width: 5),
              Text('$points Gude Points',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Tips & Challenges
// ════════════════════════════════════════════════════════════
class _TipsAndChallenges extends StatelessWidget {
  final VoidCallback onTap;
  const _TipsAndChallenges({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TIPS & CHALLENGES',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        _TipCard(
          emoji: '💰',
          title: 'Survive till Month-End',
          subtitle: 'Budget R104/day for the next 12 days and make it.',
          color: AppColors.primary,
          onTap: onTap,
        ),
        const SizedBox(height: 10),
        _TipCard(
          emoji: '🚀',
          title: 'Save R500 This Month',
          subtitle: 'Small daily cuts add up — skip one takeout a week.',
          color: _ExtraColors.green,
          onTap: onTap,
        ),
        const SizedBox(height: 10),
        _TipCard(
          emoji: '📦',
          title: 'The Leftover Challenge',
          subtitle:
              'Aim to have at least R200 left on the last day of the month.',
          color: _ExtraColors.blue,
          onTap: onTap,
        ),
        const SizedBox(height: 10),
        _TipCard(
          emoji: '⏳',
          title: 'NSFAS Delay Survival',
          subtitle: 'Emergency budget mode — cut to R30/day on food.',
          color: _ExtraColors.amber,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TipCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ],
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textGrey, height: 1.4)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: color, size: 20),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Quick Actions Section
// ════════════════════════════════════════════════════════════
class _QuickActionsSection extends StatelessWidget {
  final List<_QAData> actions;
  final VoidCallback onCustomise;
  final void Function(_QAData) onAction;

  const _QuickActionsSection({
    required this.actions,
    required this.onCustomise,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quick Actions',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            GestureDetector(
              onTap: onCustomise,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.tune_rounded, size: 13, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Customise',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (actions.isEmpty)
          GestureDetector(
            onTap: onCustomise,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03), blurRadius: 6)
                ],
              ),
              child: Column(children: [
                Icon(Icons.add_circle_outline,
                    size: 32, color: AppColors.textGrey.withOpacity(0.5)),
                const SizedBox(height: 8),
                const Text('Tap to add quick actions',
                    style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
              ]),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: actions.map((qa) {
              return _QuickActionTile(
                icon: qa.icon,
                label: qa.label,
                color: qa.color,
                onTap: () => onAction(qa),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.20)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 7),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Customise Quick Actions Sheet
// ════════════════════════════════════════════════════════════
class _CustomiseSheet extends StatefulWidget {
  final List<_QAData> all;
  final List<_QAData> active;
  final void Function(List<_QAData>) onSave;

  const _CustomiseSheet(
      {required this.all, required this.active, required this.onSave});

  @override
  State<_CustomiseSheet> createState() => _CustomiseSheetState();
}

class _CustomiseSheetState extends State<_CustomiseSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.active.map((a) => a.label).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.84),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Customise Quick Actions',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('Select the actions you want on your home screen',
            style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: widget.all.length,
            itemBuilder: (_, index) {
              final qa = widget.all[index];
              final isOn = _selected.contains(qa.label);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: qa.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(qa.icon, color: qa.color, size: 20),
                ),
                title: Text(qa.label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                trailing: Switch(
                  value: isOn,
                  activeColor: AppColors.primary,
                  onChanged: (_) => setState(() {
                    isOn ? _selected.remove(qa.label) : _selected.add(qa.label);
                  }),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final result =
                  widget.all.where((a) => _selected.contains(a.label)).toList();
              widget.onSave(result);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Add Expense Modal
// ════════════════════════════════════════════════════════════
const _expenseCategories = [
  ('Food', Icons.restaurant_menu_outlined, AppColors.primary),
  ('Transport', Icons.directions_bus_outlined, Color(0xFF3B82F6)),
  ('Data/Airtime', Icons.wifi_outlined, Color(0xFF8B5CF6)),
  ('Entertainment', Icons.sports_esports_outlined, Color(0xFFF59E0B)),
  ('Textbooks', Icons.menu_book_outlined, Color(0xFF10B981)),
  ('Other', Icons.more_horiz_outlined, AppColors.textGrey),
];

class _AddExpenseSheet extends StatefulWidget {
  final void Function(double amount, String category, String note) onSave;
  const _AddExpenseSheet({required this.onSave});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _category = 'Food';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Log Expense',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixText: 'R  ',
              prefixStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGrey),
              hintText: 'Amount',
              hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 20),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: AppColors.textGrey),
              items: _expenseCategories.map((c) {
                final (label, icon, color) = c;
                return DropdownMenuItem(
                  value: label,
                  child: Row(children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 10),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                  ]),
                );
              }).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(
            hintText: 'Note (optional)',
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
              if (amount <= 0) return;
              widget.onSave(amount, _category, _noteCtrl.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}
