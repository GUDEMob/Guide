import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/wallet_service.dart';

class TransactScreen extends StatefulWidget {
  const TransactScreen({super.key});
  @override
  State<TransactScreen> createState() => _TransactScreenState();
}

class _TransactScreenState extends State<TransactScreen> {
  Pocket? _selectedPocket;

  @override
  void initState() {
    super.initState();
    // Default selection = Main Account pocket (always index 0)
    final pockets = WalletService().pockets;
    if (pockets.isNotEmpty) {
      _selectedPocket = pockets.first; // first = Main Account
    }
  }

  @override
  Widget build(BuildContext context) {
    // All pockets including Main Account (index 0)
    final pockets = WalletService().pockets;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Transact',
            style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step 1: Select pocket ──────────────────────
            const Text('Select Pocket',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            const Text('Choose which pocket to transact from',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 12),

            // All pockets (Main Account is always first)
            ...pockets.map((p) => _PocketTile(
                  emoji: p.emoji,
                  name: p.name,
                  balance: p.balance,
                  color: p.color,
                  isMainAccount: p.isMainAccount,
                  selected: _selectedPocket?.id == p.id,
                  onTap: () => setState(() => _selectedPocket = p),
                )),

            const SizedBox(height: 24),

            // ── Step 2: Choose action ──────────────────────
            const Text('What would you like to do?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.send_rounded,
              title: 'Send Money',
              subtitle: 'Send to an external account or number',
              color: const Color(0xFF3B82F6),
              onTap: () => context
                  .push('/wallet/send', extra: {'pocket': _selectedPocket}),
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Transfer Between Pockets',
              subtitle: 'Move money from one pocket to another',
              color: const Color(0xFF10B981),
              onTap: () => _showTransferSheet(context, pockets.toList()),
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.confirmation_number_outlined,
              title: 'Withdraw (Get Voucher)',
              subtitle: 'Get a withdrawal voucher for cash',
              color: const Color(0xFFF59E0B),
              onTap: () => context
                  .push('/wallet/withdraw', extra: {'pocket': _selectedPocket}),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferSheet(BuildContext context, List<Pocket> pockets) {
    if (pockets.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least 2 pockets to transfer'),
          backgroundColor: Color(0xFFE30613),
        ),
      );
      return;
    }

    Pocket fromPocket = _selectedPocket ?? pockets.first;
    Pocket toPocket = pockets.firstWhere(
      (p) => p.id != fromPocket.id,
      orElse: () => pockets.first,
    );
    final amountCtrl = TextEditingController();

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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Transfer Between Pockets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            // Live balance preview
            Text(
              'Available in ${fromPocket.emoji} ${fromPocket.name}: '
              'R${fromPocket.balance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 20),

            // ── From pocket ───────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('From',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<Pocket>(
              value: fromPocket,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: pockets
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          '${p.emoji} ${p.name}  '
                          '(R${p.balance.toStringAsFixed(2)})',
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                ss(() {
                  fromPocket = v;
                  // Auto-switch toPocket if same was selected
                  if (toPocket.id == fromPocket.id) {
                    toPocket = pockets.firstWhere(
                      (p) => p.id != fromPocket.id,
                      orElse: () => pockets.first,
                    );
                  }
                });
              },
            ),
            const SizedBox(height: 12),

            // ── Arrow indicator ───────────────────────────
            Row(children: [
              Expanded(child: Divider(color: Colors.grey.shade200)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_downward_rounded,
                    color: const Color(0xFF10B981), size: 20),
              ),
              Expanded(child: Divider(color: Colors.grey.shade200)),
            ]),
            const SizedBox(height: 12),

            // ── To pocket ─────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('To',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<Pocket>(
              value: toPocket,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: pockets
                  .where((p) => p.id != fromPocket.id)
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.emoji} ${p.name}'),
                      ))
                  .toList(),
              onChanged: (v) => ss(() => toPocket = v ?? toPocket),
            ),
            const SizedBox(height: 12),

            // ── Amount ────────────────────────────────────
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Amount (R)',
                prefixText: 'R ',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF10B981), width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;

                  final success = WalletService().transferBetweenPockets(
                    fromPocket.id,
                    toPocket.id,
                    amount,
                  );

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Insufficient balance in source pocket'),
                        backgroundColor: Color(0xFFE30613),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'R${amount.toStringAsFixed(2)} transferred '
                        'from ${fromPocket.emoji} ${fromPocket.name} '
                        'to ${toPocket.emoji} ${toPocket.name}',
                      ),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Transfer',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Pocket Tile
// ════════════════════════════════════════════════════════════════
class _PocketTile extends StatelessWidget {
  final String emoji, name;
  final double balance;
  final Color color;
  final bool isMainAccount;
  final bool selected;
  final VoidCallback onTap;

  const _PocketTile({
    required this.emoji,
    required this.name,
    required this.balance,
    required this.color,
    required this.isMainAccount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFFEEEEEE),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                  if (isMainAccount) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('PRIMARY',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: color)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(
                  isMainAccount ? 'Available balance' : 'Pocket balance',
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Text(
            'R${balance.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Action Card
// ════════════════════════════════════════════════════════════════
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888), height: 1.4)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: color, size: 20),
        ]),
      ),
    );
  }
}
