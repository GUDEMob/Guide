// lib/features/buyer/presentation/buyer_profile_page.dart
// Buyer profile — visually distinct from student, reflects registration info,
// includes buyer ↔ seller messaging, logout → /login
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _C {
  static const primary   = Color(0xFF1A3A8F); // buyer brand = navy (distinct from student red)
  static const accent    = Color(0xFF2D5BE3);
  static const dark      = Color(0xFF1A1A1A);
  static const grey      = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border    = Color(0xFFEEEEEE);
  static const success   = Color(0xFF4CAF50);
  static const warning   = Color(0xFFF59E0B);
  static const red       = Color(0xFFE30613); // only for logout/danger
}

// Simulated buyer data — in production this comes from registration
class BuyerAccountData {
  static String fullName    = 'Jane Buyer';
  static String email       = 'jane@gmail.com';
  static String city        = 'Cape Town';
  static String phone       = '+27 82 555 0000';
  static String accountType = 'Individual Buyer';
  static String memberSince = 'March 2026';
}

class _Purchase {
  final String id, title, provider, price, date, status, emoji;
  const _Purchase({required this.id, required this.title, required this.provider, required this.price, required this.date, required this.status, required this.emoji});
}

const _mockPurchases = [
  _Purchase(id:'p1', title:'CV & Cover Letter Writing', provider:'Priya S.', price:'R180', date:'20 Mar 2026', status:'completed', emoji:'📄'),
  _Purchase(id:'p2', title:'Graphic Design',            provider:'Yusuf A.', price:'R200', date:'14 Mar 2026', status:'in_progress', emoji:'🎨'),
  _Purchase(id:'p3', title:'Photography Session',       provider:'Nandi M.', price:'R350', date:'2 Mar 2026',  status:'completed', emoji:'📷'),
  _Purchase(id:'p4', title:'Coding Help — Python',      provider:'Keanu N.', price:'R150', date:'22 Feb 2026', status:'completed', emoji:'💻'),
  _Purchase(id:'p5', title:'Video Editing',             provider:'Thabo G.', price:'R250', date:'10 Feb 2026', status:'cancelled', emoji:'🎬'),
];

class BuyerProfilePage extends StatefulWidget {
  const BuyerProfilePage({super.key});
  @override
  State<BuyerProfilePage> createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage> {
  int get _totalOrders => _mockPurchases.length;

  String get _totalSpent {
    int total = 0;
    for (final p in _mockPurchases) {
      if (p.status != 'cancelled') {
        final digits = p.price.replaceAll(RegExp(r'[^0-9]'), '');
        total += int.tryParse(digits) ?? 0;
      }
    }
    return 'R$total';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Capture the router reference BEFORE popping the dialog
              final nav = GoRouter.of(context);
              Navigator.pop(context);
              // Defer navigation until the dialog is fully dismissed
              Future.microtask(() => nav.go('/login'));
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openMessaging() => context.push('/messages');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.lightGrey,
      body: CustomScrollView(
        slivers: [
          // ── App bar — navy buyer theme ─────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: _C.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
              onPressed: () => context.go('/buyer/marketplace'),
            ),
            title: const Text('My Account', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                onPressed: _showLogoutDialog,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Buyer header — navy gradient, distinct from student red ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1A3A8F), Color(0xFF2D5BE3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  padding: const EdgeInsets.only(bottom: 28, left: 20, right: 20, top: 8),
                  child: Column(children: [
                    // Avatar with camera button
                    Stack(children: [
                      Container(
                        width: 84, height: 84,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5)),
                        child: const Center(child: Text('J', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700))),
                      ),
                      Positioned(bottom: 0, right: 0, child: GestureDetector(
                        onTap: () {},
                        child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.camera_alt_rounded, size: 15, color: Color(0xFF1A3A8F))),
                      )),
                    ]),
                    const SizedBox(height: 10),
                    Text(BuyerAccountData.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(BuyerAccountData.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    // Buyer badge — shopping bag icon (not student mortarboard)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white70, size: 13),
                        const SizedBox(width: 5),
                        Text(BuyerAccountData.accountType, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 12, color: Colors.white38),
                        const SizedBox(width: 8),
                        Text('Since ${BuyerAccountData.memberSince}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                      ]),
                    ),
                  ]),
                ),

                // ── Stats row ────────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  child: Row(children: [
                    _StatCell(label: 'Orders', value: '$_totalOrders', bordered: true),
                    _StatCell(label: 'City', value: BuyerAccountData.city, bordered: true),
                    _StatCell(label: 'Total Spent', value: _totalSpent, bordered: false),
                  ]),
                ),

                const SizedBox(height: 10),

                // ── Message a seller ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _openMessaging,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _C.primary.withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: _C.primary.withOpacity(0.06), blurRadius: 8)],
                      ),
                      child: Row(children: [
                        Container(width: 42, height: 42, decoration: BoxDecoration(color: _C.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.chat_bubble_outline_rounded, color: _C.primary, size: 20)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Message a Seller', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.dark)),
                          const Text('Ask questions or send service requests', style: TextStyle(fontSize: 11, color: _C.grey)),
                        ])),
                        const Icon(Icons.chevron_right_rounded, color: _C.grey, size: 20),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Account info — shows registration data ───────────────────
                _SectionCard(
                  title: 'Account Information',
                  child: Column(children: [
                    _InfoRow(icon: Icons.person_outline_rounded, label: 'Full Name', value: BuyerAccountData.fullName),
                    const _HDivider(),
                    _InfoRow(icon: Icons.email_outlined, label: 'Email', value: BuyerAccountData.email),
                    const _HDivider(),
                    _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: BuyerAccountData.phone),
                    const _HDivider(),
                    _InfoRow(icon: Icons.location_city_outlined, label: 'City', value: BuyerAccountData.city),
                    const _HDivider(),
                    _InfoRow(icon: Icons.badge_outlined, label: 'Account Type', value: BuyerAccountData.accountType),
                  ]),
                ),

                const SizedBox(height: 10),

                // ── Find students by skill ───────────────────────────────────
                _SectionCard(
                  title: 'Find Talent by Skill',
                  trailing: GestureDetector(
                    onTap: () => context.push('/marketplace'),
                    child: const Text('Browse all', style: TextStyle(fontSize: 12, color: _C.primary, fontWeight: FontWeight.w600)),
                  ),
                  child: Column(children: [
                    const _SkillSearchHint(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final skill in ['Tutoring', 'Design', 'Coding', 'Photography', 'Writing', 'Marketing'])
                          GestureDetector(
                            onTap: () => context.push('/marketplace'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: _C.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: _C.primary.withOpacity(0.2))),
                              child: Text(skill, style: const TextStyle(fontSize: 12, color: _C.primary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ]),
                    ),
                  ]),
                ),

                const SizedBox(height: 10),

                // ── Purchase history ─────────────────────────────────────────
                _SectionCard(
                  title: 'Purchase History',
                  trailing: const Text('See all', style: TextStyle(fontSize: 12, color: _C.primary, fontWeight: FontWeight.w600)),
                  child: _mockPurchases.isEmpty
                      ? const _EmptyHistory()
                      : Column(children: List.generate(_mockPurchases.length, (i) => Column(children: [
                          _PurchaseTile(purchase: _mockPurchases[i]),
                          if (i < _mockPurchases.length - 1) const _HDivider(),
                        ]))),
                ),

                const SizedBox(height: 10),

                // ── Help & support ───────────────────────────────────────────
                _SectionCard(
                  title: 'Help & Support',
                  child: Column(children: [
                    _MenuRow(icon: Icons.chat_bubble_outline_rounded, label: 'Contact Support', onTap: () => _showSupportSheet()),
                    const _HDivider(),
                    _MenuRow(icon: Icons.help_outline_rounded, label: 'FAQs', onTap: () {}),
                    const _HDivider(),
                    _MenuRow(icon: Icons.privacy_tip_outlined, label: 'Privacy & Terms', onTap: () {}),
                  ]),
                ),

                const SizedBox(height: 10),

                // ── Logout ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _showLogoutDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _C.red.withOpacity(0.3))),
                      child: const Row(children: [
                        Icon(Icons.logout_rounded, color: _C.red, size: 20),
                        SizedBox(width: 12),
                        Text('Log Out', style: TextStyle(color: _C.red, fontWeight: FontWeight.w700, fontSize: 14)),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(2)))),
          const Text('Contact Support', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _C.dark)),
          const SizedBox(height: 6),
          const Text('We typically respond within a few hours.', style: TextStyle(fontSize: 13, color: _C.grey)),
          const SizedBox(height: 20),
          for (final item in [
            {'icon': Icons.chat_bubble_outline_rounded, 'title': 'Live Chat', 'sub': 'Chat with a support agent now'},
            {'icon': Icons.email_outlined, 'title': 'Email Us', 'sub': 'support@gude.co.za'},
            {'icon': Icons.report_problem_outlined, 'title': 'Report an Issue', 'sub': 'Problem with an order or payment?'},
          ]) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: _C.lightGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.border)),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: _C.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(item['icon'] as IconData, color: _C.primary, size: 20)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.dark)),
                    Text(item['sub'] as String, style: const TextStyle(fontSize: 11, color: _C.grey)),
                  ]),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: _C.grey),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─── Skill search hint ────────────────────────────────────────────────
class _SkillSearchHint extends StatelessWidget {
  const _SkillSearchHint();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE))),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 16, color: Color(0xFFAAAAAA)),
          const SizedBox(width: 8),
          const Text('Search for a skill…', style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
        ]),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String label, value;
  final bool bordered;
  const _StatCell({required this.label, required this.value, required this.bordered});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(right: bordered ? const BorderSide(color: _C.border) : BorderSide.none, bottom: const BorderSide(color: _C.border))),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.dark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: _C.grey)),
      ]),
    ));
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _C.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.dark)),
            if (trailing != null) trailing!,
          ]),
        ),
        const Divider(height: 1, color: _C.border),
        child,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Icon(icon, size: 18, color: _C.grey),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: _C.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.dark)),
      ]),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final _Purchase purchase;
  const _PurchaseTile({required this.purchase});

  Color get _statusColor => purchase.status == 'completed' ? _C.success : purchase.status == 'in_progress' ? _C.warning : _C.grey;
  Color get _statusBg => purchase.status == 'completed' ? const Color(0xFFEAF3DE) : purchase.status == 'in_progress' ? const Color(0xFFFAEEDA) : _C.lightGrey;
  String get _statusLabel => purchase.status == 'completed' ? 'Completed' : purchase.status == 'in_progress' ? 'In Progress' : 'Cancelled';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: _C.lightGrey, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(purchase.emoji, style: const TextStyle(fontSize: 22)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(purchase.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.dark), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('${purchase.provider} · ${purchase.date}', style: const TextStyle(fontSize: 11, color: _C.grey)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(purchase.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _C.primary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(10)),
            child: Text(_statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor)),
          ),
        ]),
      ]),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuRow({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 20, color: _C.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: _C.dark))),
          const Icon(Icons.chevron_right_rounded, size: 18, color: _C.grey),
        ]),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
    child: Center(child: Column(children: [
      Icon(Icons.receipt_long_outlined, size: 40, color: _C.grey),
      SizedBox(height: 10),
      Text('No purchases yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.dark)),
      SizedBox(height: 4),
      Text('Browse the marketplace to get started', style: TextStyle(fontSize: 12, color: _C.grey)),
    ])),
  );
}

class _HDivider extends StatelessWidget {
  const _HDivider();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: _C.border, indent: 16, endIndent: 16);
}