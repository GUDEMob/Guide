// lib/features/wallet/presentation/wallet_pockets_page.dart
// Each pocket is a full page. The ">" button advances to the next pocket
// in a clockwise (circular) formation. Navigation arrow always visible.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _C {
  static const primary = Color(0xFFE30613);
}

class _Pocket {
  final String id, name, cardNumber, expiry;
  final double balance;
  final Color cardColor, cardColorEnd;
  final String emoji;
  final List<_PocketTx> transactions;
  const _Pocket({required this.id, required this.name, required this.cardNumber, required this.expiry, required this.balance, required this.cardColor, required this.cardColorEnd, required this.emoji, required this.transactions});
}

class _PocketTx {
  final String label, date;
  final double amount;
  final bool isCredit;
  const _PocketTx(this.label, this.amount, this.isCredit, this.date);
}

final _pockets = [
  _Pocket(id: 'saving', name: 'Saving Pocket', emoji: '💰', cardNumber: '2015 1320 8870 2351', expiry: '09/30', balance: 190.00, cardColor: const Color(0xFF1A1A1A), cardColorEnd: const Color(0xFF3A3A3A), transactions: const [
    _PocketTx('Top up to balance', 100.00, true, '26/8/2025, 3:07 PM'),
    _PocketTx('Balance Changed', 20.00, false, '26/8/2025, 3:07 PM'),
    _PocketTx('Top up', 70.00, true, '25/8/2025, 11:00 AM'),
  ]),
  _Pocket(id: 'transport', name: 'Transport Pocket', emoji: '🚌', cardNumber: '1202 1320 8870 2351', expiry: '09/30', balance: 100.00, cardColor: const Color(0xFF1A3A8F), cardColorEnd: const Color(0xFF3B5BD5), transactions: const [
    _PocketTx('Gautrain', 32.00, false, '26/8/2025, 8:00 AM'),
    _PocketTx('Top up', 100.00, true, '25/8/2025, 9:00 AM'),
    _PocketTx('Uber', 45.00, false, '24/8/2025, 6:30 PM'),
  ]),
  _Pocket(id: 'grocery', name: 'Grocery Pocket', emoji: '🛒', cardNumber: '0057 0120 8870 0234', expiry: '09/30', balance: 120.00, cardColor: const Color(0xFF065F46), cardColorEnd: const Color(0xFF059669), transactions: const [
    _PocketTx('Checkers', 89.00, false, '26/8/2025, 12:00 PM'),
    _PocketTx('Top up', 150.00, true, '24/8/2025, 9:00 AM'),
    _PocketTx('Woolworths Food', 61.00, false, '23/8/2025, 1:00 PM'),
  ]),
  _Pocket(id: 'accommodation', name: 'Accommodation Pocket', emoji: '🏠', cardNumber: '0587 1320 8870 5723', expiry: '09/30', balance: 200.00, cardColor: const Color(0xFF5B21B6), cardColorEnd: const Color(0xFF7C3AED), transactions: const [
    _PocketTx('Rent payment', 200.00, false, '26/8/2025, 7:00 AM'),
    _PocketTx('Top up', 200.00, true, '25/8/2025, 8:00 AM'),
    _PocketTx('Deposit refund', 50.00, true, '20/8/2025, 3:00 PM'),
  ]),
];

class WalletPocketsPage extends StatefulWidget {
  final int initialIndex;
  const WalletPocketsPage({super.key, this.initialIndex = 0});
  @override
  State<WalletPocketsPage> createState() => _WalletPocketsPageState();
}

class _WalletPocketsPageState extends State<WalletPocketsPage> with TickerProviderStateMixin {
  late int _selectedIndex;
  bool _balanceVisible = true;
  late AnimationController _navAnim;
  late Animation<double> _navScale;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _navAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _navScale = Tween<double>(begin: 1.0, end: 0.88).animate(CurvedAnimation(parent: _navAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _navAnim.dispose(); super.dispose(); }

  void _nextPocket() {
    _navAnim.forward().then((_) => _navAnim.reverse());
    setState(() => _selectedIndex = (_selectedIndex + 1) % _pockets.length);
  }

  _Pocket get _pocket => _pockets[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(_pocket.name, style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        actions: [
          // ">" clockwise navigation to next pocket
          ScaleTransition(
            scale: _navScale,
            child: GestureDetector(
              onTap: _nextPocket,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _pocket.cardColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _pocket.cardColor.withOpacity(0.3)),
                ),
                child: Icon(Icons.chevron_right_rounded, color: _pocket.cardColor, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pocket selector tabs
          Container(
            color: Colors.white,
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _pockets.length + 1,
              itemBuilder: (_, i) {
                if (i == _pockets.length) {
                  return GestureDetector(
                    onTap: () => _showAddPocketSheet(context),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFDDDDDD))),
                      child: const Row(children: [Icon(Icons.add, size: 14, color: Color(0xFF777777)), SizedBox(width: 4), Text('Add', style: TextStyle(fontSize: 12, color: Color(0xFF777777), fontWeight: FontWeight.w600))]),
                    ),
                  );
                }
                final sel = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: sel ? _C.primary : const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      Text(_pockets[i].emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(_pockets[i].name.replaceAll(' Pocket', ''), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : const Color(0xFF777777))),
                    ]),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _PocketBody(key: ValueKey(_pocket.id), pocket: _pocket, balanceVisible: _balanceVisible, onToggleBalance: () => setState(() => _balanceVisible = !_balanceVisible), onNext: _nextPocket),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPocketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create New Pocket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          for (final name in ['Data Pocket', 'Entertainment Pocket', 'Books Pocket', 'Emergency Pocket'])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: _C.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add_card_outlined, color: _C.primary, size: 20)),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => Navigator.pop(context),
            ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _PocketBody extends StatelessWidget {
  final _Pocket pocket;
  final bool balanceVisible;
  final VoidCallback onToggleBalance, onNext;
  const _PocketBody({super.key, required this.pocket, required this.balanceVisible, required this.onToggleBalance, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Pocket card
        _PocketCard(pocket: pocket, balanceVisible: balanceVisible, onToggle: onToggleBalance),
        const SizedBox(height: 16),

        // Balance row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: pocket.cardColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.account_balance_outlined, color: pocket.cardColor, size: 18)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Available Balance', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              Text(balanceVisible ? 'R${pocket.balance.toStringAsFixed(2)} ZAR' : 'R•••••', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
            ]),
            const Spacer(),
            GestureDetector(onTap: onToggleBalance, child: Icon(balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF888888), size: 20)),
          ]),
        ),
        const SizedBox(height: 16),

        // Quick actions
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _Action(icon: Icons.send_rounded, label: 'Send', onTap: () {}),
          _Action(icon: Icons.call_received_rounded, label: 'Withdraw', onTap: () {}),
          _Action(icon: Icons.swap_horiz_rounded, label: 'Transfer', onTap: () {}),
          // Next pocket button in action row
          _Action(icon: Icons.rotate_right_rounded, label: 'Next Pocket', onTap: onNext, color: pocket.cardColor),
        ]),
        const SizedBox(height: 20),

        // Transactions
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          Row(children: [const Text('View all', style: TextStyle(fontSize: 13, color: _C.primary, fontWeight: FontWeight.w600)), const SizedBox(width: 2), const Icon(Icons.chevron_right, size: 16, color: _C.primary)]),
        ]),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: pocket.transactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F0F0)),
            itemBuilder: (_, i) {
              final tx = pocket.transactions[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: tx.isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), shape: BoxShape.circle), child: Icon(tx.isCredit ? Icons.check_circle_outline : Icons.remove_circle_outline, size: 18, color: tx.isCredit ? const Color(0xFF388E3C) : _C.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tx.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                    Text(tx.date, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                  ])),
                  Text('${tx.isCredit ? '+' : '-'}R${tx.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tx.isCredit ? const Color(0xFF388E3C) : _C.primary)),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _Action({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? _C.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))]), child: Icon(icon, color: c, size: 22)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF555555)), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _PocketCard extends StatelessWidget {
  final _Pocket pocket;
  final bool balanceVisible;
  final VoidCallback onToggle;
  const _PocketCard({required this.pocket, required this.balanceVisible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180, width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [pocket.cardColor, pocket.cardColorEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: pocket.cardColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(children: [
        Positioned(top: -30, right: -20, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text(pocket.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(pocket.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
              Row(children: [
                Container(width: 26, height: 26, decoration: const BoxDecoration(color: Color(0xFFEB001B), shape: BoxShape.circle)),
                Transform.translate(offset: const Offset(-10, 0), child: Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(0xFFF79E1B).withOpacity(0.9), shape: BoxShape.circle))),
              ]),
            ]),
            const SizedBox(height: 10),
            Container(width: 34, height: 26, decoration: BoxDecoration(color: const Color(0xFFD4B068), borderRadius: BorderRadius.circular(4)), child: CustomPaint(painter: _ChipPainter())),
            const Spacer(),
            Text(pocket.cardNumber, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 2)),
            const SizedBox(height: 6),
            Row(children: [
              Text(pocket.expiry, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const Spacer(),
              GestureDetector(onTap: onToggle, child: Icon(balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white60, size: 16)),
              const SizedBox(width: 8),
              Text(balanceVisible ? 'R${pocket.balance.toStringAsFixed(2)}' : 'R•••••', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFB8964A)..strokeWidth = 0.8..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), p);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), p);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), p);
  }
  @override
  bool shouldRepaint(_) => false;
}