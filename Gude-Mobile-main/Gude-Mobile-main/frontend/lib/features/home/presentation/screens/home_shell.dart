import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

const _red      = Color(0xFFE30613);
const _redDark  = Color(0xFFC0000F);
const _redLight = Color(0xFFFF3B3B);
const _success  = Color(0xFF4CAF50);
const _stable   = Color(0xFF4CAF50);
const _offWhite = Color(0xFFF8F8F8);
const _txt1     = Color(0xFF1A1A1A);
const _txt2     = Color(0xFF666666);
const _txtHint  = Color(0xFF9E9E9E);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  final List<Widget> _pages = const [
    _HomeDashboard(),
    _MarketplacePlaceholder(),
    WalletScreen(),
    _SupportPlaceholder(),
    _ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color:Colors.black.withOpacity(0.08), blurRadius:16, offset:const Offset(0,-2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:8, vertical:6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon:Icons.home_outlined,                   activeIcon:Icons.home_rounded,                     label:'Home',    index:0, current:_idx, onTap:()=>setState(()=>_idx=0)),
                _NavItem(icon:Icons.storefront_outlined,             activeIcon:Icons.storefront_rounded,               label:'Market',  index:1, current:_idx, onTap:()=>setState(()=>_idx=1)),
                _NavItem(icon:Icons.account_balance_wallet_outlined, activeIcon:Icons.account_balance_wallet_rounded,   label:'Wallet',  index:2, current:_idx, onTap:()=>setState(()=>_idx=2)),
                _NavItem(icon:Icons.support_agent_outlined,          activeIcon:Icons.support_agent_rounded,            label:'Support', index:3, current:_idx, onTap:()=>setState(()=>_idx=3)),
                _NavItem(icon:Icons.person_outline_rounded,          activeIcon:Icons.person_rounded,                   label:'Profile', index:4, current:_idx, onTap:()=>setState(()=>_idx=4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds:200),
        padding: const EdgeInsets.symmetric(horizontal:16, vertical:8),
        decoration: BoxDecoration(
          color: active ? _red.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(mainAxisSize:MainAxisSize.min, children:[
          Icon(active ? activeIcon : icon, color: active ? _red : _txtHint, size:22),
          const SizedBox(height:3),
          Text(label, style:TextStyle(fontSize:10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? _red : _txtHint)),
        ]),
      ),
    );
  }
}

// ── Home Dashboard ────────────────────────────────────────────────────────────
class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale:'en_ZA', symbol:'R ');
    return Scaffold(
      backgroundColor: _offWhite,
      body: CustomScrollView(slivers:[

        // greeting header
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top+16, left:24, right:24, bottom:28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight, colors:[_red,_redDark]),
              borderRadius: BorderRadius.only(bottomLeft:Radius.circular(28), bottomRight:Radius.circular(28)),
            ),
            child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
                Row(children:[
                  Container(width:36, height:36,
                    decoration: const BoxDecoration(color:Colors.white, shape:BoxShape.circle),
                    child: const Center(child:Text('G', style:TextStyle(fontSize:18, fontWeight:FontWeight.w800, color:_red)))),
                  const SizedBox(width:10),
                  const Text('Gude', style:TextStyle(fontSize:18, fontWeight:FontWeight.w700, color:Colors.white)),
                ]),
                IconButton(icon: const Icon(Icons.notifications_outlined, color:Colors.white), onPressed:(){}),
              ]),
              const SizedBox(height:20),
              const Text('Good morning 👋', style:TextStyle(fontSize:13, color:Colors.white70)),
              const Text('Welcome back, Thabo', style:TextStyle(fontSize:22, fontWeight:FontWeight.w700, color:Colors.white)),
              const SizedBox(height:20),
              // balance chip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color:Colors.white.withOpacity(0.2)),
                ),
                child: Row(children:[
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                    const Text('Wallet Balance', style:TextStyle(fontSize:12, color:Colors.white70)),
                    const SizedBox(height:2),
                    Text(fmt.format(1234.50), style: const TextStyle(fontSize:24, fontWeight:FontWeight.w800, color:Colors.white)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal:12, vertical:8),
                    decoration: BoxDecoration(
                      color: _stable.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color:_stable.withOpacity(0.4)),
                    ),
                    child: Row(children:[
                      Container(width:8, height:8, decoration: const BoxDecoration(color:_stable, shape:BoxShape.circle)),
                      const SizedBox(width:6),
                      const Text('Stable', style:TextStyle(fontSize:12, fontWeight:FontWeight.w600, color:Colors.white)),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ),

        // quick actions
        SliverToBoxAdapter(child:Padding(
          padding: const EdgeInsets.fromLTRB(20,20,20,0),
          child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            const Text('Quick Actions', style:TextStyle(fontSize:15, fontWeight:FontWeight.w700, color:_txt1)),
            const SizedBox(height:12),
            Row(children:[
              _QA(emoji:'🛍️', label:'Browse\nMarket',   onTap:(){}),
              const SizedBox(width:12),
              _QA(emoji:'➕',  label:'Create\nListing',  onTap:(){}),
              const SizedBox(width:12),
              _QA(emoji:'💸', label:'Send\nMoney',      onTap:(){}),
              const SizedBox(width:12),
              _QA(emoji:'🆘', label:'Support\nHub',     onTap:(){}),
            ]),
          ]),
        )),

        // active jobs banner
        SliverToBoxAdapter(child:Padding(
          padding: const EdgeInsets.fromLTRB(20,20,20,0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors:[Color(0xFF1A1A1A),Color(0xFF2D2D2D)], begin:Alignment.topLeft, end:Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children:[
              Container(width:44, height:44,
                decoration: BoxDecoration(color:_red.withOpacity(0.2), borderRadius:BorderRadius.circular(12)),
                child: const Icon(Icons.work_outline_rounded, color:_redLight, size:22)),
              const SizedBox(width:14),
              const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                Text('2 Active Jobs', style:TextStyle(fontSize:14, fontWeight:FontWeight.w700, color:Colors.white)),
                Text('You have pending deliverables', style:TextStyle(fontSize:12, color:Colors.white60)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:14, vertical:8),
                decoration: BoxDecoration(color:_red, borderRadius:BorderRadius.circular(10)),
                child: const Text('View', style:TextStyle(fontSize:12, fontWeight:FontWeight.w600, color:Colors.white)),
              ),
            ]),
          ),
        )),

        // recent earnings
        const SliverToBoxAdapter(child:Padding(
          padding: EdgeInsets.fromLTRB(20,24,20,12),
          child: Text('Recent Earnings', style:TextStyle(fontSize:15, fontWeight:FontWeight.w700, color:_txt1)),
        )),

        SliverList(delegate: SliverChildListDelegate([
          _EarningTile(title:'Tutoring - Sipho M.',  amount:'R 250.00', time:'2h ago',     icon:Icons.menu_book_outlined),
          _EarningTile(title:'Design Gig - Nomvula', amount:'R 400.00', time:'Yesterday',  icon:Icons.brush_outlined),
          _EarningTile(title:'Coding Help - Thabo',  amount:'R 180.00', time:'3 days ago', icon:Icons.code_rounded),
          const SizedBox(height:32),
        ])),
      ]),
    );
  }
}

class _QA extends StatelessWidget {
  final String emoji, label; final VoidCallback onTap;
  const _QA({required this.emoji, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical:14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05), blurRadius:8, offset:const Offset(0,2))],
        ),
        child: Column(children:[
          Text(emoji, style: const TextStyle(fontSize:22)),
          const SizedBox(height:6),
          Text(label, textAlign:TextAlign.center, style: const TextStyle(fontSize:10, fontWeight:FontWeight.w500, color:_txt2, height:1.3)),
        ]),
      ),
    ),
  );
}

class _EarningTile extends StatelessWidget {
  final String title, amount, time; final IconData icon;
  const _EarningTile({required this.title, required this.amount, required this.time, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20,0,20,10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.04), blurRadius:8, offset:const Offset(0,1))],
    ),
    child: Row(children:[
      Container(width:42, height:42, decoration:BoxDecoration(color:_success.withOpacity(0.1), shape:BoxShape.circle),
        child:Icon(icon, color:_success, size:20)),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text(title, style: const TextStyle(fontSize:13, fontWeight:FontWeight.w600, color:_txt1)),
        Text(time,  style: const TextStyle(fontSize:11, color:_txtHint)),
      ])),
      Text('+$amount', style: const TextStyle(fontSize:14, fontWeight:FontWeight.w700, color:_success)),
    ]),
  );
}

// ── Placeholder tabs ──────────────────────────────────────────────────────────
class _MarketplacePlaceholder extends StatelessWidget {
  const _MarketplacePlaceholder();
  @override
  Widget build(BuildContext context) => _ComingSoon(icon:Icons.storefront_outlined, label:'Marketplace');
}

class _SupportPlaceholder extends StatelessWidget {
  const _SupportPlaceholder();
  @override
  Widget build(BuildContext context) => _ComingSoon(icon:Icons.support_agent_outlined, label:'Support Hub');
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();
  @override
  Widget build(BuildContext context) => _ComingSoon(icon:Icons.person_outline_rounded, label:'Profile');
}

class _ComingSoon extends StatelessWidget {
  final IconData icon; final String label;
  const _ComingSoon({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _offWhite,
    body: SafeArea(child:Center(child:Column(mainAxisSize:MainAxisSize.min, children:[
      Container(width:72, height:72,
        decoration: BoxDecoration(color:_red.withOpacity(0.08), shape:BoxShape.circle),
        child: Icon(icon, size:36, color:_red)),
      const SizedBox(height:16),
      Text(label, style: const TextStyle(fontSize:18, fontWeight:FontWeight.w700, color:_txt1)),
      const SizedBox(height:6),
      const Text('Coming soon', style:TextStyle(color:_txtHint)),
    ]))),
  );
}
