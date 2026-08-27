// lib/features/marketplace/presentation/notifications_page.dart
// Full-page notifications (replaces pop-up sheet)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _C {
  static const primary   = Color(0xFFE30613);
  static const dark      = Color(0xFF1A1A1A);
  static const grey      = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border    = Color(0xFFEEEEEE);
}

class _Notification {
  final String id, text, time, category;
  bool read;
  _Notification({required this.id, required this.text, required this.time, required this.category, this.read = false});
}

final _sampleNotifications = [
  _Notification(id: 'n1', text: 'Sipho M. replied to your message about Maths Tutoring', time: '2 min ago', category: 'Message', read: false),
  _Notification(id: 'n2', text: 'Your order for HP Laptop was confirmed', time: '1 hr ago', category: 'Order', read: false),
  _Notification(id: 'n3', text: 'Price drop on Macbook 16 — now R18,900', time: 'Yesterday', category: 'Deal', read: true),
  _Notification(id: 'n4', text: 'A buyer is interested in your Design services', time: 'Yesterday', category: 'Interest', read: true),
  _Notification(id: 'n5', text: 'New student listing matching your saved search', time: '2 days ago', category: 'Match', read: true),
  _Notification(id: 'n6', text: 'Your withdrawal of R500 was processed', time: '3 days ago', category: 'Wallet', read: true),
];

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_Notification> _notifications = _sampleNotifications;

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  void _markAllRead() => setState(() { for (final n in _notifications) {
    n.read = true;
  } });

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Message': return const Color(0xFF3B82F6);
      case 'Order': return const Color(0xFF10B981);
      case 'Deal': return const Color(0xFFF59E0B);
      case 'Interest': return const Color(0xFF8B5CF6);
      case 'Match': return const Color(0xFFEC4899);
      case 'Wallet': return const Color(0xFF10B981);
      default: return _C.grey;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Message': return Icons.chat_bubble_outline_rounded;
      case 'Order': return Icons.shopping_bag_outlined;
      case 'Deal': return Icons.local_offer_outlined;
      case 'Interest': return Icons.person_outline_rounded;
      case 'Match': return Icons.search_rounded;
      case 'Wallet': return Icons.account_balance_wallet_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _C.dark, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(children: [
          const Text('Notifications', style: TextStyle(color: _C.dark, fontWeight: FontWeight.w800, fontSize: 18)),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(12)),
              child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: _C.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: _C.border),
              itemBuilder: (_, i) {
                final n = _notifications[i];
                final catColor = _categoryColor(n.category);
                return InkWell(
                  onTap: () => setState(() => n.read = true),
                  child: Container(
                    color: n.read ? Colors.white : _C.primary.withOpacity(0.03),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_categoryIcon(n.category), color: catColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(n.category, style: TextStyle(fontSize: 9, color: catColor, fontWeight: FontWeight.w700)),
                          ),
                          const Spacer(),
                          Text(n.time, style: TextStyle(fontSize: 11, color: n.read ? _C.grey : _C.primary)),
                        ]),
                        const SizedBox(height: 4),
                        Text(n.text, style: TextStyle(fontSize: 13, color: _C.dark, fontWeight: n.read ? FontWeight.w400 : FontWeight.w600, height: 1.4)),
                      ])),
                      if (!n.read) ...[
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: _C.primary, shape: BoxShape.circle)),
                      ],
                    ]),
                  ),
                );
              },
            ),
    );
  }

  Widget _emptyState() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.notifications_none_outlined, size: 64, color: _C.border),
      SizedBox(height: 14),
      Text('No notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _C.dark)),
      SizedBox(height: 4),
      Text('You\'re all caught up!', style: TextStyle(fontSize: 13, color: _C.grey)),
    ]),
  );
}


// ─────────────────────────────────────────────────────────────────────
// WISHLIST FULL PAGE
// ─────────────────────────────────────────────────────────────────────

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // In production, drive from MarketWishlist singleton
  final List<_WishItem> _items = [
    _WishItem(id: 'p1', name: 'HP Laptop 15.6"', price: 'R5,200', emoji: '💻', seller: 'Precious M.', category: 'Electronics'),
    _WishItem(id: 'p3', name: 'SkullCandy Headphones', price: 'R1,200', emoji: '🎧', seller: 'Aisha K.', category: 'Electronics'),
    _WishItem(id: 'p6', name: 'Casio Calculator', price: 'R245', emoji: '🧮', seller: 'Ruan P.', category: 'Stationery'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _C.dark, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(children: [
          const Text('My Wishlist', style: TextStyle(color: _C.dark, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _C.lightGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.border)),
            child: Text('${_items.length}', style: const TextStyle(color: _C.grey, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
      body: _items.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.favorite_border_rounded, size: 64, color: _C.border),
              SizedBox(height: 14),
              Text('Your wishlist is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _C.dark)),
              SizedBox(height: 4),
              Text('Tap the heart icon on any listing to save it', style: TextStyle(fontSize: 13, color: _C.grey)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = _items[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _C.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                  child: Row(children: [
                    Container(width: 60, height: 60, decoration: BoxDecoration(color: _C.lightGrey, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 30)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.dark), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${item.seller} · ${item.category}', style: const TextStyle(fontSize: 11, color: _C.grey)),
                      const SizedBox(height: 4),
                      Text(item.price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.primary)),
                    ])),
                    Column(children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _C.primary, foregroundColor: Colors.white, minimumSize: const Size(80, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.zero),
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart'), backgroundColor: const Color(0xFF10B981), duration: const Duration(seconds: 1))),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => setState(() => _items.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _C.lightGrey, borderRadius: BorderRadius.circular(6), border: Border.all(color: _C.border)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.delete_outline, size: 12, color: _C.grey),
                            SizedBox(width: 3),
                            Text('Remove', style: TextStyle(fontSize: 10, color: _C.grey)),
                          ]),
                        ),
                      ),
                    ]),
                  ]),
                );
              },
            ),
    );
  }
}

class _WishItem {
  final String id, name, price, emoji, seller, category;
  const _WishItem({required this.id, required this.name, required this.price, required this.emoji, required this.seller, required this.category});
}