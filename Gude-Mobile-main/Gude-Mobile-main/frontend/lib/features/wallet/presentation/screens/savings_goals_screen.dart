import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../wallet/domain/models/wallet_models.dart';

const _red      = Color(0xFFE30613);
const _success  = Color(0xFF4CAF50);
const _error    = Color(0xFFF44336);
const _offWhite = Color(0xFFF8F8F8);
const _surface  = Color(0xFFF2F2F2);
const _border   = Color(0xFFE0E0E0);
const _txt1     = Color(0xFF1A1A1A);
const _txt2     = Color(0xFF666666);
const _txtHint  = Color(0xFF9E9E9E);

final List<SavingsGoal> _sample = [
  SavingsGoal(id:'1', name:'Laptop',            target:8000, saved:3200, emoji:'💻'),
  SavingsGoal(id:'2', name:'Accommodation',     target:5000, saved:1800, emoji:'🏠'),
  SavingsGoal(id:'3', name:'Registration Fees', target:3000, saved:3000, emoji:'🎓'),
];

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  late List<SavingsGoal> _goals;

  @override
  void initState() { super.initState(); _goals = List.from(_sample); }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ');
    final totalSaved  = _goals.fold<double>(0, (s,g) => s + g.saved);
    final totalTarget = _goals.fold<double>(0, (s,g) => s + g.target);
    final completed   = _goals.where((g) => g.saved >= g.target).length;

    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: _red, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Savings Goals', style:TextStyle(fontWeight:FontWeight.w700, color:Colors.white)),
        iconTheme: const IconThemeData(color:Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        backgroundColor: _red, foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal', style:TextStyle(fontWeight:FontWeight.w600)),
      ),
      body: Column(children:[
        // summary header
        Container(
          color: _red,
          child: Container(
            decoration: const BoxDecoration(color:_offWhite, borderRadius:BorderRadius.only(topLeft:Radius.circular(24), topRight:Radius.circular(24))),
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(16),
                boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:12, offset:const Offset(0,2))]),
              child: Row(children:[
                _StatItem(label:'Total Saved',  value:fmt.format(totalSaved),  color:_success),
                _div(), _StatItem(label:'Target',       value:fmt.format(totalTarget), color:_txt1),
                _div(), _StatItem(label:'Completed',    value:'$completed / ${_goals.length}', color:_red),
              ]),
            ),
          ),
        ),

        // goals list
        Expanded(
          child: _goals.isEmpty
            ? _Empty(onAdd: _showAdd)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: _goals.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom:14),
                  child: _GoalCard(
                    goal: _goals[i], fmt: fmt,
                    onAddFunds: () => _showAddFunds(i),
                    onDelete: () => setState(() => _goals.removeAt(i)),
                  ),
                ),
              ),
        ),
      ]),
    );
  }

  Widget _div() => Container(width:1, height:36, color:_border, margin:const EdgeInsets.symmetric(horizontal:8));

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color:_txtHint, fontSize:14),
    filled: true, fillColor: _surface,
    border: OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:const BorderSide(color:_red, width:1.5)),
  );

  void _showAdd() {
    final nameCtrl = TextEditingController();
    final tgtCtrl  = TextEditingController();
    String emoji   = '🎯';
    const emojis   = ['🎯','💻','🏠','🎓','✈️','📱','🚗','💊','📦','💰'];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
          padding: EdgeInsets.only(left:24, right:24, top:24, bottom:MediaQuery.of(ctx).viewInsets.bottom+24),
          child: Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[
            const Text('Create Savings Goal', style:TextStyle(fontSize:18, fontWeight:FontWeight.w700)),
            const SizedBox(height:20),
            const Text('Pick an icon', style:TextStyle(fontSize:13, color:_txt2)),
            const SizedBox(height:8),
            Wrap(spacing:8, children: emojis.map((e) => GestureDetector(
              onTap: () => ss(() => emoji = e),
              child: Container(width:44, height:44,
                decoration: BoxDecoration(
                  color: e==emoji ? _red.withOpacity(0.1) : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: e==emoji ? _red : Colors.transparent, width:1.5),
                ),
                child: Center(child:Text(e, style: const TextStyle(fontSize:20))),
              ),
            )).toList()),
            const SizedBox(height:16),
            TextField(controller:nameCtrl, decoration:_dec('Goal name (e.g. Laptop)')),
            const SizedBox(height:12),
            TextField(controller:tgtCtrl, keyboardType:TextInputType.number, decoration:_dec('Target amount (R)')),
            const SizedBox(height:20),
            SizedBox(width:double.infinity, height:50,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final tgt  = double.tryParse(tgtCtrl.text) ?? 0;
                  if (name.isNotEmpty && tgt > 0) {
                    setState(() => _goals.add(SavingsGoal(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name:name, target:tgt, saved:0, emoji:emoji,
                    )));
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor:_red, shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
                child: const Text('Create Goal', style:TextStyle(color:Colors.white, fontWeight:FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showAddFunds(int i) {
    final goal    = _goals[i];
    final amtCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left:24, right:24, top:24, bottom:MediaQuery.of(ctx).viewInsets.bottom+24),
        child: Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text('${goal.emoji} Add to ${goal.name}', style: const TextStyle(fontSize:18, fontWeight:FontWeight.w700)),
          const SizedBox(height:20),
          TextField(controller:amtCtrl, keyboardType:TextInputType.number, autofocus:true, decoration:_dec('Amount to add (R)')),
          const SizedBox(height:20),
          SizedBox(width:double.infinity, height:50,
            child: ElevatedButton(
              onPressed: () {
                final add = double.tryParse(amtCtrl.text) ?? 0;
                if (add > 0) {
                  setState(() => _goals[i] = SavingsGoal(
                    id:goal.id, name:goal.name, target:goal.target,
                    saved:(goal.saved+add).clamp(0, goal.target).toDouble(),
                    emoji:goal.emoji,
                  ));
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor:_red, shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
              child: const Text('Add Funds', style:TextStyle(color:Colors.white, fontWeight:FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value; final Color color;
  const _StatItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child:Column(children:[
    Text(value, textAlign:TextAlign.center, style:TextStyle(fontSize:14, fontWeight:FontWeight.w700, color:color)),
    const SizedBox(height:2),
    Text(label, textAlign:TextAlign.center, style: const TextStyle(fontSize:11, color:_txt2)),
  ]));
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal; final NumberFormat fmt;
  final VoidCallback onAddFunds, onDelete;
  const _GoalCard({required this.goal, required this.fmt, required this.onAddFunds, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final done = goal.saved >= goal.target;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: done ? Border.all(color:_success, width:1.5) : null,
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:10, offset:const Offset(0,2))],
      ),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Row(children:[
          Container(width:48, height:48,
            decoration:BoxDecoration(color: done ? _success.withOpacity(0.1) : _red.withOpacity(0.08), borderRadius:BorderRadius.circular(14)),
            child:Center(child:Text(goal.emoji, style: const TextStyle(fontSize:22)))),
          const SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Row(children:[
              Text(goal.name, style: const TextStyle(fontSize:15, fontWeight:FontWeight.w700, color:Color(0xFF1A1A1A))),
              if (done) ...[const SizedBox(width:6), const Icon(Icons.check_circle_rounded, color:_success, size:16)],
            ]),
            Text('${fmt.format(goal.saved)} of ${fmt.format(goal.target)}', style: const TextStyle(fontSize:12, color:_txt2)),
          ])),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color:_txtHint, size:20),
            onSelected: (v) { if (v=='delete') onDelete(); },
            itemBuilder: (_) => [
              PopupMenuItem(value:'delete', child:Row(children:[
                const Icon(Icons.delete_outline_rounded, color:_error, size:18),
                const SizedBox(width:8),
                Text('Delete', style:TextStyle(color:_error)),
              ])),
            ],
          ),
        ]),
        const SizedBox(height:14),
        ClipRRect(borderRadius:BorderRadius.circular(6),
          child:LinearProgressIndicator(value:goal.percentage, minHeight:10, backgroundColor:_surface, valueColor:AlwaysStoppedAnimation<Color>(done ? _success : _red))),
        const SizedBox(height:8),
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
          Text('${(goal.percentage*100).toStringAsFixed(0)}% saved', style: const TextStyle(fontSize:11, color:_txtHint)),
          Text(done ? '🎉 Goal reached!' : '${fmt.format(goal.remaining)} to go',
            style: TextStyle(fontSize:11, fontWeight:FontWeight.w600, color: done ? _success : _txt2)),
        ]),
        if (!done) ...[
          const SizedBox(height:14),
          SizedBox(width:double.infinity, height:40,
            child:OutlinedButton(
              onPressed: onAddFunds,
              style:OutlinedButton.styleFrom(side:const BorderSide(color:_red), shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))),
              child: const Text('Add Funds', style:TextStyle(color:_red, fontWeight:FontWeight.w600, fontSize:13)),
            )),
        ],
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onAdd;
  const _Empty({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(child:Padding(padding: const EdgeInsets.all(40), child:Column(mainAxisSize:MainAxisSize.min, children:[
    Container(width:80, height:80, decoration:BoxDecoration(color:_red.withOpacity(0.08), shape:BoxShape.circle),
      child: const Center(child:Text('💰', style:TextStyle(fontSize:36)))),
    const SizedBox(height:20),
    const Text('No savings goals yet', style:TextStyle(fontSize:16, fontWeight:FontWeight.w700, color:Color(0xFF1A1A1A))),
    const SizedBox(height:8),
    const Text('Set a goal and start saving.', textAlign:TextAlign.center, style:TextStyle(fontSize:13, color:_txt2, height:1.5)),
    const SizedBox(height:24),
    ElevatedButton(onPressed:onAdd,
      style:ElevatedButton.styleFrom(backgroundColor:_red, shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)), padding:const EdgeInsets.symmetric(horizontal:28, vertical:14)),
      child: const Text('Create First Goal', style:TextStyle(color:Colors.white, fontWeight:FontWeight.w600))),
  ])));
}
