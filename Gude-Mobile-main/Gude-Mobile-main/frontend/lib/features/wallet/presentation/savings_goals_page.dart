// lib/features/wallet/presentation/savings_goals_page.dart
// Enhanced Savings Goals — PDF §2.7
// Cards: "New Phone – R3000" style · Progress bar · Weekly target · Time remaining
// CTA: Add Goal · All original logic intact + enhanced UI

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE30613);
  static const dark      = Color(0xFF1A1A1A);
  static const grey      = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border    = Color(0xFFEEEEEE);
  static const green     = Color(0xFF10B981);
  static const amber     = Color(0xFFF59E0B);
  static const blue      = Color(0xFF3B82F6);
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
class _Goal {
  final String id, name, emoji;
  double saved, target;
  final Color color, colorDark;
  final List<_GoalTransaction> transactions;
  final double weeklyContribution; // how much user saves/week

  _Goal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.saved,
    required this.target,
    required this.color,
    required this.colorDark,
    required this.transactions,
    this.weeklyContribution = 200,
  });

  double get progress => (saved / target).clamp(0.0, 1.0);
  String get cardNumber =>
      '•••• •••• •••• ${id.hashCode.abs() % 9000 + 1000}';

  double get remaining => (target - saved).clamp(0, target);

  /// Weeks left at current weekly contribution rate
  int get weeksRemaining {
    if (weeklyContribution <= 0 || remaining <= 0) return 0;
    return (remaining / weeklyContribution).ceil();
  }

  /// Human-readable time remaining string
  String get timeRemainingLabel {
    if (progress >= 1.0) return 'Goal reached! 🎉';
    final weeks = weeksRemaining;
    if (weeks <= 0) return 'Almost there!';
    if (weeks == 1) return '~1 week left';
    if (weeks < 5) return '~$weeks weeks left';
    final months = (weeks / 4.3).round();
    return '~$months ${months == 1 ? 'month' : 'months'} left';
  }
}

class _GoalTransaction {
  final String label, date;
  final double amount;
  final bool isCredit;
  const _GoalTransaction(this.label, this.amount, this.isCredit, this.date);
}

// ─────────────────────────────────────────────
// SAVINGS GOALS PAGE
// ─────────────────────────────────────────────
class SavingsGoalsPage extends StatefulWidget {
  const SavingsGoalsPage({super.key});
  @override
  State<SavingsGoalsPage> createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends State<SavingsGoalsPage> {
  final List<_Goal> _goals = [
    _Goal(
      id: 'food',
      name: 'Food & Groceries',
      emoji: '🍎',
      saved: 650,
      target: 1200,
      color: _C.green,
      colorDark: const Color(0xFF065F46),
      weeklyContribution: 137.5,
      transactions: const [
        _GoalTransaction(
            'Woolworths Food', 120.00, false, 'Today, 11:30'),
        _GoalTransaction(
            'Pocket top-up', 300.00, true, 'Yesterday, 09:00'),
        _GoalTransaction('Pick n Pay', 230.00, false, 'Mon, 14:20'),
      ],
    ),
    _Goal(
      id: 'laptop',
      name: 'Laptop Savings',
      emoji: '💻',
      saved: 3200,
      target: 5200,
      color: _C.blue,
      colorDark: const Color(0xFF1E40AF),
      weeklyContribution: 800,
      transactions: const [
        _GoalTransaction(
            'Monthly contribution', 800.00, true, 'Mar 1, 08:00'),
        _GoalTransaction(
            'Monthly contribution', 800.00, true, 'Feb 1, 08:00'),
        _GoalTransaction(
            'Monthly contribution', 800.00, true, 'Jan 1, 08:00'),
      ],
    ),
    _Goal(
      id: 'phone',
      name: 'New Phone',
      emoji: '📱',
      saved: 800,
      target: 3000,
      color: _C.primary,
      colorDark: const Color(0xFF8B0000),
      weeklyContribution: 200,
      transactions: const [
        _GoalTransaction(
            'Initial deposit', 500.00, true, 'Mar 1, 09:00'),
        _GoalTransaction(
            'Weekly top-up', 200.00, true, 'Mar 8, 09:00'),
        _GoalTransaction(
            'Weekly top-up', 100.00, true, 'Mar 15, 09:00'),
      ],
    ),
    _Goal(
      id: 'rent',
      name: 'Accommodation',
      emoji: '🏠',
      saved: 2800,
      target: 4500,
      color: const Color(0xFF8B5CF6),
      colorDark: const Color(0xFF5B21B6),
      weeklyContribution: 500,
      transactions: const [
        _GoalTransaction(
            'Rent deposit top-up', 1000.00, true, 'Mar 5, 10:00'),
        _GoalTransaction('Pocket to wallet transfer', 200.00, false,
            'Feb 28, 16:00'),
        _GoalTransaction(
            'Rent deposit top-up', 1000.00, true, 'Feb 5, 10:00'),
      ],
    ),
    _Goal(
      id: 'emergency',
      name: 'Emergency Fund',
      emoji: '🆘',
      saved: 500,
      target: 3000,
      color: _C.amber,
      colorDark: const Color(0xFF92400E),
      weeklyContribution: 100,
      transactions: const [
        _GoalTransaction(
            'First contribution', 500.00, true, 'Mar 10, 09:00'),
      ],
    ),
  ];

  // ── Add Goal dialog (original logic + weekly contribution field) ──
  void _showAddGoalDialog() {
    final nameCtrl   = TextEditingController();
    final targetCtrl = TextEditingController();
    final weeklyCtrl = TextEditingController();
    final emojis = ['🎯', '📱', '✈️', '🎓', '🏋️', '🎮', '👟', '🚗'];
    String selectedEmoji = '🎯';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Add New Goal',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Emoji picker
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Choose an emoji',
                    style: TextStyle(
                        fontSize: 12,
                        color: _C.grey,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: emojis.map((e) {
                  final sel = e == selectedEmoji;
                  return GestureDetector(
                    onTap: () => setDlg(() => selectedEmoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: sel
                            ? _C.primary.withOpacity(0.12)
                            : _C.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel ? _C.primary : _C.border,
                            width: sel ? 1.5 : 1),
                      ),
                      child: Center(
                          child: Text(e,
                              style: const TextStyle(fontSize: 20))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // Goal name
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Goal name (e.g. New Phone)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _C.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Target amount
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target amount (R)',
                  prefixText: 'R ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _C.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Weekly contribution
              TextField(
                controller: weeklyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weekly contribution (R)',
                  helperText: 'We\'ll calculate time to reach goal',
                  prefixText: 'R ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _C.primary, width: 1.5),
                  ),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: _C.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final name   = nameCtrl.text.trim();
                final target = double.tryParse(targetCtrl.text) ?? 0;
                final weekly = double.tryParse(weeklyCtrl.text) ?? 200;
                if (name.isEmpty || target <= 0) return;

                final colors = [
                  _C.primary, _C.blue, _C.green,
                  _C.amber, const Color(0xFF8B5CF6),
                  const Color(0xFFEC4899),
                ];
                final colorDarks = [
                  const Color(0xFF8B0000),
                  const Color(0xFF1E40AF),
                  const Color(0xFF065F46),
                  const Color(0xFF92400E),
                  const Color(0xFF5B21B6),
                  const Color(0xFF9D174D),
                ];
                final idx = _goals.length % colors.length;

                setState(() => _goals.add(_Goal(
                      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      emoji: selectedEmoji,
                      saved: 0,
                      target: target,
                      color: colors[idx],
                      colorDark: colorDarks[idx],
                      weeklyContribution: weekly,
                      transactions: [],
                    )));
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$selectedEmoji "$name" goal created!'),
                    backgroundColor: _C.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: const Text('Add Goal',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openPocketDetail(_Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _GoalPocketPage(goal: goal)),
    );
  }

  // ── Add Funds dialog (original logic intact) ──────────────
  void _addFunds(_Goal goal) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Text(goal.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Add to ${goal.name}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Amount (R)',
              prefixText: 'R ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: _C.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Quick amount chips
          Row(children: [
            for (final amt in ['50', '100', '200', '500'])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => ctrl.text = amt,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: goal.color.withOpacity(0.3)),
                    ),
                    child: Text('R$amt',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: goal.color)),
                  ),
                ),
              ),
          ]),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _C.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goal.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final amount = double.tryParse(ctrl.text) ?? 0;
              if (amount <= 0) return;
              setState(() {
                goal.saved =
                    (goal.saved + amount).clamp(0, goal.target);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    '${goal.emoji} R${amount.toStringAsFixed(0)} added to ${goal.name}!'),
                backgroundColor: _C.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ));
            },
            child: const Text('Add Funds',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSaved  = _goals.fold<double>(0, (s, g) => s + g.saved);
    final totalTarget = _goals.fold<double>(0, (s, g) => s + g.target);
    final goalsReached = _goals.where((g) => g.progress >= 1.0).length;

    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _C.dark),
            onPressed: () => context.pop()),
        title: const Text('Savings Goals',
            style: TextStyle(
                color: _C.dark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        actions: [
          // Add Goal CTA in app bar
          TextButton.icon(
            onPressed: _showAddGoalDialog,
            icon: const Icon(Icons.add_circle_outline,
                color: _C.primary, size: 18),
            label: const Text('Add Goal',
                style: TextStyle(
                    color: _C.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ── Overall summary card ───────────────────────────
          _OverallSummaryCard(
            totalSaved: totalSaved,
            totalTarget: totalTarget,
            goalsCount: _goals.length,
            goalsReached: goalsReached,
          ),

          const SizedBox(height: 14),

          // ── Weekly savings insight ─────────────────────────
          _WeeklySavingsCard(goals: _goals),

          const SizedBox(height: 14),

          // ── Section label ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Goals',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _C.dark)),
              GestureDetector(
                onTap: _showAddGoalDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _C.primary.withOpacity(0.25)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.add, size: 13, color: _C.primary),
                    SizedBox(width: 4),
                    Text('Add Goal',
                        style: TextStyle(
                            fontSize: 11,
                            color: _C.primary,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Goal cards ─────────────────────────────────────
          ...(_goals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GoalCard(
                  goal: goal,
                  onAddFunds: () => _addFunds(goal),
                  onOpenPocket: () => _openPocketDetail(goal),
                ),
              ))),

          const SizedBox(height: 40),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _C.primary,
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Overall Summary Card
// ─────────────────────────────────────────────
class _OverallSummaryCard extends StatelessWidget {
  final double totalSaved, totalTarget;
  final int goalsCount, goalsReached;

  const _OverallSummaryCard({
    required this.totalSaved,
    required this.totalTarget,
    required this.goalsCount,
    required this.goalsReached,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTarget > 0
        ? (totalSaved / totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Savings',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  SizedBox(height: 2),
                ]),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('$goalsCount goals',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              if (goalsReached > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _C.green.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('$goalsReached reached 🎉',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'R${totalSaved.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(_C.green),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Saved: R${totalSaved.toStringAsFixed(0)}',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11)),
          Text('Target: R${totalTarget.toStringAsFixed(0)}',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Weekly Savings Insight Card
// ─────────────────────────────────────────────
class _WeeklySavingsCard extends StatelessWidget {
  final List<_Goal> goals;
  const _WeeklySavingsCard({required this.goals});

  @override
  Widget build(BuildContext context) {
    final totalWeekly =
        goals.fold<double>(0, (s, g) => s + g.weeklyContribution);
    final nearestGoal = goals
        .where((g) => g.progress < 1.0)
        .fold<_Goal?>(null, (prev, g) {
      if (prev == null) return g;
      return g.weeksRemaining < prev.weeksRemaining ? g : prev;
    });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8)
        ],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: _C.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.trending_up_rounded,
              color: _C.green, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly Saving Rate',
                    style: TextStyle(fontSize: 11, color: _C.grey)),
                Text('R${totalWeekly.toStringAsFixed(0)} / week',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _C.dark)),
                if (nearestGoal != null)
                  Text(
                    '${nearestGoal.emoji} ${nearestGoal.name}: ${nearestGoal.timeRemainingLabel}',
                    style: const TextStyle(
                        fontSize: 11, color: _C.grey),
                  ),
              ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _C.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${goals.where((g) => g.progress < 1.0).length} active',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.green),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Goal Card — "New Phone – R3000" style (PDF §2.7)
// Shows: progress bar · weekly target · time remaining
// ─────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final _Goal goal;
  final VoidCallback onAddFunds, onOpenPocket;
  const _GoalCard(
      {required this.goal,
      required this.onAddFunds,
      required this.onOpenPocket});

  @override
  Widget build(BuildContext context) {
    final pct  = (goal.progress * 100).toInt();
    final done = goal.progress >= 1.0;

    return GestureDetector(
      onTap: onOpenPocket,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: done
                  ? goal.color.withOpacity(0.4)
                  : _C.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // ── Header row ──────────────────────────────────
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Center(
                  child: Text(goal.emoji,
                      style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── "New Phone – R3000" label style ─────────
                    Text(
                      '${goal.name} – R${goal.target.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _C.dark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.access_time_rounded,
                          size: 11, color: _C.grey),
                      const SizedBox(width: 3),
                      Text(goal.timeRemainingLabel,
                          style: TextStyle(
                              fontSize: 11,
                              color: done ? goal.color : _C.grey,
                              fontWeight: done
                                  ? FontWeight.w700
                                  : FontWeight.normal)),
                    ]),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('R${goal.saved.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: goal.color)),
              Text('of R${goal.target.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 10, color: _C.grey)),
            ]),
          ]),

          const SizedBox(height: 14),

          // ── Progress bar + % ─────────────────────────────
          Row(children: [
            Expanded(
              child: Column(children: [
                // ── PDF-style bar ─────────────────────────────
                Stack(children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: goal.progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            goal.color.withOpacity(0.7),
                            goal.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('R${goal.remaining.toStringAsFixed(0)} to go',
                        style: const TextStyle(
                            fontSize: 10, color: _C.grey)),
                    Text('R${goal.remaining.toStringAsFixed(0)} remaining',
                        style: const TextStyle(
                            fontSize: 10, color: _C.grey)),
                  ],
                ),
              ]),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('$pct%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: goal.color)),
            ),
          ]),

          const SizedBox(height: 12),

          // ── Weekly target + time remaining row (PDF §2.7) ─
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: goal.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: goal.color.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: goal.color),
                  const SizedBox(width: 5),
                  Text(
                    'Weekly target: R${goal.weeklyContribution.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: goal.color),
                  ),
                ]),
                Row(children: [
                  Icon(Icons.hourglass_bottom_rounded,
                      size: 13, color: goal.color),
                  const SizedBox(width: 4),
                  Text(
                    done
                        ? '🎉 Done!'
                        : goal.timeRemainingLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: goal.color),
                  ),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Action buttons ───────────────────────────────
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenPocket,
                icon: Icon(Icons.credit_card_outlined,
                    size: 15, color: goal.color),
                label: Text('View Pocket',
                    style: TextStyle(
                        color: goal.color, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8),
                  side: BorderSide(
                      color: goal.color.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: done ? null : onAddFunds,
                icon: const Icon(Icons.add,
                    size: 15, color: Colors.white),
                label: const Text('Add Funds',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      done ? _C.grey : goal.color,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GOAL POCKET PAGE — original logic fully intact
// ─────────────────────────────────────────────
class _GoalPocketPage extends StatelessWidget {
  final _Goal goal;
  const _GoalPocketPage({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: _C.dark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(goal.name,
            style: const TextStyle(
                color: _C.dark,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

          // ── Pocket Card (styled like main wallet card) ──
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [goal.color, goal.colorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: goal.color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Stack(children: [
              Positioned(
                top: -30, right: -20,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06)),
                ),
              ),
              Positioned(
                bottom: -40, right: 40,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Text(goal.emoji,
                              style: const TextStyle(
                                  fontSize: 16)),
                          const SizedBox(width: 4),
                          const Text('G',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                        ]),
                      ),
                      Row(children: [
                        Container(
                            width: 26, height: 26,
                            decoration: const BoxDecoration(
                                color: Color(0xFFEB001B),
                                shape: BoxShape.circle)),
                        Transform.translate(
                          offset: const Offset(-10, 0),
                          child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF79E1B)
                                      .withOpacity(0.9),
                                  shape: BoxShape.circle)),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'R${goal.saved.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of R${goal.target.toStringAsFixed(2)} goal',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(goal.cardNumber,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Savings Pocket',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11)),
                      Text(
                          '${(goal.progress * 100).toInt()}% complete',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11)),
                    ],
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Progress + time remaining ─────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: goal.color)),
                  Text(
                    'R${goal.remaining.toStringAsFixed(0)} remaining',
                    style: const TextStyle(
                        fontSize: 12, color: _C.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 10,
                  backgroundColor: goal.color.withOpacity(0.12),
                  valueColor:
                      AlwaysStoppedAnimation(goal.color),
                ),
              ),
              const SizedBox(height: 10),
              // ── Time remaining + weekly target (PDF §2.7) ─
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 16, color: goal.color),
                      const SizedBox(height: 4),
                      Text(
                        'R${goal.weeklyContribution.toStringAsFixed(0)}/wk',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: goal.color),
                      ),
                      const Text('Weekly target',
                          style: TextStyle(
                              fontSize: 9, color: _C.grey)),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(children: [
                      Icon(Icons.hourglass_bottom_rounded,
                          size: 16, color: goal.color),
                      const SizedBox(height: 4),
                      Text(
                        goal.timeRemainingLabel,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: goal.color),
                        textAlign: TextAlign.center,
                      ),
                      const Text('Time remaining',
                          style: TextStyle(
                              fontSize: 9, color: _C.grey)),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Stat cells ────────────────────────────────────
          Row(children: [
            Expanded(
                child: _StatCell(
                    label: 'Saved',
                    value:
                        'R${goal.saved.toStringAsFixed(0)}',
                    color: goal.color)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCell(
                    label: 'Target',
                    value:
                        'R${goal.target.toStringAsFixed(0)}',
                    color: _C.dark)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCell(
                    label: 'Progress',
                    value:
                        '${(goal.progress * 100).toInt()}%',
                    color: goal.color)),
          ]),

          const SizedBox(height: 20),

          // ── Transactions ──────────────────────────────────
          const Text('Pocket Activity',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.dark)),
          const SizedBox(height: 10),

          goal.transactions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Column(children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: _C.border),
                      SizedBox(height: 10),
                      Text('No activity yet',
                          style: TextStyle(
                              color: _C.grey, fontSize: 14)),
                    ]),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.border),
                  ),
                  child: ListView.separated(
                    physics:
                        const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: goal.transactions.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: Color(0xFFF0F0F0)),
                    itemBuilder: (_, i) {
                      final tx = goal.transactions[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: tx.isCredit
                                  ? _C.green.withOpacity(0.12)
                                  : _C.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tx.isCredit
                                  ? Icons.add_rounded
                                  : Icons.remove_rounded,
                              size: 18,
                              color: tx.isCredit
                                  ? _C.green
                                  : _C.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              Text(tx.label,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _C.dark)),
                              Text(tx.date,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _C.grey)),
                            ]),
                          ),
                          Text(
                            '${tx.isCredit ? '+' : '-'}R${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: tx.isCredit
                                    ? _C.green
                                    : _C.primary),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STAT CELL (original preserved)
// ─────────────────────────────────────────────
class _StatCell extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCell(
      {required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: _C.grey)),
        ]),
      );
}