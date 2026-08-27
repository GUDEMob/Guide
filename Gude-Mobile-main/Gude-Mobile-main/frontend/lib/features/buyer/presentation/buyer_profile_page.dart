import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
// COLORS (mirrors your app palette)
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFF59E0B);
}

// ─────────────────────────────────────────────
// MOCK PURCHASE DATA MODEL
// Replace with real data source when ready.
// ─────────────────────────────────────────────
class _Purchase {
  final String id;
  final String title;
  final String provider;
  final String price;
  final String date;
  final String status; // 'completed' | 'in_progress' | 'cancelled'
  final String emoji;

  const _Purchase({
    required this.id,
    required this.title,
    required this.provider,
    required this.price,
    required this.date,
    required this.status,
    required this.emoji,
  });
}

// Mock purchases — swap out for real data layer
const _mockPurchases = [
  _Purchase(
    id: 'p1',
    title: 'CV & Cover Letter Writing',
    provider: 'Priya S.',
    price: 'R180',
    date: '20 Mar 2026',
    status: 'completed',
    emoji: '📄',
  ),
  _Purchase(
    id: 'p2',
    title: 'Graphic Design',
    provider: 'Yusuf A.',
    price: 'R200',
    date: '14 Mar 2026',
    status: 'in_progress',
    emoji: '🎨',
  ),
  _Purchase(
    id: 'p3',
    title: 'Photography Session',
    provider: 'Nandi M.',
    price: 'R350',
    date: '2 Mar 2026',
    status: 'completed',
    emoji: '📷',
  ),
  _Purchase(
    id: 'p4',
    title: 'Coding Help – Python',
    provider: 'Keanu N.',
    price: 'R150',
    date: '22 Feb 2026',
    status: 'completed',
    emoji: '💻',
  ),
  _Purchase(
    id: 'p5',
    title: 'Video Editing',
    provider: 'Thabo G.',
    price: 'R250',
    date: '10 Feb 2026',
    status: 'cancelled',
    emoji: '🎬',
  ),
];

// ─────────────────────────────────────────────
// BUYER PROFILE PAGE
// ─────────────────────────────────────────────
class BuyerProfilePage extends StatefulWidget {
  const BuyerProfilePage({super.key});

  @override
  State<BuyerProfilePage> createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage> {
  // ── Derived stats ──────────────────────────
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

  // ── Logout dialog ──────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _C.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text(
              'Log Out',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact support ────────────────────────
  void _contactSupport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SupportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: _C.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => context.go('/buyer/marketplace'),
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 20),
                onPressed: () {}, // TODO: open edit profile
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Profile header ──────────────────
                Container(
                  width: double.infinity,
                  color: _C.primary,
                  padding:
                      const EdgeInsets.only(bottom: 28, left: 20, right: 20),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 2.5),
                            ),
                            child: const Center(
                              child: Text(
                                'J',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {}, // TODO: pick image
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    size: 14, color: _C.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Name
                      const Text(
                        'Jane Buyer',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      // Email
                      const Text(
                        'jane@gmail.com',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                color: Colors.white70, size: 13),
                            SizedBox(width: 5),
                            Text(
                              'Buyer Account',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stats row ───────────────────────
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      _StatCell(
                          label: 'Orders',
                          value: '$_totalOrders',
                          bordered: true),
                      _StatCell(
                          label: 'City', value: 'Cape Town', bordered: true),
                      _StatCell(
                          label: 'Total Spent',
                          value: _totalSpent,
                          bordered: false),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Account info card ───────────────
                _SectionCard(
                  title: 'Account Information',
                  child: Column(
                    children: const [
                      _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: 'Jane Buyer'),
                      _Divider(),
                      _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: 'jane@gmail.com'),
                      _Divider(),
                      _InfoRow(
                          icon: Icons.location_city_outlined,
                          label: 'City',
                          value: 'Cape Town'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Purchase history ────────────────
                _SectionCard(
                  title: 'Purchase History',
                  trailing: const Text(
                    'See all',
                    style: TextStyle(
                        fontSize: 12,
                        color: _C.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  child: _mockPurchases.isEmpty
                      ? const _EmptyHistory()
                      : Column(
                          children: List.generate(
                            _mockPurchases.length,
                            (i) => Column(
                              children: [
                                _PurchaseTile(purchase: _mockPurchases[i]),
                                if (i < _mockPurchases.length - 1)
                                  const _Divider(),
                              ],
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 12),

                // ── Help & support ──────────────────
                _SectionCard(
                  title: 'Help & Support',
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Contact Support',
                        onTap: _contactSupport,
                      ),
                      const _Divider(),
                      _MenuRow(
                        icon: Icons.help_outline_rounded,
                        label: 'FAQs',
                        onTap: () {}, // TODO
                      ),
                      const _Divider(),
                      _MenuRow(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy & Terms',
                        onTap: () {}, // TODO
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Logout ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _showLogoutDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _C.primary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              color: _C.primary, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Log Out',
                            style: TextStyle(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ],
                      ),
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
}

// ─────────────────────────────────────────────
// STAT CELL
// ─────────────────────────────────────────────
class _StatCell extends StatelessWidget {
  final String label, value;
  final bool bordered;
  const _StatCell(
      {required this.label, required this.value, required this.bordered});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            right:
                bordered ? const BorderSide(color: _C.border) : BorderSide.none,
            bottom: const BorderSide(color: _C.border),
          ),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _C.dark)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: _C.grey)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION CARD WRAPPER
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.dark)),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1, color: _C.border),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFO ROW
// ─────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _C.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: _C.grey)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _C.dark)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PURCHASE TILE
// ─────────────────────────────────────────────
class _PurchaseTile extends StatelessWidget {
  final _Purchase purchase;
  const _PurchaseTile({required this.purchase});

  Color get _statusColor {
    switch (purchase.status) {
      case 'completed':
        return _C.success;
      case 'in_progress':
        return _C.warning;
      case 'cancelled':
        return _C.grey;
      default:
        return _C.grey;
    }
  }

  Color get _statusBg {
    switch (purchase.status) {
      case 'completed':
        return const Color(0xFFEAF3DE);
      case 'in_progress':
        return const Color(0xFFFAEEDA);
      case 'cancelled':
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String get _statusLabel {
    switch (purchase.status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'cancelled':
        return 'Cancelled';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(purchase.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // Title + provider + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(purchase.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.dark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${purchase.provider} · ${purchase.date}',
                    style: const TextStyle(fontSize: 11, color: _C.grey)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Price + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(purchase.price,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _C.primary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MENU ROW (Help & Support items)
// ─────────────────────────────────────────────
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _C.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: _C.dark)),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: _C.grey),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY HISTORY STATE
// ─────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 40, color: _C.grey),
            SizedBox(height: 10),
            Text('No purchases yet',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _C.dark)),
            SizedBox(height: 4),
            Text('Browse the marketplace to get started',
                style: TextStyle(fontSize: 12, color: _C.grey)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// THIN DIVIDER
// ─────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: _C.border, indent: 16, endIndent: 16);
}

// ─────────────────────────────────────────────
// SUPPORT BOTTOM SHEET
// ─────────────────────────────────────────────
class _SupportSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _C.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Contact Support',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: _C.dark)),
            const SizedBox(height: 6),
            const Text(
              'Our team typically responds within a few hours.',
              style: TextStyle(fontSize: 13, color: _C.grey),
            ),
            const SizedBox(height: 20),
            // Options
            _SupportOption(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Chat',
              subtitle: 'Chat with a support agent now',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _SupportOption(
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'support@gude.co.za',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _SupportOption(
              icon: Icons.report_problem_outlined,
              title: 'Report an Issue',
              subtitle: 'Problem with an order or payment?',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _SupportOption(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _C.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.dark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: _C.grey)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, size: 18, color: _C.grey),
          ],
        ),
      ),
    );
  }
}
