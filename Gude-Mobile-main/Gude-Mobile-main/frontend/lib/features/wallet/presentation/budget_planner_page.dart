// lib/features/wallet/presentation/budget_planner_page.dart
// Enhanced Budget Planner — PDF §2.6
// Category bars (Food R800/R1200 · Transport R300/R500) · Visual progress bars
// "Adjust Budget" CTA · Weekly breakdown · Spend insights · All original code intact

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/state/financial_health.dart';

// ─────────────────────────────────────────────
// COLORS (Gude palette)
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
// DATA
// ─────────────────────────────────────────────
class _BudgetItem {
  final String name;
  final IconData icon;
  final Color color;
  double allocated;
  double spent;

  _BudgetItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.allocated,
    required this.spent,
  });

  double get progress => (spent / allocated).clamp(0.0, 1.0);
  bool   get isOver   => spent > allocated;
  double get remaining => (allocated - spent).clamp(0, double.infinity);

  // Weekly target derived from monthly allocated
  double get weeklyTarget => allocated / 4;
}

// ─────────────────────────────────────────────
// BUDGET PLANNER PAGE
// ─────────────────────────────────────────────
class BudgetPlannerPage extends StatefulWidget {
  const BudgetPlannerPage({super.key});
  @override
  State<BudgetPlannerPage> createState() => _BudgetPlannerPageState();
}

class _BudgetPlannerPageState extends State<BudgetPlannerPage>
    with SingleTickerProviderStateMixin {
  final double _monthlyBudget = 3000;
  bool _adjustMode = false; // toggle between view and adjust
  late TabController _tabCtrl;

  final List<_BudgetItem> _items = [
    _BudgetItem(
        name: 'Food',
        icon: Icons.restaurant_menu_outlined,
        color: _C.primary,
        allocated: 800,
        spent: 650),
    _BudgetItem(
        name: 'Transport',
        icon: Icons.directions_bus_outlined,
        color: _C.blue,
        allocated: 500,
        spent: 420),
    _BudgetItem(
        name: 'Data',
        icon: Icons.wifi_outlined,
        color: const Color(0xFF8B5CF6),
        allocated: 200,
        spent: 180),
    _BudgetItem(
        name: 'Entertainment',
        icon: Icons.sports_esports_outlined,
        color: _C.amber,
        allocated: 300,
        spent: 380),
    _BudgetItem(
        name: 'Textbooks',
        icon: Icons.menu_book_outlined,
        color: _C.green,
        allocated: 300,
        spent: 150),
    _BudgetItem(
        name: 'Savings',
        icon: Icons.savings_outlined,
        color: _C.blue,
        allocated: 200,
        spent: 50),
  ];

  double get _totalAllocated =>
      _items.fold(0, (s, i) => s + i.allocated);
  double get _totalSpent =>
      _items.fold(0, (s, i) => s + i.spent);
  double get _remaining =>
      (_monthlyBudget - _totalAllocated).clamp(0, _monthlyBudget);
  int get _overCount => _items.where((i) => i.isOver).length;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _saveBudget() {
    FinancialHealth.monthlyBudget = _monthlyBudget;
    setState(() => _adjustMode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Budget saved!'),
        backgroundColor: _C.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Budget Planner',
          style: TextStyle(
              color: _C.dark, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          // ── "Adjust Budget" CTA in app bar ───────────────
          TextButton(
            onPressed: () => setState(() => _adjustMode = !_adjustMode),
            style: TextButton.styleFrom(
              foregroundColor:
                  _adjustMode ? _C.green : _C.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
            ),
            child: Text(
              _adjustMode ? 'Done' : 'Adjust Budget',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: _C.dark,
              unselectedLabelColor: _C.grey,
              indicatorColor: _C.primary,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: '📊  Overview'),
                Tab(text: '📅  Weekly'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── TAB 1: Overview ──────────────────────────────
          _buildOverviewTab(),
          // ── TAB 2: Weekly ────────────────────────────────
          _buildWeeklyTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  Overview Tab
  // ═══════════════════════════════════════════
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [

        // ── Monthly hero card ──────────────────────────────
        _MonthlyHeroCard(
          monthlyBudget: _monthlyBudget,
          totalAllocated: _totalAllocated,
          totalSpent: _totalSpent,
          remaining: _remaining,
          overCount: _overCount,
        ),

        const SizedBox(height: 16),

        // ── Insights row ───────────────────────────────────
        _InsightsRow(
          items: _items,
          totalSpent: _totalSpent,
          monthlyBudget: _monthlyBudget,
        ),

        const SizedBox(height: 16),

        // ── Section header ─────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.dark),
            ),
            if (_adjustMode)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _C.primary.withOpacity(0.25)),
                ),
                child: const Text('Drag sliders to adjust',
                    style: TextStyle(
                        fontSize: 10,
                        color: _C.primary,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Category bars ──────────────────────────────────
        ..._items.map(
          (item) => _adjustMode
              ? _BudgetSliderCard(
                  item: item,
                  maxBudget: _monthlyBudget,
                  onChanged: (v) =>
                      setState(() => item.allocated = v),
                )
              : _CategoryBarCard(item: item),
        ),

        const SizedBox(height: 8),

        // ── Save / Adjust button ───────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _adjustMode ? _C.green : _C.dark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _adjustMode
                ? _saveBudget
                : () => setState(() => _adjustMode = true),
            child: Text(
              _adjustMode ? 'Save Budget ✅' : 'Adjust Budget',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  // ═══════════════════════════════════════════
  //  Weekly Tab
  // ═══════════════════════════════════════════
  Widget _buildWeeklyTab() {
    final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
    // Simulated weekly spent (percent of monthly)
    final weeklySpentFractions = [0.35, 0.28, 0.22, 0.15];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Weekly summary card ────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10)
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly Budget Target',
                    style:
                        TextStyle(fontSize: 12, color: _C.grey)),
                const SizedBox(height: 4),
                Text(
                  'R${(_monthlyBudget / 4).toStringAsFixed(0)} / week',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _C.dark,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: weeks.asMap().entries.map((e) {
                    final weeklyBudget = _monthlyBudget / 4;
                    final weekSpent =
                        _totalSpent * weeklySpentFractions[e.key];
                    final pct = (weekSpent / weeklyBudget)
                        .clamp(0.0, 1.0);
                    final isOver = weekSpent > weeklyBudget;
                    final color = isOver ? _C.primary : _C.green;

                    return Expanded(
                      child: Column(children: [
                        Text(e.value,
                            style: const TextStyle(
                                fontSize: 9,
                                color: _C.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          height: 60,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 3),
                          decoration: BoxDecoration(
                            color: _C.lightGrey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: pct,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.85),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R${weekSpent.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isOver
                                  ? _C.primary
                                  : _C.dark),
                        ),
                      ]),
                    );
                  }).toList(),
                ),
              ]),
        ),

        const SizedBox(height: 16),

        const Text('Weekly Category Targets',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.dark)),
        const SizedBox(height: 10),

        // ── Category weekly cards ──────────────────────────
        ..._items.map((item) => _WeeklyCategoryCard(item: item)),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Monthly Hero Card
// ─────────────────────────────────────────────
class _MonthlyHeroCard extends StatelessWidget {
  final double monthlyBudget, totalAllocated, totalSpent, remaining;
  final int overCount;

  const _MonthlyHeroCard({
    required this.monthlyBudget,
    required this.totalAllocated,
    required this.totalSpent,
    required this.remaining,
    required this.overCount,
  });

  @override
  Widget build(BuildContext context) {
    final spentPct = (totalSpent / monthlyBudget).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFE30613), Color(0xFFB0000E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFE30613).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Monthly Budget',
                style:
                    TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              'R${monthlyBudget.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1),
            ),
            const SizedBox(height: 14),

            // ── Spent progress bar ─────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: spentPct,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Spent: R${totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
                Text(
                    'Remaining: R${remaining.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),

            if (overCount > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⚠️  $overCount ${overCount == 1 ? 'category' : 'categories'} over budget',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Insights Row (3 stat tiles)
// ─────────────────────────────────────────────
class _InsightsRow extends StatelessWidget {
  final List<_BudgetItem> items;
  final double totalSpent, monthlyBudget;

  const _InsightsRow({
    required this.items,
    required this.totalSpent,
    required this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    final biggest =
        items.reduce((a, b) => a.spent > b.spent ? a : b);
    final saved = items
        .where((i) => !i.isOver)
        .fold<double>(0, (s, i) => s + (i.allocated - i.spent));

    return Row(children: [
      _StatTile(
        label: 'Biggest Spend',
        value: biggest.name,
        sub: 'R${biggest.spent.toStringAsFixed(0)}',
        icon: biggest.icon,
        color: biggest.color,
      ),
      const SizedBox(width: 10),
      _StatTile(
        label: 'Saved so far',
        value: 'R${saved.toStringAsFixed(0)}',
        sub: 'under budget',
        icon: Icons.savings_outlined,
        color: _C.green,
      ),
      const SizedBox(width: 10),
      _StatTile(
        label: 'Budget Used',
        value: '${(totalSpent / monthlyBudget * 100).toInt()}%',
        sub: 'of monthly',
        icon: Icons.pie_chart_outline,
        color: _C.blue,
      ),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6)
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: _C.grey),
                  maxLines: 1),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 9, color: _C.grey),
                  maxLines: 1),
            ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Category Bar Card (View mode — PDF §2.6 style)
// Shows: Food: R650 / R800  with visual progress bar
// ─────────────────────────────────────────────
class _CategoryBarCard extends StatelessWidget {
  final _BudgetItem item;
  const _CategoryBarCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final pct  = item.progress;
    final over = item.isOver;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: over
              ? _C.primary.withOpacity(0.35)
              : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header row ────────────────────────────────────
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.dark)),
                  // ── PDF-style "R650 / R800" label ─────────
                  Text(
                    'R${item.spent.toStringAsFixed(0)} / R${item.allocated.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: over ? _C.primary : _C.grey),
                  ),
                ]),
          ),

          // ── Status badge ──────────────────────────────────
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (over)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: _C.primary,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('Over',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: _C.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  'R${item.remaining.toStringAsFixed(0)} left',
                  style: const TextStyle(
                      fontSize: 9,
                      color: _C.green,
                      fontWeight: FontWeight.w700),
                ),
              ),
          ]),
        ]),

        const SizedBox(height: 10),

        // ── Visual progress bar (PDF §2.6) ────────────────
        Stack(
          children: [
            // Background track
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Filled portion
            FractionallySizedBox(
              widthFactor: pct,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: over ? _C.primary : item.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ── Percentage row ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(pct * 100).toInt()}% used',
              style: TextStyle(
                  fontSize: 10,
                  color: over ? _C.primary : _C.grey,
                  fontWeight: over
                      ? FontWeight.w600
                      : FontWeight.normal),
            ),
            Text(
              'Weekly: R${item.weeklyTarget.toStringAsFixed(0)}/wk',
              style: const TextStyle(
                  fontSize: 10, color: _C.grey),
            ),
          ],
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Budget Slider Card (Adjust mode) — original logic preserved
// ─────────────────────────────────────────────
class _BudgetSliderCard extends StatelessWidget {
  final _BudgetItem item;
  final double maxBudget;
  final ValueChanged<double> onChanged;

  const _BudgetSliderCard({
    required this.item,
    required this.maxBudget,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = item.isOver;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isOver
                ? const Color(0xFFEF4444).withOpacity(0.35)
                : const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Name row ────────────────────────────────────
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
          ),
          // Allocated amount badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'R${item.allocated.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: item.color),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        // ── ONE slider only ────────────────────────────
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: item.color,
            inactiveTrackColor: item.color.withOpacity(0.15),
            thumbColor: item.color,
            overlayColor: item.color.withOpacity(0.12),
            trackHeight: 5,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 9),
          ),
          child: Slider(
            value: item.allocated.clamp(0, maxBudget),
            min: 0,
            max: maxBudget,
            divisions: (maxBudget / 50).round(),
            onChanged: onChanged,
          ),
        ),

        // ── Spent indicator ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: R${item.spent.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 11,
                  color: isOver
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF888888),
                  fontWeight:
                      isOver ? FontWeight.w600 : FontWeight.normal),
            ),
            if (isOver)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('Over budget',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Weekly Category Card — shows weekly target + time remaining
// ─────────────────────────────────────────────
class _WeeklyCategoryCard extends StatelessWidget {
  final _BudgetItem item;
  const _WeeklyCategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final weeklyTarget = item.weeklyTarget;
    // Simulate weekly spent as 25% of monthly spent
    final weeklySpent  = item.spent * 0.25;
    final pct = (weeklySpent / weeklyTarget).clamp(0.0, 1.0);
    final over = weeklySpent > weeklyTarget;
    // Weeks remaining in month (simulated)
    const weeksLeft = 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6)
        ],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(item.icon, size: 18, color: item.color),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.dark)),
                    Text(
                      'R${weeklySpent.toStringAsFixed(0)} / R${weeklyTarget.toStringAsFixed(0)}/wk',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: over ? _C.primary : _C.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Weekly progress bar
                Stack(children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: over ? _C.primary : item.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(pct * 100).toInt()}% this week',
                        style: const TextStyle(
                            fontSize: 10, color: _C.grey)),
                    Text(
                      '$weeksLeft weeks remaining',
                      style: const TextStyle(
                          fontSize: 10, color: _C.grey),
                    ),
                  ],
                ),
              ]),
        ),
      ]),
    );
  }
}