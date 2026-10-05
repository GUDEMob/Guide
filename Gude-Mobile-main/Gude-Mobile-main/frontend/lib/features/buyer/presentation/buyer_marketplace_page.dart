import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/user_role_service.dart';

class _BuyerColors {
  static const primary = Color(0xFFE30613);
  static const primaryDark = Color(0xFF1D4ED8);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF687385);
  static const line = Color(0xFFDCE7FF);
  static const canvas = Color(0xFFF6F8FF);
  static const success = Color(0xFF16875D);
  static const blue = Color(0xFF2563EB);
  static const sky = Color(0xFF38BDF8);
  static const amber = Color(0xFFF59E0B);
}

class _MarketItem {
  final String id;
  final String name;
  final String seller;
  final String category;
  final String type;
  final String priceLabel;
  final double priceValue;
  final String detail;
  final String imageUrl;
  final double rating;
  final int reviews;
  final int stockLeft;
  final IconData fallbackIcon;
  final Color accent;
  final bool wishlisted;

  const _MarketItem({
    required this.id,
    required this.name,
    required this.seller,
    required this.category,
    required this.type,
    required this.priceLabel,
    required this.priceValue,
    required this.detail,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.stockLeft,
    required this.fallbackIcon,
    required this.accent,
    this.wishlisted = false,
  });
}

const _categories = [
  _Category('All', Icons.dashboard_rounded),
  _Category('Products', Icons.shopping_bag_rounded),
  _Category('Services', Icons.handshake_rounded),
  _Category('Electronics', Icons.devices_rounded),
  _Category('Study Gear', Icons.menu_book_rounded),
  _Category('Stationery', Icons.edit_note_rounded),
  _Category('Fashion', Icons.checkroom_rounded),
  _Category('Design', Icons.palette_rounded),
  _Category('Wishlist', Icons.favorite_rounded),
];

class _Category {
  final String label;
  final IconData icon;

  const _Category(this.label, this.icon);
}

const _items = [
  _MarketItem(
    id: 'study-pack',
    name: 'Exam Study Pack',
    seller: 'Naledi Prints',
    category: 'Study Gear',
    type: 'Product',
    priceLabel: 'R120',
    priceValue: 120,
    detail: 'Summaries, flashcards and planner sheets.',
    imageUrl:
        'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
    reviews: 42,
    stockLeft: 8,
    fallbackIcon: Icons.menu_book_rounded,
    accent: _BuyerColors.primary,
    wishlisted: true,
  ),
  _MarketItem(
    id: 'laptop-stand',
    name: 'Foldable Laptop Stand',
    seller: 'Campus Gear Co.',
    category: 'Products',
    type: 'Product',
    priceLabel: 'R260',
    priceValue: 260,
    detail: 'Lightweight desk setup for study sessions.',
    imageUrl:
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=80',
    rating: 4.6,
    reviews: 18,
    stockLeft: 5,
    fallbackIcon: Icons.laptop_mac_rounded,
    accent: _BuyerColors.blue,
  ),
  _MarketItem(
    id: 'brand-kit',
    name: 'Social Brand Kit',
    seller: 'Yusuf A.',
    category: 'Design',
    type: 'Service',
    priceLabel: 'From R200',
    priceValue: 200,
    detail: 'Logo cleanup, covers and launch graphics.',
    imageUrl:
        'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
    reviews: 28,
    stockLeft: 3,
    fallbackIcon: Icons.design_services_rounded,
    accent: _BuyerColors.primary,
    wishlisted: true,
  ),
  _MarketItem(
    id: 'tutoring',
    name: 'Maths Tutoring',
    seller: 'Amina K.',
    category: 'Services',
    type: 'Service',
    priceLabel: 'R160/hr',
    priceValue: 160,
    detail: 'Calculus, stats and exam prep support.',
    imageUrl:
        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=80',
    rating: 5.0,
    reviews: 33,
    stockLeft: 4,
    fallbackIcon: Icons.school_rounded,
    accent: _BuyerColors.success,
  ),
  _MarketItem(
    id: 'photo-shoot',
    name: 'Product Photo Shoot',
    seller: 'Nandi M.',
    category: 'Services',
    type: 'Service',
    priceLabel: 'From R350',
    priceValue: 350,
    detail: 'Clean product photos for small brands.',
    imageUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
    reviews: 16,
    stockLeft: 2,
    fallbackIcon: Icons.photo_camera_rounded,
    accent: _BuyerColors.amber,
  ),
  _MarketItem(
    id: 'wireless-headphones',
    name: 'Wireless Headphones',
    seller: 'Res Tech Deals',
    category: 'Products',
    type: 'Product',
    priceLabel: 'R390',
    priceValue: 390,
    detail: 'Noise-friendly headphones for calls and study.',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
    rating: 4.5,
    reviews: 21,
    stockLeft: 6,
    fallbackIcon: Icons.headphones_rounded,
    accent: _BuyerColors.sky,
  ),
  _MarketItem(
    id: 'tablet',
    name: 'Samsung Study Tablet',
    seller: 'Tech Corner',
    category: 'Electronics',
    type: 'Product',
    priceLabel: 'R1800',
    priceValue: 1800,
    detail: 'Pre-owned tablet for notes, PDFs and online lectures.',
    imageUrl:
        'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
    reviews: 24,
    stockLeft: 3,
    fallbackIcon: Icons.tablet_mac_rounded,
    accent: _BuyerColors.blue,
  ),
  _MarketItem(
    id: 'keyboard-mouse',
    name: 'Keyboard and Mouse Set',
    seller: 'Campus Gear Co.',
    category: 'Electronics',
    type: 'Product',
    priceLabel: 'R220',
    priceValue: 220,
    detail: 'Compact wireless set for desk setups and assignments.',
    imageUrl:
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=900&q=80',
    rating: 4.6,
    reviews: 19,
    stockLeft: 7,
    fallbackIcon: Icons.keyboard_rounded,
    accent: _BuyerColors.sky,
  ),
  _MarketItem(
    id: 'power-bank',
    name: 'Fast Charge Power Bank',
    seller: 'Res Tech Deals',
    category: 'Electronics',
    type: 'Product',
    priceLabel: 'R180',
    priceValue: 180,
    detail: 'Slim 10000mAh power bank for campus and travel.',
    imageUrl:
        'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
    reviews: 37,
    stockLeft: 9,
    fallbackIcon: Icons.battery_charging_full_rounded,
    accent: _BuyerColors.primary,
    wishlisted: true,
  ),
  _MarketItem(
    id: 'desk-lamp',
    name: 'LED Desk Lamp',
    seller: 'Braam Finds',
    category: 'Study Gear',
    type: 'Product',
    priceLabel: 'R150',
    priceValue: 150,
    detail: 'Adjustable lamp with three brightness modes.',
    imageUrl:
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=900&q=80',
    rating: 4.5,
    reviews: 15,
    stockLeft: 5,
    fallbackIcon: Icons.light_mode_rounded,
    accent: _BuyerColors.amber,
  ),
  _MarketItem(
    id: 'notebook-bundle',
    name: 'Notebook Bundle',
    seller: 'Naledi Prints',
    category: 'Stationery',
    type: 'Product',
    priceLabel: 'R95',
    priceValue: 95,
    detail: 'Five notebooks with sticky tabs and subject labels.',
    imageUrl:
        'https://images.unsplash.com/photo-1531346680769-a1d79b57de5c?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
    reviews: 51,
    stockLeft: 12,
    fallbackIcon: Icons.edit_note_rounded,
    accent: _BuyerColors.primary,
  ),
  _MarketItem(
    id: 'calculator',
    name: 'Scientific Calculator',
    seller: 'Study Supply Hub',
    category: 'Stationery',
    type: 'Product',
    priceLabel: 'R210',
    priceValue: 210,
    detail: 'Exam-ready calculator for maths, stats and accounting.',
    imageUrl:
        'https://images.unsplash.com/photo-1616627987101-3f52c0b5f510?auto=format&fit=crop&w=900&q=80',
    rating: 4.7,
    reviews: 29,
    stockLeft: 4,
    fallbackIcon: Icons.calculate_rounded,
    accent: _BuyerColors.blue,
  ),
  _MarketItem(
    id: 'campus-hoodie',
    name: 'Campus Hoodie',
    seller: 'Thread Lab',
    category: 'Fashion',
    type: 'Product',
    priceLabel: 'R320',
    priceValue: 320,
    detail: 'Warm unisex hoodie for lectures, res and weekend wear.',
    imageUrl:
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=900&q=80',
    rating: 4.8,
    reviews: 34,
    stockLeft: 6,
    fallbackIcon: Icons.checkroom_rounded,
    accent: _BuyerColors.sky,
  ),
  _MarketItem(
    id: 'tote-bag',
    name: 'Canvas Tote Bag',
    seller: 'Thread Lab',
    category: 'Fashion',
    type: 'Product',
    priceLabel: 'R85',
    priceValue: 85,
    detail: 'Durable campus tote for books, laptop sleeves and groceries.',
    imageUrl:
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=80',
    rating: 4.6,
    reviews: 22,
    stockLeft: 10,
    fallbackIcon: Icons.shopping_bag_rounded,
    accent: _BuyerColors.amber,
  ),
  _MarketItem(
    id: 'phone-repair',
    name: 'Phone Screen Repair',
    seller: 'Sipho Fixes',
    category: 'Services',
    type: 'Service',
    priceLabel: 'From R450',
    priceValue: 450,
    detail: 'Student phone repair with quote before work starts.',
    imageUrl:
        'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=900&q=80',
    rating: 4.9,
    reviews: 40,
    stockLeft: 4,
    fallbackIcon: Icons.build_rounded,
    accent: _BuyerColors.success,
  ),
  _MarketItem(
    id: 'assignment-proofread',
    name: 'Assignment Proofread',
    seller: 'Priya S.',
    category: 'Services',
    type: 'Service',
    priceLabel: 'From R90',
    priceValue: 90,
    detail: 'Grammar, structure and citation checks before submission.',
    imageUrl:
        'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=900&q=80',
    rating: 5.0,
    reviews: 46,
    stockLeft: 8,
    fallbackIcon: Icons.rate_review_rounded,
    accent: _BuyerColors.primary,
  ),
  _MarketItem(
    id: 'mini-fridge',
    name: 'Mini Fridge',
    seller: 'Res Room Deals',
    category: 'Products',
    type: 'Product',
    priceLabel: 'R950',
    priceValue: 950,
    detail: 'Compact fridge for res rooms and shared spaces.',
    imageUrl:
        'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=900&q=80',
    rating: 4.4,
    reviews: 12,
    stockLeft: 2,
    fallbackIcon: Icons.kitchen_rounded,
    accent: _BuyerColors.blue,
  ),
  _MarketItem(
    id: 'desk-chair',
    name: 'Study Desk Chair',
    seller: 'Braam Finds',
    category: 'Products',
    type: 'Product',
    priceLabel: 'R420',
    priceValue: 420,
    detail: 'Comfortable chair for long study sessions.',
    imageUrl:
        'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?auto=format&fit=crop&w=900&q=80',
    rating: 4.5,
    reviews: 17,
    stockLeft: 3,
    fallbackIcon: Icons.event_seat_rounded,
    accent: _BuyerColors.amber,
  ),
];

class BuyerMarketplacePage extends StatefulWidget {
  const BuyerMarketplacePage({super.key});

  @override
  State<BuyerMarketplacePage> createState() => _BuyerMarketplacePageState();
}

class _BuyerMarketplacePageState extends State<BuyerMarketplacePage> {
  final _searchCtrl = TextEditingController();
  final Set<String> _wishlist = {
    for (final item in _items)
      if (item.wishlisted) item.id,
  };
  final Map<String, int> _cart = {};

  String _category = 'All';
  String _query = '';

  int get _cartCount => _cart.values.fold(0, (total, qty) => total + qty);

  double get _cartTotal => _cart.entries.fold(0, (total, entry) {
        final item = _items.firstWhere((item) => item.id == entry.key);
        return total + item.priceValue * entry.value;
      });

  List<_MarketItem> get _visibleItems {
    final q = _query.trim().toLowerCase();
    return _items.where((item) {
      final matchesCategory = switch (_category) {
        'Products' => item.type == 'Product',
        'Services' => item.type == 'Service',
        'Wishlist' => _wishlist.contains(item.id),
        'All' => true,
        _ => item.category == _category,
      };
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.seller.toLowerCase().contains(q) ||
          item.detail.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    final buyerName = UserRoleService().userName.trim();

    return Scaffold(
      backgroundColor: _BuyerColors.canvas,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(
                          buyerName: buyerName.isEmpty ? 'Buyer' : buyerName,
                          onWishlist: () =>
                              setState(() => _category = 'Wishlist'),
                          onOrders: () => context.go('/buyer/profile'),
                        ),
                        const SizedBox(height: 14),
                        _SearchRow(
                          controller: _searchCtrl,
                          onChanged: (value) => setState(() => _query = value),
                          onFilter: () => _showFilterSheet(context),
                        ),
                        const SizedBox(height: 12),
                        _CategoryRail(
                          selected: _category,
                          onSelect: (value) =>
                              setState(() => _category = value),
                        ),
                        const SizedBox(height: 16),
                        _PromoBanner(
                          onShopNow: () =>
                              setState(() => _category = 'Services'),
                        ),
                        const SizedBox(height: 18),
                        _SectionTitle(
                          title: _category == 'Wishlist'
                              ? 'Saved favourites'
                              : 'Featured marketplace',
                          count: visible.length,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (visible.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyWishlist(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    _cartCount > 0 ? 96 : 28,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 225,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = visible[index];
                        return _MarketTile(
                          item: item,
                          saved: _wishlist.contains(item.id),
                          quantity: _cart[item.id] ?? 0,
                          onWishlist: () => _toggleWishlist(item.id),
                          onAdd: () => _addToCart(item.id),
                          onOpen: () => item.type == 'Service'
                              ? context.go('/buyer/messages')
                              : _addToCart(item.id),
                        );
                      },
                      childCount: visible.length,
                    ),
                  ),
                ),
            ],
          ),
          if (_cartCount > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: _CartBar(
                count: _cartCount,
                total: _cartTotal,
                onView: () => context.go('/buyer/profile'),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleWishlist(String id) {
    setState(() {
      if (_wishlist.contains(id)) {
        _wishlist.remove(id);
      } else {
        _wishlist.add(id);
      }
    });
  }

  void _addToCart(String id) {
    setState(() => _cart[id] = (_cart[id] ?? 0) + 1);
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _BuyerColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filter marketplace',
                  style: TextStyle(
                    color: _BuyerColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ..._categories.map(
                (category) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    category.icon,
                    color: category.label == _category
                        ? _BuyerColors.blue
                        : _BuyerColors.muted,
                  ),
                  title: Text(
                    category.label,
                    style: TextStyle(
                      color: category.label == _category
                          ? _BuyerColors.blue
                          : _BuyerColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: category.label == _category
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: _BuyerColors.blue,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _category = category.label);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String buyerName;
  final VoidCallback onWishlist;
  final VoidCallback onOrders;

  const _TopBar({
    required this.buyerName,
    required this.onWishlist,
    required this.onOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _BuyerColors.primary.withValues(alpha: 0.12),
                _BuyerColors.blue.withValues(alpha: 0.16),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            color: _BuyerColors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: _BuyerColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                buyerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _BuyerColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Wishlist',
          onPressed: onWishlist,
          icon: const Icon(Icons.favorite_border_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _BuyerColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Orders',
          onPressed: onOrders,
          icon: const Icon(Icons.receipt_long_outlined),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _BuyerColors.ink,
          ),
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'What are you looking for?',
                hintStyle: const TextStyle(
                  color: _BuyerColors.muted,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _BuyerColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _BuyerColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: _BuyerColors.blue, width: 1.4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 46,
          height: 46,
          child: IconButton.filled(
            tooltip: 'Filters',
            onPressed: onFilter,
            icon: const Icon(Icons.tune_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _BuyerColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryRail({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = _categories[index];
          final active = selected == item.label;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelect(item.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active ? _BuyerColors.blue : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active ? _BuyerColors.blue : _BuyerColors.line,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: active ? 0.08 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 16,
                    color: active ? Colors.white : _BuyerColors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: active ? Colors.white : _BuyerColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final VoidCallback onShopNow;

  const _PromoBanner({required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _BuyerColors.primary,
            _BuyerColors.primary,
            _BuyerColors.primaryDark,
          ],
          stops: [0, 0.58, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _BuyerColors.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -36,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 10,
            child: SizedBox(
              width: 92,
              height: 92,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=400&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withValues(alpha: 0.14),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 118, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get 30% off selected services',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Limited time offer for first-time buyers.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 34,
                  child: FilledButton.icon(
                    onPressed: onShopNow,
                    icon: const Icon(Icons.sell_rounded, size: 15),
                    label: const Text('Shop now'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _BuyerColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _BuyerColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$count found',
            style: const TextStyle(
              color: _BuyerColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketTile extends StatelessWidget {
  final _MarketItem item;
  final bool saved;
  final int quantity;
  final VoidCallback onWishlist;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  const _MarketTile({
    required this.item,
    required this.saved,
    required this.quantity,
    required this.onWishlist,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: _BuyerColors.line),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.08,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _ImageFallback(item: item),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: _MiniBadge(
                        text: item.type,
                        color: item.accent,
                      ),
                    ),
                    Positioned(
                      right: 7,
                      top: 7,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onWishlist,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              saved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _BuyerColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _BuyerColors.primaryDark,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          item.priceLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.stockLeft} slots left',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _BuyerColors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: _BuyerColors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${item.rating.toStringAsFixed(1)} (${item.reviews})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _BuyerColors.ink,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _BuyerColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.seller,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _BuyerColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: FilledButton(
                          onPressed: onAdd,
                          style: FilledButton.styleFrom(
                            backgroundColor: quantity > 0
                                ? _BuyerColors.success
                                : _BuyerColors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  quantity > 0
                                      ? Icons.check_rounded
                                      : Icons.add_shopping_cart_rounded,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  quantity > 0 ? 'Added $quantity' : 'Add',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final _MarketItem item;

  const _ImageFallback({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.accent.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          item.fallbackIcon,
          color: item.accent,
          size: 42,
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  final int count;
  final double total;
  final VoidCallback onView;

  const _CartBar({
    required this.count,
    required this.total,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_BuyerColors.blue, _BuyerColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _BuyerColors.blue.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: 19,
          ),
          const SizedBox(width: 8),
          const Text(
            'View your cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: _BuyerColors.blue,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'R${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Open cart',
            onPressed: onView,
            icon: const Icon(Icons.chevron_right_rounded),
            color: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _BuyerColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: _BuyerColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nothing here yet',
              style: TextStyle(
                color: _BuyerColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another category or save a listing with the heart button.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _BuyerColors.muted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
