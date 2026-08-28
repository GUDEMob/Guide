import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../wallet/domain/models/wallet_models.dart';

// ── Brand colours (inline — no dependency on your core/constants) ────────────
const _red      = Color(0xFFE30613);
const _redDark  = Color(0xFFC0000F);
const _success  = Color(0xFF4CAF50);
const _warning  = Color(0xFFFFC107);
const _surface  = Color(0xFFF2F2F2);
const _offWhite = Color(0xFFF8F8F8);
const _border   = Color(0xFFE0E0E0);
const _txt1     = Color(0xFF1A1A1A);
const _txt2     = Color(0xFF666666);
const _txtHint  = Color(0xFF9E9E9E);

// ── Sample data ──────────────────────────────────────────────────────────────
final List<WalletTransaction> _sampleTx = [
  WalletTransaction(id:'1', title:'Tutoring - Sipho M.',    amount:250, isCredit:true,  date:DateTime.now().subtract(const Duration(hours:2)),  category:TransactionCategory.marketplace),
  WalletTransaction(id:'2', title:'Campus Café',            amount:45,  isCredit:false, date:DateTime.now().subtract(const Duration(hours:5)),  category:TransactionCategory.food),
  WalletTransaction(id:'3', title:'Design Gig - Nomvula',   amount:400, isCredit:true,  date:DateTime.now().subtract(const Duration(days:1)),   category:TransactionCategory.marketplace),
  WalletTransaction(id:'4', title:'Gautrain',               amount:32,  isCredit:false, date:DateTime.now().subtract(const Duration(days:1)),   category:TransactionCategory.transport),
  WalletTransaction(id:'5', title:'Library Printing',       amount:18,  isCredit:false, date:DateTime.now().subtract(const Duration(days:2)),   category:TransactionCategory.printing),
];

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ');
    return Scaffold(
      backgroundColor: _offWhite,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _BalanceCard(fmt: fmt)),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20,20,20,0), child: _QuickActions())),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20,16,20,0), child: _Alert())),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20,20,20,0), child: _MonthlySummary(fmt: fmt))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20,24,20,12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Transactions', style: TextStyle(fontSize:16, fontWeight:FontWeight.w700, color:_txt1)),
                  GestureDetector(
                    onTap: () => context.push('/wallet/transactions'),
                    child: const Text('See all', style: TextStyle(fontSize:13, color:_red, fontWeight:FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, i == _sampleTx.length - 1 ? 32 : 10),
                child: _TxTile(tx: _sampleTx[i], fmt: fmt),
              ),
              childCount: _sampleTx.length,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Balance card ─────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final NumberFormat fmt;
  const _BalanceCard({required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left:24, right:24, bottom:32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight, colors:[_red, _redDark]),
        borderRadius: BorderRadius.only(bottomLeft:Radius.circular(32), bottomRight:Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gude Wallet', style: TextStyle(fontSize:16, fontWeight:FontWeight.w600, color:Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                decoration: BoxDecoration(color:Colors.white.withOpacity(0.2), borderRadius:BorderRadius.circular(20)),
                child: const Row(children:[
                  Icon(Icons.shield_outlined, color:Colors.white, size:14),
                  SizedBox(width:4),
                  Text('Verified', style:TextStyle(fontSize:11, color:Colors.white, fontWeight:FontWeight.w500)),
                ]),
              ),
            ],
          ),
          const SizedBox(height:24),
          const Text('Available Balance', style:TextStyle(fontSize:12, color:Colors.white60)),
          const SizedBox(height:4),
          Text(fmt.format(1234.50), style: const TextStyle(fontSize:36, fontWeight:FontWeight.w800, color:Colors.white, letterSpacing:-0.5)),
          const SizedBox(height:4),
          const Text('↑ R650.00 earned this month', style:TextStyle(fontSize:12, color:Colors.white70)),
        ],
      ),
    );
  }
}

// ── Quick action buttons ──────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children:[
      _Btn(icon:Icons.arrow_downward_rounded,  label:'Received',  onTap:() => context.push('/wallet/received')),
      const SizedBox(width:12),
      _Btn(icon:Icons.arrow_upward_rounded,    label:'Send',     onTap:() => context.push('/wallet/send')),
      const SizedBox(width:12),
      _Btn(icon:Icons.account_balance_outlined,label:'Withdraw', onTap:() => context.push('/wallet/withdraw')),
      const SizedBox(width:12),
      _Btn(icon:Icons.pie_chart_outline_rounded,label:'Budget',  onTap:() => context.push('/wallet/budget')),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical:14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:8, offset:const Offset(0,2))],
        ),
        child: Column(children:[
          Icon(icon, color:_red, size:22),
          const SizedBox(height:6),
          Text(label, style: const TextStyle(fontSize:11, fontWeight:FontWeight.w500, color:_txt1)),
        ]),
      ),
    ),
  );
}

// ── Spending alert ────────────────────────────────────────────────────────────
class _Alert extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _warning.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color:_warning.withOpacity(0.3)),
    ),
    child: Row(children:[
      const Icon(Icons.warning_amber_rounded, color:_warning, size:20),
      const SizedBox(width:10),
      const Expanded(child:Text('You may run out of funds before month-end at current spend rate.', style:TextStyle(fontSize:12, color:_txt2, height:1.4))),
      GestureDetector(
        onTap: () => context.push('/wallet/budget'),
        child: const Text('Budget', style:TextStyle(fontSize:12, fontWeight:FontWeight.w700, color:_warning)),
      ),
    ]),
  );
}

// ── Monthly summary card ──────────────────────────────────────────────────────
class _MonthlySummary extends StatelessWidget {
  final NumberFormat fmt;
  const _MonthlySummary({required this.fmt});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.04), blurRadius:12, offset:const Offset(0,2))],
    ),
    child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      const Text('This Month', style:TextStyle(fontSize:14, fontWeight:FontWeight.w600, color:_txt1)),
      const SizedBox(height:16),
      Row(children:[
        Expanded(child:_StatChip(label:'Income', value:fmt.format(650), color:_success, icon:Icons.trending_up_rounded)),
        Container(width:1, height:40, color:_border, margin:const EdgeInsets.symmetric(horizontal:16)),
        Expanded(child:_StatChip(label:'Spent', value:fmt.format(415.50), color:Colors.redAccent, icon:Icons.trending_down_rounded)),
      ]),
      const SizedBox(height:16),
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
        const Text('Budget used', style:TextStyle(fontSize:12, color:_txt2)),
        const Text('64%', style:TextStyle(fontSize:12, fontWeight:FontWeight.w600, color:_warning)),
      ]),
      const SizedBox(height:6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const LinearProgressIndicator(value:0.64, minHeight:8, backgroundColor:_surface, valueColor:AlwaysStoppedAnimation<Color>(_warning)),
      ),
    ]),
  );
}

class _StatChip extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _StatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
    Row(children:[Icon(icon, color:color, size:16), const SizedBox(width:4), Text(label, style: const TextStyle(fontSize:12, color:_txt2))]),
    const SizedBox(height:4),
    Text(value, style:TextStyle(fontSize:16, fontWeight:FontWeight.w700, color:color)),
  ]);
}

// ── Transaction tile ──────────────────────────────────────────────────────────
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.04), blurRadius:8, offset:const Offset(0,1))],
      ),
      child: Row(children:[
        Container(width:44, height:44,
          decoration: BoxDecoration(color:color.withOpacity(0.1), shape:BoxShape.circle),
          child: Icon(_icon, color:color, size:20)),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text(tx.title, style: const TextStyle(fontSize:14, fontWeight:FontWeight.w600, color:_txt1)),
          Text(DateFormat('d MMM, HH:mm').format(tx.date), style: const TextStyle(fontSize:11, color:_txtHint)),
        ])),
        Text('${tx.isCredit ? '+' : '-'} ${fmt.format(tx.amount)}',
          style:TextStyle(fontSize:14, fontWeight:FontWeight.w700, color: tx.isCredit ? _success : _txt1)),
      ]),
    );
  }
}
