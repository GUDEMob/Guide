import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Payments', 'Grocery', 'Transport'];

  final List<Map<String, dynamic>> _transactions = [
    {'type': 'Top up to balance', 'amount': 190.00, 'date': '26/6/2025, 3:07 PM', 'positive': true},
    {'type': 'Balance Changed',   'amount': -20.00,  'date': '26/6/2025, 3:07 PM', 'positive': false},
    {'type': 'Top up to balance', 'amount': 190.00, 'date': '26/6/2025, 3:07 PM', 'positive': true},
    {'type': 'Balance Changed',   'amount': -20.00,  'date': '26/6/2025, 3:07 PM', 'positive': false},
    {'type': 'Top up to balance', 'amount': 190.00, 'date': '26/6/2025, 3:07 PM', 'positive': true},
    {'type': 'Balance Changed',   'amount': -20.00,  'date': '26/6/2025, 3:07 PM', 'positive': false},
    {'type': 'Top up to balance', 'amount': 190.00, 'date': '26/6/2025, 3:07 PM', 'positive': true},
    {'type': 'Balance Changed',   'amount': -20.00,  'date': '26/6/2025, 3:07 PM', 'positive': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/wallet')),
        title: const Text('Recent Transactions'),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List.generate(_filters.length, (i) => GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedFilter == i ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _selectedFilter == i ? AppColors.primary : AppColors.inputBorder),
                ),
                child: Text(_filters[i],
                  style: TextStyle(
                    color: _selectedFilter == i ? Colors.white : AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  )),
              ),
            ))),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                TextButton(onPressed: () {}, child: const Text('View all >', style: TextStyle(color: AppColors.primary))),
              ]),
              ..._transactions.map((t) => _TxTile(t: t)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> t;
  const _TxTile({required this.t});
  @override
  Widget build(BuildContext context) {
    final pos = t['positive'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        CircleAvatar(radius: 16,
          backgroundColor: pos ? Colors.green : AppColors.primary,
          child: Icon(pos ? Icons.check : Icons.close, color: Colors.white, size: 14)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t['type'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text('${(t['amount'] as double).toStringAsFixed(2)} ZAR',
            style: TextStyle(fontSize: 13, color: pos ? Colors.green : AppColors.primary, fontWeight: FontWeight.bold)),
        ])),
        Text(t['date'], style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ]),
    );
  }
}
