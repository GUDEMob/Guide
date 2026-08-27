import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../wallet/domain/models/wallet_models.dart';

// Brand colours (consistent with other wallet screens)
const _red      = Color(0xFFE30613);
const _success  = Color(0xFF4CAF50);
const _offWhite = Color(0xFFF8F8F8);
const _border   = Color(0xFFE0E0E0);
const _txt1     = Color(0xFF1A1A1A);
const _txt2     = Color(0xFF666666);
const _txtHint  = Color(0xFF9E9E9E);

// Sample data for received transactions (only credits)
final List<WalletTransaction> _receivedTx = [
  WalletTransaction(
    id: '1',
    title: 'Tutoring - Sipho M.',
    amount: 250,
    isCredit: true,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    category: TransactionCategory.marketplace,
  ),
  WalletTransaction(
    id: '3',
    title: 'Design Gig - Nomvula',
    amount: 400,
    isCredit: true,
    date: DateTime.now().subtract(const Duration(days: 1)),
    category: TransactionCategory.marketplace,
  ),
  WalletTransaction(
    id: '6',
    title: 'Coding Help - Thabo',
    amount: 180,
    isCredit: true,
    date: DateTime.now().subtract(const Duration(days: 3)),
    category: TransactionCategory.marketplace,
  ),
  WalletTransaction(
    id: '10',
    title: 'Essay Editing - Lerato',
    amount: 150,
    isCredit: true,
    date: DateTime.now().subtract(const Duration(days: 8)),
    category: TransactionCategory.marketplace,
  ),
];

class ReceivedMoneyScreen extends StatelessWidget {
  const ReceivedMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ');
    final totalReceived = _receivedTx.fold<double>(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: _red,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Money Received', style: TextStyle(fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Total Received',
                  style: TextStyle(fontSize: 14, color: _txt2),
                ),
                const SizedBox(height: 4),
                Text(
                  fmt.format(totalReceived),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _success),
                ),
                const SizedBox(height: 8),
                Text(
                  'From ${_receivedTx.length} service${_receivedTx.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: _txtHint),
                ),
              ],
            ),
          ),

          // List header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _txt1)),
                Text('', style: TextStyle(fontSize: 12, color: _txtHint)), // placeholder for future filter
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _receivedTx.length,
              itemBuilder: (ctx, i) {
                final tx = _receivedTx[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReceivedTile(tx: tx, fmt: fmt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedTile extends StatelessWidget {
  final WalletTransaction tx;
  final NumberFormat fmt;

  const _ReceivedTile({required this.tx, required this.fmt});

  IconData get _icon {
    switch (tx.category) {
      case TransactionCategory.marketplace:
        return Icons.work_outline;
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_bus;
      case TransactionCategory.printing:
        return Icons.print;
      case TransactionCategory.textbooks:
        return Icons.menu_book;
      case TransactionCategory.savings:
        return Icons.savings;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _txt1),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM, HH:mm').format(tx.date),
                  style: const TextStyle(fontSize: 11, color: _txtHint),
                ),
              ],
            ),
          ),
          Text(
            '+${fmt.format(tx.amount)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _success),
          ),
        ],
      ),
    );
  }
}