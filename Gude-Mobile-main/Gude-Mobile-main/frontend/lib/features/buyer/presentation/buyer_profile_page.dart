import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/user_role_service.dart';

class _BuyerColors {
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF687385);
  static const line = Color(0xFFDCE7FF);
  static const canvas = Color(0xFFF6F8FF);
  static const navy = Color(0xFF1D4ED8);
  static const blue = Color(0xFF2563EB);
  static const teal = Color(0xFF16875D);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFE50914);
}

class _BuyerOrder {
  final String title;
  final String seller;
  final String date;
  final String price;
  final String status;
  final IconData icon;
  final Color color;

  const _BuyerOrder({
    required this.title,
    required this.seller,
    required this.date,
    required this.price,
    required this.status,
    required this.icon,
    required this.color,
  });
}

const _orders = [
  _BuyerOrder(
    title: 'Social media design pack',
    seller: 'Yusuf A.',
    date: '28 Aug 2026',
    price: 'R200',
    status: 'In progress',
    icon: Icons.palette_outlined,
    color: _BuyerColors.blue,
  ),
  _BuyerOrder(
    title: 'CV and cover letter rewrite',
    seller: 'Priya S.',
    date: '24 Aug 2026',
    price: 'R180',
    status: 'Awaiting brief',
    icon: Icons.description_outlined,
    color: _BuyerColors.teal,
  ),
  _BuyerOrder(
    title: 'Product photography session',
    seller: 'Nandi M.',
    date: '18 Aug 2026',
    price: 'R350',
    status: 'Booked',
    icon: Icons.photo_camera_outlined,
    color: _BuyerColors.amber,
  ),
  _BuyerOrder(
    title: 'Python dashboard cleanup',
    seller: 'Keanu N.',
    date: '10 Aug 2026',
    price: 'R150/hr',
    status: 'Delivered',
    icon: Icons.code_rounded,
    color: _BuyerColors.navy,
  ),
];

class BuyerProfilePage extends StatelessWidget {
  const BuyerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BuyerColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: _BuyerColors.blue,
            foregroundColor: Colors.white,
            title: const Text(
              'Buyer Account',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () => _showSettingsSheet(context),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AccountHero(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: Row(
                    children: [
                      _ActionTile(
                        icon: Icons.add_task_rounded,
                        title: 'Post brief',
                        subtitle: 'Start a request',
                        color: _BuyerColors.blue,
                        onTap: () => context.go('/buyer/marketplace'),
                      ),
                      const SizedBox(width: 10),
                      _ActionTile(
                        icon: Icons.forum_outlined,
                        title: 'Inbox',
                        subtitle: 'Reply to sellers',
                        color: _BuyerColors.teal,
                        onTap: () => context.go('/buyer/messages'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _SectionHeader(title: 'Account details'),
                const _InfoPanel(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Name',
                      value: 'Jane Buyer',
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: 'jane@gmail.com',
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'City',
                      value: 'Cape Town',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _SectionHeader(title: 'Orders'),
              ],
            ),
          ),
          SliverList.separated(
            itemCount: _orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  index == _orders.length - 1 ? 18 : 0,
                ),
                child: _OrderCard(order: _orders[index]),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: Column(
                children: [
                  const _InfoPanel(
                    children: [
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Buyer verification',
                        value: 'Verified',
                      ),
                      _InfoRow(
                        icon: Icons.credit_card_outlined,
                        label: 'Payment method',
                        value: 'Card ending 4028',
                      ),
                      _InfoRow(
                        icon: Icons.support_agent_outlined,
                        label: 'Support',
                        value: 'Priority',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _BuyerColors.red,
                      side: BorderSide(
                        color: _BuyerColors.red.withValues(alpha: 0.25),
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _SettingsSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to role selection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              UserRoleService().clear();
              Future.microtask(() => router.go('/signup'));
            },
            style: FilledButton.styleFrom(
              backgroundColor: _BuyerColors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet();

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  bool _orderUpdates = true;
  bool _wishlistDeals = true;
  bool _serviceReminders = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _BuyerColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Buyer settings',
              style: TextStyle(
                color: _BuyerColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _SettingsSwitch(
              icon: Icons.notifications_active_outlined,
              title: 'Order updates',
              subtitle: 'Get alerts when sellers reply or deliver.',
              value: _orderUpdates,
              onChanged: (value) => setState(() => _orderUpdates = value),
            ),
            _SettingsSwitch(
              icon: Icons.local_offer_outlined,
              title: 'Wishlist deals',
              subtitle: 'Notify me when saved items get discounts.',
              value: _wishlistDeals,
              onChanged: (value) => setState(() => _wishlistDeals = value),
            ),
            _SettingsSwitch(
              icon: Icons.event_available_outlined,
              title: 'Service reminders',
              subtitle: 'Remind me before booked service sessions.',
              value: _serviceReminders,
              onChanged: (value) => setState(() => _serviceReminders = value),
            ),
            const SizedBox(height: 8),
            const _SettingsAction(
              icon: Icons.location_on_outlined,
              title: 'Delivery location',
              subtitle: 'Cape Town',
            ),
            const _SettingsAction(
              icon: Icons.credit_card_outlined,
              title: 'Payment methods',
              subtitle: 'Card ending 4028',
            ),
            const _SettingsAction(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy and security',
              subtitle: 'Manage account protection',
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: _BuyerColors.blue,
      secondary: Icon(icon, color: _BuyerColors.blue),
      title: Text(
        title,
        style: const TextStyle(
          color: _BuyerColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: _BuyerColors.muted,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _BuyerColors.blue),
      title: Text(
        title,
        style: const TextStyle(
          color: _BuyerColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: _BuyerColors.muted,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: _BuyerColors.muted,
      ),
      onTap: () {},
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_BuyerColors.red, _BuyerColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'JB',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jane Buyer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 21,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hiring student talent across design, content and tech.',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _Metric(label: 'Orders', value: '4'),
              SizedBox(width: 10),
              _Metric(label: 'Spent', value: 'R880'),
              SizedBox(width: 10),
              _Metric(label: 'Rating', value: '4.9'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _BuyerColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _BuyerColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _BuyerColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: _BuyerColors.ink,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final List<Widget> children;

  const _InfoPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _BuyerColors.line),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: _BuyerColors.muted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _BuyerColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _BuyerColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _BuyerOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _BuyerColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: order.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(order.icon, color: order.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _BuyerColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${order.seller} - ${order.date}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _BuyerColors.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: order.color.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: order.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            order.price,
            style: const TextStyle(
              color: _BuyerColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
