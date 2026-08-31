// lib/features/marketplace/presentation/marketplace_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const green = Color(0xFF10B981);
}

// ── Product / Service model ───────────────────────────────────
class MarketItem {
  final String id, name, brand, category, description, seller, sellerAvatar;
  final double price, originalPrice, rating;
  final int reviews;
  final String emoji;
  final bool isNew, isSale, isService;
  final List<String> colors;
  final int views, purchases;
  final Map<String, int> demographics;
  final List<String> topLocations;

  const MarketItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.seller,
    required this.sellerAvatar,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviews,
    required this.emoji,
    this.isNew = false,
    this.isSale = false,
    this.isService = false,
    this.colors = const [],
    this.views = 0,
    this.purchases = 0,
    this.demographics = const {},
    this.topLocations = const [],
  });
}

final _items = [
  const MarketItem(
    id: 'p1',
    name: 'HP Laptop 15.6"',
    brand: 'HP',
    category: 'Electronics',
    description:
        'HP 15.6" Intel Core i5, 8GB RAM, 512GB SSD, Windows 11. Perfect for students.',
    seller: 'CompuWorld',
    sellerAvatar: '🖥️',
    price: 5200,
    originalPrice: 6500,
    rating: 4.7,
    reviews: 203,
    emoji: '💻',
    isSale: true,
    colors: ['#C0C0C0', '#1A1A1A'],
    views: 847,
    purchases: 34,
    demographics: {'18–24': 68, '25–34': 22, '35+': 10},
    topLocations: ['Johannesburg', 'Cape Town', 'Durban'],
  ),
  const MarketItem(
    id: 'p2',
    name: 'iPhone 12 Pro Max',
    brand: 'Apple',
    category: 'Electronics',
    description: 'Unlocked iPhone 12 Pro Max, 256 GB, excellent condition.',
    seller: 'iStore SA',
    sellerAvatar: '🏪',
    price: 12500,
    originalPrice: 15000,
    rating: 4.9,
    reviews: 89,
    emoji: '📱',
    isNew: true,
    colors: ['#1A1A1A', '#C0C0C0', '#FFD700'],
    views: 1203,
    purchases: 12,
    demographics: {'18–24': 45, '25–34': 40, '35+': 15},
    topLocations: ['Pretoria', 'Sandton', 'Cape Town'],
  ),
  const MarketItem(
    id: 's1',
    name: 'Maths Tutoring (1 hr)',
    brand: 'Student Service',
    category: 'Service',
    description:
        'Expert maths tutoring for grade 10–12 and university level. Algebra, calculus, statistics.',
    seller: 'Priya S.',
    sellerAvatar: '👩‍🏫',
    price: 150,
    originalPrice: 200,
    rating: 4.8,
    reviews: 56,
    emoji: '📐',
    isService: true,
    views: 320,
    purchases: 45,
    demographics: {'18–24': 80, '25–34': 15, '35+': 5},
    topLocations: ['Online', 'Johannesburg'],
  ),
  const MarketItem(
    id: 's2',
    name: 'Graphic Design Package',
    brand: 'Student Service',
    category: 'Service',
    description:
        'Logo design, social media graphics, and full branding packages. 48-hour turnaround.',
    seller: 'Yusuf A.',
    sellerAvatar: '🎨',
    price: 200,
    originalPrice: 350,
    rating: 4.6,
    reviews: 34,
    emoji: '🎨',
    isNew: true,
    isService: true,
    views: 510,
    purchases: 28,
    demographics: {'18–24': 55, '25–34': 35, '35+': 10},
    topLocations: ['Cape Town', 'Online'],
  ),
  const MarketItem(
    id: 'p3',
    name: 'Scientific Calculator',
    brand: 'Casio',
    category: 'Stationery',
    description:
        'Casio FX-991ZA PLUS — the go-to for SA university maths, engineering, and science.',
    seller: 'Campus Store',
    sellerAvatar: '📚',
    price: 245,
    originalPrice: 350,
    rating: 4.9,
    reviews: 312,
    emoji: '🧮',
    isSale: true,
    colors: ['#1A1A1A'],
    views: 650,
    purchases: 89,
    demographics: {'18–24': 75, '25–34': 20, '35+': 5},
    topLocations: ['All campuses'],
  ),
  const MarketItem(
    id: 's3',
    name: 'Photography Session',
    brand: 'Student Service',
    category: 'Service',
    description:
        'Professional photography for events, portraits, and products. Edited files delivered in 24 hrs.',
    seller: 'Nandi M.',
    sellerAvatar: '📷',
    price: 350,
    originalPrice: 500,
    rating: 4.7,
    reviews: 29,
    emoji: '📷',
    isService: true,
    views: 280,
    purchases: 18,
    demographics: {'18–24': 50, '25–34': 38, '35+': 12},
    topLocations: ['Johannesburg', 'Pretoria'],
  ),
];

// ── Simple singleton cart ────────────────────────────────────
class _Cart {
  static final _Cart _i = _Cart._();
  factory _Cart() => _i;
  _Cart._();
  final Map<String, int> items = {};
  void add(String id) => items[id] = (items[id] ?? 0) + 1;
  void remove(String id) {
    if ((items[id] ?? 0) > 1) {
      items[id] = items[id]! - 1;
    } else {
      items.remove(id);
    }
  }

  int get count => items.values.fold(0, (a, b) => a + b);
  double total(List<MarketItem> all) => items.entries.fold(0, (s, e) {
        final item =
            all.firstWhere((i) => i.id == e.key, orElse: () => all.first);
        return s + item.price * e.value;
      });
}

// ── Wishlist singleton ────────────────────────────────────────
class _Wishlist {
  static final _Wishlist _i = _Wishlist._();
  factory _Wishlist() => _i;
  _Wishlist._();
  final Set<String> _ids = {};
  bool has(String id) => _ids.contains(id);
  void toggle(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
  }

  List<String> get ids => _ids.toList();
}

// ════════════════════════════════════════════════════════════════
//  Marketplace Landing
// ════════════════════════════════════════════════════════════════
class _StudentMarketToggle extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChanged;

  const _StudentMarketToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.primary.withOpacity(0.14)),
      ),
      child: Row(children: [
        Expanded(
          child: _ModeOption(
            selected: mode == 'buy',
            icon: Icons.shopping_bag_outlined,
            label: 'Buy',
            subtitle: 'Browse student deals',
            onTap: () => onChanged('buy'),
          ),
        ),
        Expanded(
          child: _ModeOption(
            selected: mode == 'sell',
            icon: Icons.storefront_outlined,
            label: 'Sell',
            subtitle: 'Offer items or skills',
            onTap: () => onChanged('sell'),
          ),
        ),
      ]),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;

  const _ModeOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)]
              : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: selected ? _C.primary : _C.grey, size: 19),
          const SizedBox(width: 7),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? _C.primary : _C.dark)),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: _C.grey)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _CompactListingAction extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactListingAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CompactListingAction> createState() => _CompactListingActionState();
}

class _CompactListingActionState extends State<_CompactListingAction> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(13),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: _hovering ? 132 : 46,
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: widget.color.withOpacity(0.28)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(widget.icon, color: widget.color, size: 20),
              if (_hovering) ...[
                const SizedBox(width: 7),
                Expanded(
                  child: Text(widget.tooltip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: widget.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class _BuyerShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BuyerShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _C.dark)),
        ]),
      ),
    );
  }
}

class MarketplacePage extends StatefulWidget {
  final bool isBuyer;
  const MarketplacePage({super.key, this.isBuyer = false});
  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _cart = _Cart();
  String _studentMode = 'buy';
  String _filter = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  final _filters = ['All', 'Electronics', 'Service', 'Stationery', 'Furniture'];

  // ── Filtered + searched list ──────────────────────────────
  List<MarketItem> get _visible {
    var list = _filter == 'All'
        ? _items
        : _items.where((i) => i.category == _filter).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q) ||
              i.brand.toLowerCase().contains(q) ||
              i.seller.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor:
                widget.isBuyer ? const Color(0xFF1A3A8F) : _C.primary,
            elevation: 0,
            title: Text(widget.isBuyer ? 'Discover' : 'Market',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CartPage(allItems: _items)),
                    ).then((_) => _refresh()),
                  ),
                  if (_cart.count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                            color: _C.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${_cart.count}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner ─────────────────────────────────
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: widget.isBuyer
                            ? const [Color(0xFF1A3A8F), Color(0xFF2D5BE3)]
                            : const [Color(0xFFE30613), Color(0xFF7C4DFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🛒 Student Deals',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          Text(
                              widget.isBuyer
                                  ? 'Find talent. Get it done.'
                                  : 'Buy less. Earn more.',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFC857),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('40% OFF',
                              style: TextStyle(
                                  color: _C.dark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900)),
                          Text('Black Friday',
                              style: TextStyle(
                                  color: _C.dark, fontSize: 10)),
                        ],
                      ),
                    ),
                  ]),
                ),

                // ── SPLIT listing buttons ───────────────────
                if (!widget.isBuyer)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _StudentMarketToggle(
                      mode: _studentMode,
                      onChanged: (mode) => setState(() => _studentMode = mode),
                    ),
                  ),

                if (!widget.isBuyer && _studentMode == 'sell')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(children: [
                      const Text('Create a listing',
                          style: TextStyle(
                              color: _C.dark,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      _CompactListingAction(
                        tooltip: 'List a product',
                        icon: Icons.inventory_2_outlined,
                        color: _C.primary,
                        onTap: () => context.push('/marketplace/create?type=product'),
                      ),
                      const SizedBox(width: 10),
                      _CompactListingAction(
                        tooltip: 'List a service',
                        icon: Icons.design_services_outlined,
                        color: const Color(0xFF3B82F6),
                        onTap: () => context.push('/marketplace/create?type=service'),
                      ),
                    ]),
                  ),

                if (widget.isBuyer)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(children: [
                      Expanded(
                        child: _BuyerShortcut(
                          icon: Icons.favorite_outline_rounded,
                          label: 'Saved',
                          color: const Color(0xFFEF476F),
                          onTap: () => context.push('/wishlist'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _BuyerShortcut(
                          icon: Icons.receipt_long_outlined,
                          label: 'Orders',
                          color: const Color(0xFFF59E0B),
                          onTap: () => context.go('/buyer/profile'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _BuyerShortcut(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Messages',
                          color: const Color(0xFF1A3A8F),
                          onTap: () => context.go('/buyer/messages'),
                        ),
                      ),
                    ]),
                  ),

                // ── Search (functional) ─────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.primary.withOpacity(0.16)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6)
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search products & services',
                        hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: Color(0xFFAAAAAA), size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: Color(0xFFAAAAAA), size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : const Icon(Icons.tune_rounded,
                                color: Color(0xFFAAAAAA), size: 18),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                // ── Category filters ────────────────────────
                SizedBox(
                  height: 38,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: const {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filters.length,
                        itemBuilder: (_, i) {
                          final sel = _filters[i] == _filter;
                          return GestureDetector(
                            onTap: () => setState(() => _filter = _filters[i]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: sel ? _C.primary : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel ? _C.primary : _C.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(_filters[i],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: sel ? Colors.white : _C.grey)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchQuery.isNotEmpty
                            ? '${_visible.length} result${_visible.length == 1 ? '' : 's'} for "$_searchQuery"'
                            : 'Recommended',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _C.dark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Empty search state ───────────────────────
                if (_visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 40),
                    child: Center(
                      child: Column(children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No results for "$_searchQuery"',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _C.dark)),
                        const SizedBox(height: 4),
                        const Text('Try a different search term',
                            style: TextStyle(fontSize: 12, color: _C.grey)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),

          // ── Product grid ─────────────────────────────────
          if (_visible.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final item = _visible[i];
                    return _ItemCard(
                      item: item,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductDetailPage(item: item)),
                      ).then((_) => _refresh()),
                      onAddToCart: () {
                        _cart.add(item.id);
                        _refresh();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${item.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: _C.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                      },
                    );
                  },
                  childCount: _visible.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Listing bottom sheet — pre-selects Product or Service ──
  void _showListingSheet(BuildContext context, String initialType) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = initialType;
    String? pickedImageName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: _C.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text(
                type == 'Product' ? 'List a Product' : 'List a Service',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: _C.dark),
              ),
              const SizedBox(height: 4),
              Text(
                type == 'Product'
                    ? 'Sell a physical item to students & buyers'
                    : 'Offer your skills or gig to the community',
                style: const TextStyle(fontSize: 12, color: _C.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Type toggle
              Row(children: [
                _TypeBtn(
                    label: 'Product',
                    selected: type == 'Product',
                    onTap: () => setS(() => type = 'Product')),
                const SizedBox(width: 10),
                _TypeBtn(
                    label: 'Service',
                    selected: type == 'Service',
                    onTap: () => setS(() => type = 'Service')),
              ]),
              const SizedBox(height: 14),

              // Image upload (products only)
              if (type == 'Product') ...[
                GestureDetector(
                  onTap: () {
                    setS(() => pickedImageName =
                        'photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      color: pickedImageName != null
                          ? _C.primary.withOpacity(0.07)
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pickedImageName != null ? _C.primary : _C.border,
                        width: pickedImageName != null ? 1.5 : 1.0,
                      ),
                    ),
                    child: pickedImageName != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: _C.primary, size: 32),
                              const SizedBox(height: 6),
                              Text(
                                pickedImageName!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: _C.primary,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => setS(() => pickedImageName = null),
                                child: const Text('Remove',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _C.grey,
                                        decoration: TextDecoration.underline)),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: _C.grey, size: 32),
                              SizedBox(height: 6),
                              Text('Tap to upload product image',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _C.grey,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 2),
                              Text('JPG, PNG up to 5MB',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFFBBBBBB))),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Service icon picker (services only)
              if (type == 'Service') ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFF3B82F6), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Services are delivered remotely or in person. Set your rate per hour or per session.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1A3A8F),
                            height: 1.4),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              _Field(
                  ctrl: nameCtrl,
                  hint: type == 'Product'
                      ? 'Product name'
                      : 'Service title (e.g. Maths Tutoring)'),
              const SizedBox(height: 10),
              _Field(
                  ctrl: priceCtrl,
                  hint: type == 'Product'
                      ? 'Price (R)'
                      : 'Rate (R) per hour or session',
                  isNum: true),
              const SizedBox(height: 10),
              _Field(
                  ctrl: descCtrl,
                  hint: type == 'Product'
                      ? 'Describe your product'
                      : 'Describe your service & what is included',
                  maxLines: 3),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      type == 'Product' ? _C.primary : const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${type == 'Product' ? 'Product' : 'Service'} submitted for review — you\'ll be notified once live.'),
                    backgroundColor: _C.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                },
                child: Text(type == 'Product' ? 'Post Product' : 'Post Service',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Type button ───────────────────────────────────────────────
class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeBtn(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _C.primary : _C.lightGrey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? _C.primary : _C.border, width: 1.5),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: selected ? Colors.white : _C.grey)),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final bool isNum;
  const _Field(
      {required this.ctrl,
      required this.hint,
      this.maxLines = 1,
      this.isNum = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 14, color: _C.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.primary, width: 1.5)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Item Card
// ════════════════════════════════════════════════════════════════
class _ItemCard extends StatefulWidget {
  final MarketItem item;
  final VoidCallback onTap, onAddToCart;
  const _ItemCard(
      {required this.item, required this.onTap, required this.onAddToCart});

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  final _wishlist = _Wishlist();

  void _toggleWishlist(BuildContext context) {
    setState(() => _wishlist.toggle(widget.item.id));
    final isNowWishlisted = _wishlist.has(widget.item.id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isNowWishlisted ? Icons.favorite_rounded : Icons.favorite_border,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(isNowWishlisted
              ? '${widget.item.name} added to Wishlist'
              : '${widget.item.name} removed from Wishlist'),
        ]),
        backgroundColor: isNowWishlisted ? _C.primary : _C.grey,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = _wishlist.has(widget.item.id);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            Container(
              height: 105,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Center(
                child: Text(widget.item.emoji,
                    style: const TextStyle(fontSize: 50)),
              ),
            ),
            if (widget.item.isSale)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('SALE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            if (widget.item.isNew)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: _C.green, borderRadius: BorderRadius.circular(6)),
                  child: const Text('NEW',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            if (widget.item.isService)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1A3A8F),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('SERVICE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _toggleWishlist(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isWishlisted
                        ? _C.primary.withOpacity(0.12)
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isWishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border,
                      key: ValueKey(isWishlisted),
                      size: 14,
                      color: _C.primary,
                    ),
                  ),
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.dark,
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(widget.item.brand,
                    style: const TextStyle(fontSize: 10, color: _C.grey)),
                const SizedBox(height: 6),
                Row(children: [
                  Text('R${widget.item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _C.primary)),
                  const SizedBox(width: 4),
                  Text('R${widget.item.originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFAAAAAA),
                          decoration: TextDecoration.lineThrough)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 2),
                  Text(widget.item.rating.toString(),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: _C.primary,
                          borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.add_shopping_cart_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Product Detail Page
// ════════════════════════════════════════════════════════════════
class ProductDetailPage extends StatefulWidget {
  final MarketItem item;
  const ProductDetailPage({super.key, required this.item});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;
  int _selectedColor = 0;
  final _cart = _Cart();
  final _wishlist = _Wishlist();
  bool _showAnalytics = false;

  MarketItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final discount =
        ((item.originalPrice - item.price) / item.originalPrice * 100).round();
    final isOwner = item.isService;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product',
            style: TextStyle(
                color: _C.dark, fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
        actions: [
          if (isOwner)
            TextButton(
              onPressed: () => setState(() => _showAnalytics = !_showAnalytics),
              child: Text(_showAnalytics ? 'Hide Stats' : 'My Stats',
                  style: const TextStyle(
                      color: _C.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: _C.dark),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CartPage(allItems: _items))),
            ),
            if (_cart.count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: _C.primary, shape: BoxShape.circle),
                  child: Center(
                    child: Text('${_cart.count}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ]),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 240,
                  color: const Color(0xFFF5F5F5),
                  child: Stack(children: [
                    Center(
                        child: Text(item.emoji,
                            style: const TextStyle(fontSize: 90))),
                    if (discount > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _C.primary,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('-$discount%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _C.dark)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('R${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: _C.primary)),
                        const SizedBox(width: 8),
                        Text('R${item.originalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFAAAAAA),
                                decoration: TextDecoration.lineThrough)),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        ...List.generate(
                            5,
                            (i) => Icon(
                                i < item.rating.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 16,
                                color: const Color(0xFFF59E0B))),
                        const SizedBox(width: 6),
                        Text('${item.rating} (${item.reviews} reviews)',
                            style:
                                const TextStyle(fontSize: 12, color: _C.grey)),
                      ]),
                      const SizedBox(height: 14),
                      if (isOwner && _showAnalytics) ...[
                        _AnalyticsPanel(item: item),
                        const SizedBox(height: 14),
                      ],
                      if (item.colors.isNotEmpty) ...[
                        const Text('Color',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _C.dark)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(item.colors.length, (i) {
                            final c = Color(int.parse(
                                item.colors[i].replaceAll('#', '0xFF')));
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = i),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == i
                                        ? _C.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),
                      ],
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.dark)),
                      const SizedBox(height: 6),
                      Text(item.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF555555),
                              height: 1.5)),
                      const SizedBox(height: 14),
                      const Text('Seller',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.dark)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _C.border),
                        ),
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: Center(
                              child: Text(item.sellerAvatar,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.seller,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    item.isService
                                        ? 'Student provider'
                                        : 'Product seller',
                                    style: const TextStyle(
                                        fontSize: 11, color: _C.grey)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openSellerChat(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: _C.primary,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.phone_outlined,
                                  color: _C.primary, size: 18),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _C.border))),
          child: Row(children: [
            GestureDetector(
              onTap: () {
                setState(() => _wishlist.toggle(item.id));
                final saved = _wishlist.has(item.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(saved
                      ? '${item.name} saved to Wishlist'
                      : '${item.name} removed from Wishlist'),
                  backgroundColor: saved ? _C.primary : _C.grey,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _wishlist.has(item.id)
                      ? _C.primary.withOpacity(0.10)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _wishlist.has(item.id)
                        ? _C.primary.withOpacity(0.4)
                        : _C.border,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    _wishlist.has(item.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(_wishlist.has(item.id)),
                    color: _C.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: _C.border),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                IconButton(
                  onPressed: () => setState(() {
                    if (_qty > 1) _qty--;
                  }),
                  icon: const Icon(Icons.remove, size: 16),
                ),
                Text('$_qty',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: () => setState(() => _qty++),
                  icon: const Icon(Icons.add, size: 16),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: item.isService
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openSellerChat(context),
                      child: const Text('Hire — Message Seller',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        for (var i = 0; i < _qty; i++) {
                          _cart.add(item.id);
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CartPage(allItems: _items)));
                      },
                      child: Text('Checkout ($_qty)',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _openSellerChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DirectChatPage(
          sellerName: item.seller,
          sellerAvatar: item.sellerAvatar,
          itemContext: item.name,
        ),
      ),
    );
  }
}

// ── Analytics panel ───────────────────────────────────────────
class _AnalyticsPanel extends StatelessWidget {
  final MarketItem item;
  const _AnalyticsPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A3A8F).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.bar_chart_rounded, color: Color(0xFF1A3A8F), size: 18),
            SizedBox(width: 6),
            Text('My Listing Analytics',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A3A8F))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _AStatBox(
                label: 'Views',
                value: '${item.views}',
                icon: Icons.visibility_outlined),
            const SizedBox(width: 8),
            _AStatBox(
                label: 'Purchases',
                value: '${item.purchases}',
                icon: Icons.shopping_bag_outlined),
            const SizedBox(width: 8),
            _AStatBox(
              label: 'Conv. Rate',
              value:
                  '${(item.purchases / item.views * 100).toStringAsFixed(1)}%',
              icon: Icons.trending_up_rounded,
            ),
          ]),
          const SizedBox(height: 10),
          const Text('Demographics',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: _C.dark)),
          const SizedBox(height: 6),
          ...item.demographics.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(
                      width: 46,
                      child: Text(e.key,
                          style:
                              const TextStyle(fontSize: 11, color: _C.grey))),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: e.value / 100,
                        minHeight: 6,
                        backgroundColor: _C.border,
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF1A3A8F)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${e.value}%',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.dark)),
                ]),
              )),
          const SizedBox(height: 6),
          const Text('Top Locations',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: _C.dark)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.topLocations
                .map((loc) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A8F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(loc,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1A3A8F),
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AStatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _AStatBox(
      {required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1A3A8F).withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: const Color(0xFF1A3A8F)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _C.dark)),
          Text(label, style: const TextStyle(fontSize: 10, color: _C.grey)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Direct Chat Page
// ════════════════════════════════════════════════════════════════
class _DirectChatPage extends StatefulWidget {
  final String sellerName, sellerAvatar, itemContext;
  const _DirectChatPage({
    required this.sellerName,
    required this.sellerAvatar,
    required this.itemContext,
  });
  @override
  State<_DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<_DirectChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _msgs.addAll([
      {
        'from': 'seller',
        'text': 'Hi! Thanks for your interest in my listing. How can I help?',
        'time': _now()
      },
    ]);
  }

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add({'from': 'me', 'text': text, 'time': _now()});
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      const replies = [
        'Sure, I can help with that!',
        'That works for me, let\'s schedule it.',
        'Thanks! Let me know your preferred time.',
        'Absolutely — I\'m available this week.',
      ];
      setState(() {
        _msgs.add({
          'from': 'seller',
          'text': replies[DateTime.now().millisecond % replies.length],
          'time': _now(),
        });
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _C.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _C.primary.withOpacity(0.1),
            child:
                Text(widget.sellerAvatar, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.sellerName,
                style: const TextStyle(
                    color: _C.dark, fontWeight: FontWeight.w700, fontSize: 14)),
            const Text('Online',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.call_outlined, color: _C.primary),
              onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: _C.primary.withOpacity(0.06),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: _C.primary, size: 14),
            const SizedBox(width: 6),
            Text('Re: ${widget.itemContext}',
                style: const TextStyle(
                    color: _C.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length,
            itemBuilder: (_, i) {
              final m = _msgs[i];
              final me = m['from'] == 'me';
              return Align(
                alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.68),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: me ? _C.primary : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(me ? 16 : 4),
                      bottomRight: Radius.circular(me ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(m['text'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              color: me ? Colors.white : _C.dark,
                              height: 1.4)),
                      const SizedBox(height: 3),
                      Text(m['time'] as String,
                          style: TextStyle(
                              fontSize: 10,
                              color: me ? Colors.white70 : _C.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _C.border))),
          child: Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _C.border)),
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _send(),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle:
                        TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: _C.primary, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Cart Page
// ════════════════════════════════════════════════════════════════
class CartPage extends StatefulWidget {
  final List<MarketItem> allItems;
  const CartPage({super.key, required this.allItems});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  final _cart = _Cart();
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<MapEntry<MarketItem, int>> get _entries => _cart.items.entries.map((e) {
        final item = widget.allItems.firstWhere((i) => i.id == e.key,
            orElse: () => widget.allItems.first);
        return MapEntry(item, e.value);
      }).toList();

  @override
  Widget build(BuildContext context) {
    final total = _cart.total(widget.allItems);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Cart',
            style: TextStyle(
                color: _C.dark, fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Apply Promo',
                style: TextStyle(
                    color: _C.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: _C.primary,
          unselectedLabelColor: _C.grey,
          indicatorColor: _C.primary,
          tabs: const [Tab(text: 'My Cart'), Tab(text: 'Wishlist')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _entries.isEmpty
              ? const Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🛒', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('Your cart is empty',
                        style: TextStyle(color: _C.grey, fontSize: 16)),
                  ],
                ))
              : Column(children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _entries.length,
                      itemBuilder: (_, i) {
                        final item = _entries[i].key;
                        final qty = _entries[i].value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(14)),
                              ),
                              child: Center(
                                  child: Text(item.emoji,
                                      style: const TextStyle(fontSize: 36))),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text('R${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: _C.primary)),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      _QtyBtn(
                                        icon: Icons.remove,
                                        onTap: () {
                                          _cart.remove(item.id);
                                          setState(() {});
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text('$qty',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700)),
                                      ),
                                      _QtyBtn(
                                        icon: Icons.add,
                                        onTap: () {
                                          _cart.add(item.id);
                                          setState(() {});
                                        },
                                        filled: true,
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Color(0xFFCCCCCC), size: 20),
                              onPressed: () {
                                _cart.items.remove(item.id);
                                setState(() {});
                              },
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(children: [
                      _Row('Subtotal', 'R${total.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      _Row('Shipping', 'R0.00'),
                      const Divider(height: 16),
                      _Row('Total', 'R${total.toStringAsFixed(2)}', bold: true),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CheckoutPage(total: total)),
                          ),
                          child: const Text('Proceed to Checkout',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ),
                ]),
          _WishlistTab(allItems: widget.allItems),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Wishlist Tab
// ════════════════════════════════════════════════════════════════
class _WishlistTab extends StatefulWidget {
  final List<MarketItem> allItems;
  const _WishlistTab({required this.allItems});

  @override
  State<_WishlistTab> createState() => _WishlistTabState();
}

class _WishlistTabState extends State<_WishlistTab> {
  final _wishlist = _Wishlist();
  final _cart = _Cart();

  List<MarketItem> get _wishlisted =>
      widget.allItems.where((item) => _wishlist.has(item.id)).toList();

  @override
  Widget build(BuildContext context) {
    final items = _wishlisted;
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 52, color: _C.grey),
            SizedBox(height: 14),
            Text('No saved items yet',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: _C.grey)),
            SizedBox(height: 6),
            Text('Tap the ♡ on any product to save it here',
                style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
            ],
          ),
          child: Row(children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _C.dark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(item.brand,
                        style: const TextStyle(fontSize: 10, color: _C.grey)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text('R${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _C.primary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          _cart.add(item.id);
                          setState(() => _wishlist.toggle(item.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} moved to cart'),
                              backgroundColor: _C.green,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _C.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Add to Cart',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_rounded,
                  color: _C.primary, size: 20),
              onPressed: () => setState(() => _wishlist.toggle(item.id)),
            ),
          ]),
        );
      },
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyBtn({required this.icon, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: filled ? _C.primary : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: filled ? _C.primary : _C.border),
        ),
        child: Icon(icon, size: 14, color: filled ? Colors.white : _C.dark),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String l, r;
  final bool bold;
  const _Row(this.l, this.r, {this.bold = false});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l,
            style: TextStyle(
                fontSize: 13,
                color: bold ? _C.dark : _C.grey,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(r,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? _C.primary : _C.dark)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Checkout Page
// ════════════════════════════════════════════════════════════════
class CheckoutPage extends StatefulWidget {
  final double total;
  const CheckoutPage({super.key, required this.total});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _step = 0;
  String? _selectedMethod;

  final _cardNum = TextEditingController();
  final _cardName = TextEditingController();
  final _cardExp = TextEditingController();
  final _cardCvv = TextEditingController();
  final _bankName = TextEditingController();
  final _accNum = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _cardNum,
      _cardName,
      _cardExp,
      _cardCvv,
      _bankName,
      _accNum,
      _fullName,
      _phone,
      _address,
      _city,
      _postal
    ]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Checkout',
            style: TextStyle(
                color: _C.dark, fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 3; i++) ...[
                _StepChip(
                    label: ['Payment', 'Shipping', 'Review'][i],
                    icon: [
                      Icons.payment_outlined,
                      Icons.local_shipping_outlined,
                      Icons.rate_review_outlined
                    ][i],
                    isActive: i == _step,
                    isDone: i < _step),
                if (i < 2)
                  Container(
                      width: 28,
                      height: 1,
                      color: i < _step ? _C.primary : _C.border),
              ],
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _step == 0
                ? _paymentForm()
                : _step == 1
                    ? _shippingForm()
                    : _reviewStep(),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          color: Colors.white,
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _C.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _step--),
                  child: const Text('Back',
                      style: TextStyle(color: Color(0xFF555555))),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_step < 2) {
                    setState(() => _step++);
                  } else {
                    _Cart().items.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const _OrderSuccessPage()),
                      (r) => r.isFirst,
                    );
                  }
                },
                child: Text(
                  _step == 2 ? 'Place Order' : 'Continue',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _shippingForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Details',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _C.dark)),
          const SizedBox(height: 14),
          _CheckoutField(
              ctrl: _fullName, hint: 'Full name', label: 'Full Name'),
          const SizedBox(height: 10),
          _CheckoutField(
              ctrl: _phone, hint: '07X XXX XXXX', label: 'Phone', isNum: true),
          const SizedBox(height: 10),
          _CheckoutField(
              ctrl: _address,
              hint: '12 Street, Suburb',
              label: 'Street Address'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child:
                    _CheckoutField(ctrl: _city, hint: 'City', label: 'City')),
            const SizedBox(width: 10),
            Expanded(
                child: _CheckoutField(
                    ctrl: _postal,
                    hint: '2001',
                    label: 'Postal Code',
                    isNum: true)),
          ]),
        ],
      );

  Widget _paymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: _C.dark)),
        const SizedBox(height: 14),
        _PayMethod(
          selected: _selectedMethod == 'wallet',
          icon: Icons.account_balance_wallet_outlined,
          label: 'Gude Wallet',
          badge: 'R190.00 available',
          onTap: () => setState(() =>
              _selectedMethod = _selectedMethod == 'wallet' ? null : 'wallet'),
          child: _selectedMethod == 'wallet'
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _C.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.border)),
                  child: const Row(children: [
                    Icon(Icons.check_circle_rounded, color: _C.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'R190.00 will be deducted from your Saving Pocket.',
                          style: TextStyle(fontSize: 12, color: _C.dark)),
                    ),
                  ]),
                )
              : null,
        ),
        const SizedBox(height: 10),
        _PayMethod(
          selected: _selectedMethod == 'card',
          icon: Icons.credit_card_outlined,
          label: 'Credit / Debit Card',
          onTap: () => setState(() =>
              _selectedMethod = _selectedMethod == 'card' ? null : 'card'),
          child: _selectedMethod == 'card'
              ? Column(children: [
                  const SizedBox(height: 12),
                  _CheckoutField(
                      ctrl: _cardNum,
                      hint: '1234 5678 9012 3456',
                      label: 'Card Number',
                      isNum: true),
                  const SizedBox(height: 8),
                  _CheckoutField(
                      ctrl: _cardName,
                      hint: 'As on card',
                      label: 'Cardholder Name'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _CheckoutField(
                            ctrl: _cardExp, hint: 'MM / YY', label: 'Expiry')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _CheckoutField(
                            ctrl: _cardCvv,
                            hint: '•••',
                            label: 'CVV',
                            obscure: true,
                            isNum: true)),
                  ]),
                ])
              : null,
        ),
        const SizedBox(height: 10),
        _PayMethod(
          selected: _selectedMethod == 'eft',
          icon: Icons.swap_horiz_rounded,
          label: 'EFT / Instant Pay',
          onTap: () => setState(
              () => _selectedMethod = _selectedMethod == 'eft' ? null : 'eft'),
          child: _selectedMethod == 'eft'
              ? Column(children: [
                  const SizedBox(height: 12),
                  _CheckoutField(
                      ctrl: _bankName,
                      hint: 'e.g. FNB, Capitec, ABSA',
                      label: 'Bank Name'),
                  const SizedBox(height: 8),
                  _CheckoutField(
                      ctrl: _accNum,
                      hint: 'Account number',
                      label: 'Account Number',
                      isNum: true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.5))),
                    child: const Text(
                      'Reference: GUDE-PAY-XXXX will be shown after placing your order.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                    ),
                  ),
                ])
              : null,
        ),
      ],
    );
  }

  Widget _reviewStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _C.dark)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _Row('Subtotal', 'R${widget.total.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _Row('Shipping', 'R0.00'),
              const Divider(height: 16),
              _Row('Total', 'R${widget.total.toStringAsFixed(2)}', bold: true),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.payment_outlined, color: _C.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                _selectedMethod == 'wallet'
                    ? 'Gude Wallet'
                    : _selectedMethod == 'card'
                        ? 'Credit / Debit Card'
                        : _selectedMethod == 'eft'
                            ? 'EFT / Instant Pay'
                            : 'No payment method selected',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _C.dark),
              ),
            ]),
          ),
        ],
      );
}

class _PayMethod extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  final Widget? child;
  const _PayMethod({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _C.primary : _C.border,
          width: selected ? 1.8 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Icon(icon, color: selected ? _C.primary : _C.grey, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: selected ? _C.primary : _C.dark)),
                      if (badge != null)
                        Text(badge!,
                            style:
                                const TextStyle(fontSize: 11, color: _C.grey)),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: selected ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: _C.grey, size: 20),
                ),
                const SizedBox(width: 4),
                if (selected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _C.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('Selected',
                        style: TextStyle(
                            color: _C.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
              ]),
            ),
          ),
          if (child != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint, label;
  final bool isNum, obscure;
  const _CheckoutField({
    required this.ctrl,
    required this.hint,
    required this.label,
    this.isNum = false,
    this.obscure = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: _C.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14, color: _C.dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.primary, width: 1.5)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ]);
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive, isDone;
  const _StepChip(
      {required this.label,
      required this.icon,
      required this.isActive,
      required this.isDone});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDone || isActive ? _C.primary : _C.border,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Icon(icon, size: 14, color: isActive ? Colors.white : _C.grey),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              fontSize: 9,
              color: isActive || isDone ? _C.primary : _C.grey,
              fontWeight: FontWeight.w600)),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════
//  Order Success Page
// ════════════════════════════════════════════════════════════════
class _OrderSuccessPage extends StatelessWidget {
  const _OrderSuccessPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                    color: Color(0xFFF0FFF4), shape: BoxShape.circle),
                child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 52))),
              ),
              const SizedBox(height: 24),
              const Text('Order placed successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _C.dark)),
              const SizedBox(height: 12),
              const Text(
                'Thank you for shopping at Gude! Happy shopping!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _C.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Continue Shopping',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
