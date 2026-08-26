import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../wallet/domain/models/wallet_models.dart';

const _red      = Color(0xFFE30613);
const _success  = Color(0xFF4CAF50);
const _warning  = Color(0xFFFFC107);
const _error    = Color(0xFFF44336);
const _offWhite = Color(0xFFF8F8F8);
const _surface  = Color(0xFFF2F2F2);
const _txt1     = Color(0xFF1A1A1A);
const _txt2     = Color(0xFF666666);
const _txtHint  = Color(0xFF9E9E9E);

final List<BudgetCategory> _defaults = [
  BudgetCategory(name:'Food',      allocated:600, spent:365, emoji:'🍔'),
  BudgetCategory(name:'Transport', allocated:300, spent:247, emoji:'🚌'),
  BudgetCategory(name:'Data',      allocated:150, spent:79,  emoji:'📶'),
  BudgetCategory(name:'Books',     allocated:200, spent:220, emoji:'📚'),
  BudgetCategory(name:'Savings',   allocated:400, spent:100, emoji:'💰'),
  BudgetCategory(name:'Other',     allocated:300, spent:85,  emoji:'🧾'),
];

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  late List<BudgetCategory> _cats;

  @override
  void initState() {
    super.initState();
    _cats = List.from(_defaults);
  }

  double get _totalAllocated => _cats.fold(0, (s, c) => s + c.allocated);
  double get _totalSpent     => _cats.fold(0, (s, c) => s + c.spent);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ');
    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: _red,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Budget Planner', style: TextStyle(fontWeight:FontWeight.w700, color:Colors.white)),
        iconTheme: const IconThemeData(color:Colors.white),
        actions: [
          TextButton(
            onPressed: () => context.push('/wallet/savings'),
            child: const Text('Savings Goals', style:TextStyle(color:Colors.white70, fontSize:13)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        backgroundColor: _red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category', style:TextStyle(fontWeight:FontWeight.w600)),
      ),
      body: Column(children: [
        Container(
          color: _red,
          child: Container(
            decoration: const BoxDecoration(
              color: _offWhite,
              borderRadius: BorderRadius.only(topLeft:Radius.circular(24), topRight:Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: _Overview(totalAllocated:_totalAllocated, totalSpent:_totalSpent, fmt:fmt),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: _cats.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom:12),
              child: _CatCard(cat:_cats[i], fmt:fmt, onEdit:() => _showEdit(i)),
            ),
          ),
        ),
      ]),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color:_txtHint, fontSize:14),
    filled: true, fillColor: _surface,
    border: OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:const BorderSide(color:_red, width:1.5)),
  );

  void _showEdit(int i) {
    final cat = _cats[i];
    final ctrl = TextEditingController(text: cat.allocated.toStringAsFixed(0));
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left:24, right:24, top:24, bottom:MediaQuery.of(ctx).viewInsets.bottom+24),
        child: Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text('${cat.emoji} Edit ${cat.name} Budget', style: const TextStyle(fontSize:18, fontWeight:FontWeight.w700)),
          const SizedBox(height:20),
          TextField(controller:ctrl, keyboardType:TextInputType.number, decoration:_dec('Monthly allocation (R)')),
          const SizedBox(height:20),
          SizedBox(width:double.infinity, height:50,
            child: ElevatedButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text) ?? cat.allocated;
                setState(() => _cats[i] = BudgetCategory(name:cat.name, allocated:v, spent:cat.spent, emoji:cat.emoji));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor:_red, shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
              child: const Text('Save', style:TextStyle(color:Colors.white, fontWeight:FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showAdd() {
    final nameCtrl = TextEditingController();
    final amtCtrl  = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left:24, right:24, top:24, bottom:MediaQuery.of(ctx).viewInsets.bottom+24),
        child: Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[
          const Text('Add Category', style:TextStyle(fontSize:18, fontWeight:FontWeight.w700)),
          const SizedBox(height:20),
          TextField(controller:nameCtrl, decoration:_dec('Category name')),
          const SizedBox(height:12),
          TextField(controller:amtCtrl, keyboardType:TextInputType.number, decoration:_dec('Monthly amount (R)')),
          const SizedBox(height:20),
          SizedBox(width:double.infinity, height:50,
            child: ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final amt  = double.tryParse(amtCtrl.text) ?? 0;
                if (name.isNotEmpty && amt > 0) {
                  setState(() => _cats.add(BudgetCategory(name:name, allocated:amt, spent:0, emoji:'📦')));
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor:_red, shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
              child: const Text('Add', style:TextStyle(color:Colors.white, fontWeight:FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Overview banner ───────────────────────────────────────────────────────────
class _Overview extends StatelessWidget {
  final double totalAllocated, totalSpent; final NumberFormat fmt;
  const _Overview({required this.totalAllocated, required this.totalSpent, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final remaining = totalAllocated - totalSpent;
    final pct       = totalAllocated > 0 ? (totalSpent / totalAllocated).clamp(0.0, 1.0) : 0.0;
    final isOver    = remaining < 0;
    final barColor  = pct > 0.9 ? _error : pct > 0.7 ? _warning : _success;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:12, offset:const Offset(0,2))],
      ),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        const Text('Monthly Budget', style:TextStyle(fontSize:14, fontWeight:FontWeight.w600, color:Color(0xFF1A1A1A))),
        const SizedBox(height:12),
        Row(children:[
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Text(fmt.format(totalSpent), style: const TextStyle(fontSize:22, fontWeight:FontWeight.w800, color:Color(0xFF1A1A1A))),
            Text('of ${fmt.format(totalAllocated)} budgeted', style: const TextStyle(fontSize:12, color:_txt2)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal:12, vertical:6),
            decoration: BoxDecoration(
              color: isOver ? _error.withOpacity(0.1) : _success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOver ? '${fmt.format(remaining.abs())} over' : '${fmt.format(remaining)} left',
              style: TextStyle(fontSize:12, fontWeight:FontWeight.w600, color: isOver ? _error : _success),
            ),
          ),
        ]),
        const SizedBox(height:12),
        ClipRRect(borderRadius:BorderRadius.circular(6),
          child: LinearProgressIndicator(value:pct, minHeight:10, backgroundColor:const Color(0xFFF2F2F2), valueColor:AlwaysStoppedAnimation<Color>(barColor))),
        const SizedBox(height:6),
        Text('${(pct*100).toStringAsFixed(0)}% used', style: const TextStyle(fontSize:11, color:_txtHint)),
      ]),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CatCard extends StatelessWidget {
  final BudgetCategory cat; final NumberFormat fmt; final VoidCallback onEdit;
  const _CatCard({required this.cat, required this.fmt, required this.onEdit});

  Color get _barColor => cat.percentage > 1.0 ? _error : cat.percentage > 0.85 ? _warning : _success;

  @override
  Widget build(BuildContext context) {
    final isOver = cat.remaining < 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.04), blurRadius:8, offset:const Offset(0,1))],
      ),
      child: Column(children:[
        Row(children:[
          Text(cat.emoji, style: const TextStyle(fontSize:20)),
          const SizedBox(width:10),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Text(cat.name, style: const TextStyle(fontSize:14, fontWeight:FontWeight.w600, color:Color(0xFF1A1A1A))),
            Text('${fmt.format(cat.spent)} / ${fmt.format(cat.allocated)}', style: const TextStyle(fontSize:12, color:_txt2)),
          ])),
          Column(crossAxisAlignment:CrossAxisAlignment.end, children:[
            GestureDetector(onTap:onEdit, child: const Icon(Icons.edit_outlined, size:18, color:_txtHint)),
            const SizedBox(height:4),
            Text(isOver ? '${fmt.format(cat.remaining.abs())} over' : '${fmt.format(cat.remaining)} left',
              style: TextStyle(fontSize:11, fontWeight:FontWeight.w600, color: isOver ? _error : _success)),
          ]),
        ]),
        const SizedBox(height:10),
        ClipRRect(borderRadius:BorderRadius.circular(4),
          child: LinearProgressIndicator(value:cat.percentage, minHeight:7, backgroundColor:const Color(0xFFF2F2F2), valueColor:AlwaysStoppedAnimation<Color>(_barColor))),
      ]),
    );
  }
}
