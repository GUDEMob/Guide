import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../wallet/domain/models/wallet_models.dart';

const _red      = Color(0xFFE30613);
const _success  = Color(0xFF4CAF50);
const _offWhite = Color(0xFFF8F8F8);
const _border   = Color(0xFFE0E0E0);
const _txt1     = Color(0xFF1A1A1A);
const _txt2     = Color(0xFF666666);
const _txtHint  = Color(0xFF9E9E9E);

final List<WalletTransaction> _allTx = [
  WalletTransaction(id:'1',  title:'Tutoring - Sipho M.',    amount:250,  isCredit:true,  date:DateTime.now().subtract(const Duration(hours:2)),  category:TransactionCategory.marketplace),
  WalletTransaction(id:'2',  title:'Campus Café',            amount:45,   isCredit:false, date:DateTime.now().subtract(const Duration(hours:5)),  category:TransactionCategory.food),
  WalletTransaction(id:'3',  title:'Design Gig - Nomvula',   amount:400,  isCredit:true,  date:DateTime.now().subtract(const Duration(days:1)),   category:TransactionCategory.marketplace),
  WalletTransaction(id:'4',  title:'Gautrain',               amount:32.5, isCredit:false, date:DateTime.now().subtract(const Duration(days:1)),   category:TransactionCategory.transport),
  WalletTransaction(id:'5',  title:'Library Printing',       amount:18,   isCredit:false, date:DateTime.now().subtract(const Duration(days:2)),   category:TransactionCategory.printing),
  WalletTransaction(id:'6',  title:'Coding Help - Thabo',    amount:180,  isCredit:true,  date:DateTime.now().subtract(const Duration(days:3)),   category:TransactionCategory.marketplace),
  WalletTransaction(id:'7',  title:'Wits Cafeteria',         amount:62,   isCredit:false, date:DateTime.now().subtract(const Duration(days:3)),   category:TransactionCategory.food),
  WalletTransaction(id:'8',  title:'Statistics Textbook',    amount:220,  isCredit:false, date:DateTime.now().subtract(const Duration(days:5)),   category:TransactionCategory.textbooks),
  WalletTransaction(id:'9',  title:'Savings - Laptop Fund',  amount:100,  isCredit:false, date:DateTime.now().subtract(const Duration(days:7)),   category:TransactionCategory.savings),
  WalletTransaction(id:'10', title:'Essay Editing - Lerato', amount:150,  isCredit:true,  date:DateTime.now().subtract(const Duration(days:8)),   category:TransactionCategory.marketplace),
];

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionCategory? _filter;

  List<WalletTransaction> get _filtered =>
      _filter == null ? _allTx : _allTx.where((t) => t.category == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ');
    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: _red,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(children: [
        // filter chips
        Container(
          color: _red,
          child: Container(
            decoration: const BoxDecoration(
              color: _offWhite,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              height: 36,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _Chip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                ...TransactionCategory.values.map((c) =>
                  _Chip(label: c.label, selected: _filter == c, onTap: () => setState(() => _filter = c)),
                ),
              ]),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: _filtered.length,
            itemBuilder: (ctx, i) {
              final tx = _filtered[i];
              final showDate = i == 0 || !_sameDay(_filtered[i-1].date, tx.date);
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (showDate) Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(_dateLabel(tx.date),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _txt2, letterSpacing: 0.4)),
                ),
                _TxTile(tx: tx, fmt: fmt),
                const SizedBox(height: 8),
              ]);
            },
          ),
        ),
      ]),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year==b.year && a.month==b.month && a.day==b.day;

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    if (_sameDay(d, now)) return 'TODAY';
    if (_sameDay(d, now.subtract(const Duration(days:1)))) return 'YESTERDAY';
    return DateFormat('EEEE, d MMMM').format(d).toUpperCase();
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds:150),
      margin: const EdgeInsets.only(right:8),
      padding: const EdgeInsets.symmetric(horizontal:14, vertical:6),
      decoration: BoxDecoration(
        color: selected ? _red : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? _red : _border),
      ),
      child: Text(label, style: TextStyle(fontSize:12, fontWeight:FontWeight.w500,
        color: selected ? Colors.white : _txt2)),
    ),
  );
}

class _TxTile extends StatelessWidget {
  final WalletTransaction tx; final NumberFormat fmt;
  const _TxTile({required this.tx, required this.fmt});

  IconData get _icon {
    switch (tx.category) {
      case TransactionCategory.marketplace: return Icons.storefront_outlined;
      case TransactionCategory.food:        return Icons.fastfood_outlined;
      case TransactionCategory.transport:   return Icons.directions_bus_outlined;
      case TransactionCategory.printing:    return Icons.print_outlined;
      case TransactionCategory.textbooks:   return Icons.menu_book_outlined;
      case TransactionCategory.savings:     return Icons.savings_outlined;
      case TransactionCategory.other:       return Icons.receipt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = tx.isCredit ? _success : _red;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.04), blurRadius:8, offset:const Offset(0,1))],
      ),
      child: Row(children:[
        Container(width:44, height:44,
          decoration: BoxDecoration(color:color.withOpacity(0.1), shape:BoxShape.circle),
          child: Icon(_icon, color:color, size:20)),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text(tx.title, style: const TextStyle(fontSize:14, fontWeight:FontWeight.w600, color:_txt1)),
          Text(tx.category.label, style: const TextStyle(fontSize:11, color:_txtHint)),
        ])),
        Column(crossAxisAlignment:CrossAxisAlignment.end, children:[
          Text('${tx.isCredit ? '+' : '-'}${fmt.format(tx.amount)}',
            style:TextStyle(fontSize:14, fontWeight:FontWeight.w700, color: tx.isCredit ? _success : _txt1)),
          Text(DateFormat('HH:mm').format(tx.date), style: const TextStyle(fontSize:10, color:_txtHint)),
        ]),
      ]),
    );
  }
}
