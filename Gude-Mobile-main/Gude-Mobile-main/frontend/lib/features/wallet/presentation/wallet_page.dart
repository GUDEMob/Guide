// lib/features/wallet/presentation/wallet_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/wallet_service.dart';

// ── Colours ─────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const green = Color(0xFF10B981);
}

// ── UI model ─────────────────────────────────────────────────
class _PocketUI {
  final String id;
  final String name, emoji, cardNumber, expiry;
  final double balance, income, spent;
  final Color cardColor, cardColorEnd;
  final bool isMainAccount;
  final List<_Tx> transactions;

  _PocketUI({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cardNumber,
    required this.expiry,
    required this.balance,
    required this.cardColor,
    required this.cardColorEnd,
    required this.income,
    required this.spent,
    this.isMainAccount = false,
    this.transactions = const [],
  });
}

// ── Transaction UI model ─────────────────────────────────────
class _Tx {
  final String label, date;
  final double amount;
  final bool isCredit;
  final IconData icon;
  final String? fromName;
  final String? toName;

  _Tx(
    this.label,
    this.amount,
    this.isCredit,
    this.date,
    this.icon, {
    this.fromName,
    this.toName,
  });
}

// ── Adapter ──────────────────────────────────────────────────
_PocketUI _adaptPocket(Pocket pocket) {
  double income = 0;
  double spent = 0;
  for (var tx in pocket.transactions) {
    if (tx.isCredit)
      income += tx.amount;
    else
      spent += tx.amount;
  }

  final transactions = pocket.transactions.map((tx) {
    String? fromName;
    String? toName;
    IconData icon;
    final lbl = tx.label;

    if (tx.isCredit) {
      icon = Icons.arrow_downward_rounded;
      if (lbl.startsWith('Transfer from ')) {
        fromName = lbl.replaceFirst('Transfer from ', '');
        toName = '${pocket.emoji} ${pocket.name}';
      } else if (lbl.startsWith('From Main Account')) {
        fromName = '🏦 Main Account';
        toName = '${pocket.emoji} ${pocket.name}';
      } else if (lbl.startsWith('Return from ')) {
        fromName = lbl.replaceFirst('Return from ', '');
        toName = '${pocket.emoji} ${pocket.name}';
      } else if (lbl.startsWith('Monthly Income')) {
        fromName = 'Income';
        toName = '${pocket.emoji} ${pocket.name}';
      } else {
        fromName = '—';
        toName = '${pocket.emoji} ${pocket.name}';
      }
    } else {
      icon = Icons.arrow_upward_rounded;
      if (lbl.startsWith('Transfer to ')) {
        final other = lbl
            .replaceFirst('Transfer to ', '')
            .replaceAll(RegExp(r' pocket$'), '');
        fromName = '${pocket.emoji} ${pocket.name}';
        toName = other;
      } else if (lbl.startsWith('Returned to Main Account')) {
        fromName = '${pocket.emoji} ${pocket.name}';
        toName = '🏦 Main Account';
      } else {
        fromName = '${pocket.emoji} ${pocket.name}';
        toName = '—';
      }
    }

    return _Tx(
      lbl,
      tx.amount,
      tx.isCredit,
      _formatDate(tx.date),
      icon,
      fromName: fromName,
      toName: toName,
    );
  }).toList();

  final last4 = pocket.id.length >= 4
      ? pocket.id.substring(pocket.id.length - 4)
      : pocket.id.padLeft(4, '0');

  return _PocketUI(
    id: pocket.id,
    name: pocket.name,
    emoji: pocket.emoji,
    cardNumber: '•••• •••• •••• $last4',
    expiry: '12/26',
    balance: pocket.balance,
    cardColor: pocket.color,
    cardColorEnd: pocket.color.withOpacity(0.7),
    income: income,
    spent: spent,
    isMainAccount: pocket.isMainAccount,
    transactions: transactions,
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  if (date.day == now.day && date.month == now.month && date.year == now.year) {
    return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else if (date.day == now.day - 1 &&
      date.month == now.month &&
      date.year == now.year) {
    return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else {
    return '${date.day}/${date.month}/${date.year}, '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _Cat {
  final String name;
  final double spent, budget;
  final Color color;
  final IconData icon;
  const _Cat(this.name, this.spent, this.budget, this.color, this.icon);
  bool get isOver => spent > budget;
}

// ════════════════════════════════════════════════════════════════
//  WalletPage
// ════════════════════════════════════════════════════════════════
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late PageController _pageController;
  int _pocketIndex = 0;
  bool _balVisible = true;
  bool _showAllTx = false;
  double _planningBalance = 5000;
  late WalletService _walletService;
  List<_PocketUI> _pockets = [];

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
    _walletService.initFromOnboarding();
    _walletService.addListener(_onWalletChanged);
    _updatePockets();
    _pageController =
        PageController(initialPage: _pocketIndex, viewportFraction: 0.85);
  }

  void _onWalletChanged() => setState(() => _updatePockets());

  void _updatePockets() {
    _pockets = _walletService.pockets.map((p) => _adaptPocket(p)).toList();
  }

  List<_Cat> get _pocketCats {
    return _walletService.pockets.where((p) => !p.isMainAccount).map((pocket) {
      final totalSpent = pocket.transactions
          .where((t) => !t.isCredit)
          .fold(0.0, (sum, t) => sum + t.amount);
      double budget = pocket.transactions
          .where((t) => t.isCredit)
          .fold(0.0, (sum, t) => sum + t.amount);
      if (budget == 0) budget = pocket.balance;
      return _Cat(
          '${pocket.emoji} ${pocket.name}',
          totalSpent,
          budget > 0 ? budget : 1,
          pocket.color,
          Icons.account_balance_wallet_outlined);
    }).toList();
  }

  @override
  void dispose() {
    _walletService.removeListener(_onWalletChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index != _pocketIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        _pocketIndex = index;
        _showAllTx = false;
      });
    }
  }

  // ── Financial Health score based on main account balance ──
  // Score stays at 100 until 50% of the initial balance is used,
  // then drops linearly to 0 as the remaining 50% is consumed.

  double get _score {
    final initial = _walletService.initialMainAccountBalance;
    final current = _walletService.mainAccountBalance;
    if (initial <= 0) return 100.0;
    final usedPct = (initial - current) / initial * 100;
    if (usedPct <= 50) return 100.0;
    return ((1 - (usedPct - 50) / 50) * 100).clamp(0, 100);
  }

  double get _initialBalance => _walletService.initialMainAccountBalance;
  double get _currentBalance => _walletService.mainAccountBalance;
  double get _amountSpent =>
      (_initialBalance - _currentBalance).clamp(0, double.infinity);

  Future<void> _editPlanningBalance() async {
    final controller =
        TextEditingController(text: _planningBalance.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Planning Wallet'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'Try a future balance without changing any spendable money.',
            style: TextStyle(color: _C.grey, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount to plan with',
              prefixText: 'R ',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(
                dialogContext, double.tryParse(controller.text)),
            child: const Text('Update plan'),
          ),
        ],
      ),
    );
    if (result != null && result >= 0 && mounted) {
      setState(() => _planningBalance = result);
    }
  }

  Color get _hColor => _score >= 70
      ? const Color(0xFF10B981)
      : _score >= 40
          ? const Color(0xFFF59E0B)
          : const Color(0xFFEF4444);
  String get _hLabel => _score >= 70
      ? 'Good'
      : _score >= 40
          ? 'Fair'
          : 'Critical';
  String get _hEmoji => _score >= 70
      ? '🟢'
      : _score >= 40
          ? '🟡'
          : '🔴';

  void _showCreatePocketSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String emoji = '💰';
    Color color = const Color(0xFF3B82F6);
    final walletService = WalletService();
    final emojiOptions = ['💰', '🚌', '🛒', '🏠', '📚', '📱', '✈️', '🎮'];
    final colorOptions = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFFE30613),
      const Color(0xFF0EA5E9),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
      const Color(0xFF6366F1),
      const Color(0xFF84CC16),
      const Color(0xFF1A1A1A),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Create Pocket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
                'Available from Main Account: R${WalletService().mainAccountBalance.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emojiOptions
                  .map((e) => GestureDetector(
                        onTap: () => ss(() => emoji = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: e == emoji
                                ? color.withOpacity(0.15)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: e == emoji ? color : Colors.transparent,
                                width: 1.5),
                          ),
                          child: Center(
                              child: Text(e,
                                  style: const TextStyle(fontSize: 20))),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colorOptions
                  .map((c) => GestureDetector(
                        onTap: () => ss(() => color = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: c == color
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.transparent,
                                  width: 2.5)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                    hintText: 'Pocket name (e.g. Transport)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color, width: 1.5)))),
            const SizedBox(height: 12),
            TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: 'Initial deposit (R) — optional',
                    prefixText: 'R ',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color, width: 1.5)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (name.isEmpty) return;
                  final success =
                      walletService.addPocket(name, emoji, color, amount);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Insufficient balance'),
                        backgroundColor: Color(0xFFE30613)));
                    return;
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Create Pocket',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: _C.primary,
          elevation: 0,
          title: const Text('My Wallet',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          actions: [
            IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => context.push('/notifications')),
            IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => _showCreatePocketSheet(context)),
          ],
        ),
        SliverToBoxAdapter(
          child: _PocketContent(
            pockets: _pockets,
            currentIndex: _pocketIndex,
            pageController: _pageController,
            onPageChanged: _onPageChanged,
            balVisible: _balVisible,
            showAllTx: _showAllTx,
            onToggleBal: () => setState(() => _balVisible = !_balVisible),
            onToggleAllTx: () => setState(() => _showAllTx = !_showAllTx),
            score: _score,
            hColor: _hColor,
            hLabel: _hLabel,
            hEmoji: _hEmoji,
            budget: _initialBalance,
            spent: _amountSpent,
            cats: _pocketCats,
            gudeEarnings: _walletService.gudeEarningsBalance,
            gudePoints: _walletService.gudePoints,
            planningBalance: _planningBalance,
            onEditPlanningBalance: _editPlanningBalance,
            onNavigate: (route) => context.push(route),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  _PocketContent
// ════════════════════════════════════════════════════════════════
class _PocketContent extends StatelessWidget {
  final List<_PocketUI> pockets;
  final int currentIndex;
  final PageController pageController;
  final void Function(int) onPageChanged;
  final bool balVisible, showAllTx;
  final VoidCallback onToggleBal, onToggleAllTx;
  final double score, budget, spent;
  final Color hColor;
  final String hLabel, hEmoji;
  final List<_Cat> cats;
  final double gudeEarnings, planningBalance;
  final int gudePoints;
  final VoidCallback onEditPlanningBalance;
  final void Function(String) onNavigate;

  const _PocketContent({
    super.key,
    required this.pockets,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.balVisible,
    required this.showAllTx,
    required this.onToggleBal,
    required this.onToggleAllTx,
    required this.score,
    required this.hColor,
    required this.hLabel,
    required this.hEmoji,
    required this.budget,
    required this.spent,
    required this.cats,
    required this.gudeEarnings,
    required this.gudePoints,
    required this.planningBalance,
    required this.onEditPlanningBalance,
    required this.onNavigate,
  });

  void _showPocketDetails(BuildContext context, _PocketUI pocket) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
            18, 10, 18, MediaQuery.of(sheetContext).padding.bottom + 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: _C.border, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: pocket.cardColor.withOpacity(0.12),
              child: Text(pocket.emoji,
                  style: const TextStyle(fontSize: 21)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pocket.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                const Text('Pocket details and controls',
                    style: TextStyle(color: _C.grey, fontSize: 11)),
              ]),
            ),
            Text('R${pocket.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: _C.primary, fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: _C.lightGrey, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.fingerprint_rounded, color: _C.grey, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Unique pocket identifier',
                      style: TextStyle(color: _C.grey, fontSize: 10)),
                  Text(pocket.cardNumber,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ),
              IconButton(
                tooltip: 'Copy identifier',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: pocket.id));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Pocket identifier copied')));
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _SheetAction(
                icon: Icons.swap_horiz_rounded,
                label: 'Transfer',
                color: _C.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  onNavigate('/wallet/transact');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SheetAction(
                icon: Icons.add_rounded,
                label: 'Add money',
                color: _C.green,
                onTap: () {
                  Navigator.pop(sheetContext);
                  onNavigate('/wallet/transact');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SheetAction(
                icon: Icons.pie_chart_outline_rounded,
                label: 'Budget',
                color: const Color(0xFF7C3AED),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onNavigate('/wallet/budget');
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.swipe_rounded, color: _C.grey, size: 16),
            SizedBox(width: 6),
            Text('Swipe the cards to see your other pockets',
                style: TextStyle(color: _C.grey, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }

  void _goToCard(int index) {
    if (index < 0 || index >= pockets.length) return;
    HapticFeedback.selectionClick();
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pocket = pockets[currentIndex];
    final txList =
        showAllTx ? pocket.transactions : pocket.transactions.take(3).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _WalletOverview(
        earnings: gudeEarnings,
        points: gudePoints,
        planningBalance: planningBalance,
        onEditPlan: onEditPlanningBalance,
      ),
      // ── Card carousel ─────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: SizedBox(
          height: 180,
          child: Stack(children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: const {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.trackpad,
                },
                overscroll: false,
              ),
              child: PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                physics: const PageScrollPhysics(
                    parent: BouncingScrollPhysics()),
                dragStartBehavior: DragStartBehavior.start,
                itemCount: pockets.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTap: () => _showPocketDetails(context, pockets[index]),
                    child: _PocketCard(
                        pocket: pockets[index],
                        balVisible: balVisible,
                        onToggle: onToggleBal),
                  ),
                ),
              ),
            ),
            if (currentIndex > 0)
              Positioned(
                left: 5,
                top: 70,
                child: _CardArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _goToCard(currentIndex - 1),
                ),
              ),
            if (currentIndex < pockets.length - 1)
              Positioned(
                right: 5,
                top: 70,
                child: _CardArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _goToCard(currentIndex + 1),
                ),
              ),
          ]),
        ),
      ),

      // ── Pocket name label ─────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(children: [
          Text(pocket.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(pocket.name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _C.dark)),
          if (pocket.isMainAccount) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: _C.dark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('Primary',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _C.dark)),
            ),
          ],
          const Spacer(),
          const Icon(Icons.swipe_rounded, size: 15, color: _C.grey),
          const SizedBox(width: 5),
          Text('${currentIndex + 1} / ${pockets.length}',
              style: const TextStyle(fontSize: 11, color: _C.grey)),
        ]),
      ),

      // ── Main Account balance row (sub-pockets only) ───
      if (!pocket.isMainAccount)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 6)
                ]),
            child: Row(children: [
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: pocket.cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.account_balance_outlined,
                      color: pocket.cardColor == const Color(0xFF1A1A1A)
                          ? _C.dark
                          : pocket.cardColor,
                      size: 18)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Main Account Balance',
                    style: TextStyle(fontSize: 11, color: _C.grey)),
                Text(
                    balVisible
                        ? 'R${WalletService().mainAccountBalance.toStringAsFixed(2)} ZAR'
                        : 'R••••• ZAR',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _C.dark)),
              ]),
              const Spacer(),
              GestureDetector(
                  onTap: onToggleBal,
                  child: Icon(
                      balVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _C.grey,
                      size: 20)),
            ]),
          ),
        ),

      // ── Quick actions ─────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          Expanded(
              child: _QA(
                  icon: Icons.savings_outlined,
                  label: 'Goals',
                  onTap: () => onNavigate('/wallet/savings'))),
          const SizedBox(width: 10),
          Expanded(
              child: _QA(
                  icon: Icons.pie_chart_outline,
                  label: 'Budget',
                  onTap: () => onNavigate('/wallet/budget'))),
          const SizedBox(width: 10),
          Expanded(
              child: _QA(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Transact',
                  onTap: () => onNavigate('/wallet/transact'))),
        ]),
      ),

      // ── Spending by Category ──────────────────────────
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Text('Spending by Category',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: _C.dark)),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ]),
        child: cats.isEmpty
            ? InkWell(
                onTap: () => onNavigate('/wallet/budget'),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFFFECEE),
                      child: Icon(Icons.add_chart_rounded, color: _C.primary),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Set up your first budget',
                              style: TextStyle(fontWeight: FontWeight.w700, color: _C.dark)),
                          SizedBox(height: 2),
                          Text('See where your money goes each month',
                              style: TextStyle(color: _C.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: _C.primary),
                  ]),
                ),
              )
            : Column(children: cats.map((c) => _CatBar(cat: c)).toList()),
      ),

      // ── Transactions ──────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Transactions',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.dark)),
          GestureDetector(
              onTap: onToggleAllTx,
              child: Text(showAllTx ? 'Show less' : 'View all',
                  style: const TextStyle(
                      color: _C.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600))),
        ]),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ]),
        child: pocket.transactions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: Text('No transactions yet',
                        style: TextStyle(color: _C.grey, fontSize: 13))))
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: txList.length,
                separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 62,
                    endIndent: 16,
                    color: Color(0xFFF0F0F0)),
                itemBuilder: (_, i) => _TxTile(tx: txList[i]),
              ),
      ),

      // ── Financial Health ──────────────────────────────
      _HealthCard(
          score: score,
          hColor: hColor,
          hLabel: hLabel,
          hEmoji: hEmoji,
          budget: budget,
          spent: spent),
      const SizedBox(height: 16),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
//  Pocket Card
// ════════════════════════════════════════════════════════════════
class _CardArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CardArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withOpacity(0.92),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, color: _C.primary, size: 22),
          ),
        ),
      );
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 5),
            Text(label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _WalletOverview extends StatelessWidget {
  final double earnings, planningBalance;
  final int points;
  final VoidCallback onEditPlan;

  const _WalletOverview({
    required this.earnings,
    required this.points,
    required this.planningBalance,
    required this.onEditPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFDDE0)),
        boxShadow: [
          BoxShadow(color: _C.primary.withOpacity(0.06), blurRadius: 16)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFFFECEE),
            child: Icon(Icons.wallet_rounded, color: _C.primary, size: 19),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your money, organised',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Swipe pocket cards below to manage each purpose',
                  style: TextStyle(color: _C.grey, fontSize: 11)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _OverviewTile(
              icon: Icons.storefront_rounded,
              color: _C.primary,
              label: 'Gude earnings',
              value: 'R${earnings.toStringAsFixed(2)}',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _OverviewTile(
              icon: Icons.stars_rounded,
              color: const Color(0xFFF59E0B),
              label: 'Gude Points',
              value: '$points pts',
            ),
          ),
        ]),
        const SizedBox(height: 10),
        InkWell(
          onTap: onEditPlan,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EDFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.auto_graph_rounded,
                  color: Color(0xFF7C3AED), size: 21),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Planning Wallet',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  Text('Simulation only - never changes spendable money',
                      style: TextStyle(color: _C.grey, fontSize: 10)),
                ]),
              ),
              Text('R${planningBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Color(0xFF7C3AED), fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              const Icon(Icons.edit_outlined, color: Color(0xFF7C3AED), size: 16),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _OverviewTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: _C.grey, fontSize: 10)),
              Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ]),
          ),
        ]),
      );
}

class _PocketCard extends StatelessWidget {
  final _PocketUI pocket;
  final bool balVisible;
  final VoidCallback onToggle;
  const _PocketCard(
      {required this.pocket, required this.balVisible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final startColor = pocket.isMainAccount ? _C.primary : pocket.cardColor;
    final endColor = pocket.isMainAccount
        ? const Color(0xFF8F0010)
        : pocket.cardColorEnd;
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: startColor.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Stack(children: [
        Positioned(
            top: -35,
            right: -25,
            child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06)))),
        Positioned(
            bottom: -40,
            left: -15,
            child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text(pocket.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(pocket.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
                if (pocket.isMainAccount) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('PRIMARY',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                  ),
                ],
              ]),
              Row(children: [
                GestureDetector(
                    onTap: onToggle,
                    child: Icon(
                        balVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 15)),
                const SizedBox(width: 8),
                Stack(children: [
                  Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                          color: Color(0xFFEB001B), shape: BoxShape.circle)),
                  Positioned(
                      left: 12,
                      child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF79E1B).withOpacity(0.9),
                              shape: BoxShape.circle))),
                ]),
              ]),
            ]),
            const SizedBox(height: 8),
            Container(
                width: 32,
                height: 24,
                decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(4)),
                child: CustomPaint(painter: _ChipPainter())),
            const Spacer(),
            Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                      balVisible
                          ? 'R ${pocket.balance.toStringAsFixed(2)}'
                          : 'R •••••',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5))),
            Text(pocket.cardNumber,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.8)),
            const SizedBox(height: 3),
            Row(children: [
              Text(pocket.expiry,
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
              const Spacer(),
              _CardStat(
                  label: 'Income',
                  value: balVisible
                      ? '+R${pocket.income.toStringAsFixed(0)}'
                      : '••••',
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.greenAccent),
              const SizedBox(width: 10),
              _CardStat(
                  label: 'Spent',
                  value: balVisible
                      ? '-R${pocket.spent.toStringAsFixed(0)}'
                      : '••••',
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.orangeAccent),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _CardStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4)),
          child: Icon(icon, color: color, size: 9)),
      const SizedBox(width: 4),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 8)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      ]),
    ]);
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB8964A)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), p);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
    canvas.drawLine(
        Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), p);
    canvas.drawLine(
        Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ════════════════════════════════════════════════════════════════
//  Financial Health Card
// ════════════════════════════════════════════════════════════════
class _HealthCard extends StatelessWidget {
  final double score, budget, spent;
  final Color hColor;
  final String hLabel, hEmoji;
  const _HealthCard(
      {required this.score,
      required this.hColor,
      required this.hLabel,
      required this.hEmoji,
      required this.budget,
      required this.spent});

  @override
  Widget build(BuildContext context) {
    final pct = budget > 0 ? (spent / budget * 100).round() : 0;
    final remaining = (budget - spent).clamp(0, double.infinity);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(hEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Financial Health',
                style: TextStyle(fontSize: 11, color: _C.grey)),
            Text(hLabel,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: hColor)),
          ]),
          const Spacer(),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: hColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${score.toInt()}/100',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: hColor))),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: _C.border,
                valueColor: AlwaysStoppedAnimation(hColor))),
        const SizedBox(height: 6),
        Text(
            'Amount used: R${spent.toStringAsFixed(2)}   Remaining: R${remaining.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11, color: _C.grey)),
        const SizedBox(height: 4),
        Text(
            pct <= 50
                ? 'You are within a healthy spending range.'
                : 'You have used $pct% of your balance — consider reducing spending.',
            style: TextStyle(
                fontSize: 12,
                color: pct > 50 ? const Color(0xFFEF4444) : _C.grey,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Category Bar
// ════════════════════════════════════════════════════════════════
class _CatBar extends StatelessWidget {
  final _Cat cat;
  const _CatBar({required this.cat});

  @override
  Widget build(BuildContext context) {
    final pct = (cat.spent / cat.budget).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(cat.icon, size: 15, color: cat.color),
          const SizedBox(width: 7),
          Text(cat.name,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _C.dark)),
          const Spacer(),
          Text('R${cat.spent.toInt()} / R${cat.budget.toInt()}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cat.isOver
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF555555))),
          if (cat.isOver) ...[
            const SizedBox(width: 4),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('Over',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700))),
          ],
        ]),
        const SizedBox(height: 5),
        ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: _C.border,
                valueColor: AlwaysStoppedAnimation(
                    cat.isOver ? const Color(0xFFEF4444) : cat.color))),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Transaction Tile
// ════════════════════════════════════════════════════════════════
class _TxTile extends StatelessWidget {
  final _Tx tx;
  const _TxTile({required this.tx});

  bool get _isTransfer =>
      tx.fromName != null &&
      tx.toName != null &&
      tx.fromName != '—' &&
      tx.toName != '—';

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: tx.isCredit
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(tx.icon,
                      size: 26,
                      color: tx.isCredit
                          ? const Color(0xFF388E3C)
                          : const Color(0xFFF57C00)))),
          const SizedBox(height: 14),
          Center(
              child: Text(
                  '${tx.isCredit ? '+' : '-'}R ${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: tx.isCredit
                          ? const Color(0xFF388E3C)
                          : const Color(0xFF1A1A1A)))),
          const SizedBox(height: 2),
          Center(
              child: Text(tx.label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A)))),
          const SizedBox(height: 20),
          if (_isTransfer)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(
                    child: Column(children: [
                  const Text('FROM',
                      style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Text(tx.fromName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                ])),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: Color(0xFF10B981))),
                Expanded(
                    child: Column(children: [
                  const Text('TO',
                      style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Text(tx.toName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                ])),
              ]),
            ),
          _DetailRow(label: 'Date & Time', value: tx.date),
          _DetailRow(
              label: 'Type',
              value: tx.isCredit ? 'Money In  ↓' : 'Money Out  ↑'),
          if (!_isTransfer) _DetailRow(label: 'Description', value: tx.label),
          const _DetailRow(label: 'Status', value: 'Completed ✓'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0),
              child: const Text('Close',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: tx.isCredit
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(tx.icon,
                  size: 18,
                  color: tx.isCredit
                      ? const Color(0xFF388E3C)
                      : const Color(0xFFF57C00))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(tx.label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.dark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                if (_isTransfer)
                  Row(children: [
                    Text(tx.fromName!,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF999999))),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 10, color: Color(0xFF999999))),
                    Text(tx.toName!,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF999999))),
                  ])
                else
                  Text(tx.date,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF999999))),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${tx.isCredit ? '+' : '-'}R ${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tx.isCredit ? const Color(0xFF388E3C) : _C.dark)),
            const Icon(Icons.chevron_right, size: 14, color: _C.grey),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Detail Row
// ════════════════════════════════════════════════════════════════
class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
        ]));
  }
}

// ════════════════════════════════════════════════════════════════
//  Quick Action Button
// ════════════════════════════════════════════════════════════════
class _QA extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QA({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = label == 'Goals'
        ? const Color(0xFFEF476F)
        : label == 'Budget'
            ? const Color(0xFF7C4DFF)
            : const Color(0xFF118AB2);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555))),
        ]),
      ),
    );
  }
}
