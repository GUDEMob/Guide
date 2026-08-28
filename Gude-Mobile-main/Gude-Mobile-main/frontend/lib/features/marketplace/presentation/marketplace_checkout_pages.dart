import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFFE30613);
}

// ─────────────────────────────────────────────
// PRODUCT DATA MODELS
// ─────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviews;
  final String emoji;
  final String category;
  final String description;
  final bool isNew;
  final List<String> colors;
  final String seller;
  final String sellerAvatar;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviews,
    required this.emoji,
    required this.category,
    required this.description,
    this.isNew = false,
    this.colors = const [],
    required this.seller,
    required this.sellerAvatar,
  });
}

final products = [
  const Product(
    id: 'p1',
    name: 'Air Jordan 6 Retro',
    brand: 'Nike',
    price: 1025,
    originalPrice: 1800,
    rating: 4.8,
    reviews: 124,
    emoji: '👟',
    category: 'Footwear',
    description: "Mi's sixth signature shoe debuted during the 1990-1991 season as his Airness forded rivals in pursuit of sk elusive... The Jordan 6 features a rubber outsole with herringbone traction, Air-Sole unit for cushioning, and leather/synthetic upper for durability.",
    isNew: false,
    colors: ['#FFFFFF', '#1A1A1A', '#E30613'],
    seller: 'Precious Mhd',
    sellerAvatar: '👤',
  ),
  const Product(
    id: 'p2',
    name: 'Loop Silicone Strong Magnetic Watch',
    brand: 'SmartTech',
    price: 419.25,
    originalPrice: 599,
    rating: 4.6,
    reviews: 87,
    emoji: '⌚',
    category: 'Electronics',
    description: 'Premium silicone magnetic smart watch with health tracking, GPS, 7-day battery life and water resistance up to 50m.',
    isNew: true,
    colors: ['#1A1A1A', '#E30613', '#3B5BD5'],
    seller: 'TechHub SA',
    sellerAvatar: '🏪',
  ),
  const Product(
    id: 'p3',
    name: 'M6 Smart watch IP67 Waterproof',
    brand: 'SmartBand',
    price: 89,
    originalPrice: 150,
    rating: 4.3,
    reviews: 56,
    emoji: '⌚',
    category: 'Electronics',
    description: 'Affordable IP67 waterproof smart band with heart rate monitor, step counter, sleep tracker and notification alerts.',
    isNew: false,
    colors: ['#1A1A1A', '#888888'],
    seller: 'GadgetZone',
    sellerAvatar: '🏬',
  ),
  const Product(
    id: 'p4',
    name: 'HP Laptop 15.6"',
    brand: 'HP',
    price: 2500,
    originalPrice: 3200,
    rating: 4.7,
    reviews: 203,
    emoji: '💻',
    category: 'Electronics',
    description: 'HP 15.6" Intel Core i5 laptop with 8GB RAM, 512GB SSD, Windows 11. Perfect for students.',
    isNew: false,
    colors: ['#C0C0C0', '#1A1A1A'],
    seller: 'CompuWorld',
    sellerAvatar: '🖥️',
  ),
  const Product(
    id: 'p5',
    name: 'Melltop Desk',
    brand: 'FurniCo',
    price: 890,
    originalPrice: 1200,
    rating: 4.4,
    reviews: 45,
    emoji: '🪑',
    category: 'Furniture',
    description: 'Modern study desk with cable management, drawer, and adjustable shelves. Fits all student dorm rooms.',
    isNew: true,
    colors: ['#8B6914', '#1A1A1A', '#FFFFFF'],
    seller: 'DormDeals',
    sellerAvatar: '🏠',
  ),
  const Product(
    id: 'p6',
    name: 'Scientific Calculator',
    brand: 'Casio',
    price: 245,
    originalPrice: 350,
    rating: 4.9,
    reviews: 312,
    emoji: '🧮',
    category: 'Stationery',
    description: 'Casio FX-991ZA PLUS scientific calculator — the go-to for SA university maths, engineering, and science courses.',
    isNew: false,
    colors: ['#1A1A1A'],
    seller: 'Campus Store',
    sellerAvatar: '📚',
  ),
];

// ─────────────────────────────────────────────
// CART MODEL (simple global state)
// ─────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartState {
  static final CartState _instance = CartState._();
  factory CartState() => _instance;
  CartState._();

  final List<CartItem> items = [];

  void add(Product product) {
    final existing = items.where((e) => e.product.id == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      items.add(CartItem(product: product));
    }
  }

  void remove(String productId) {
    items.removeWhere((e) => e.product.id == productId);
  }

  void updateQuantity(String productId, int qty) {
    final item = items.where((e) => e.product.id == productId).firstOrNull;
    if (item != null) {
      if (qty <= 0) {
        items.remove(item);
      } else {
        item.quantity = qty;
      }
    }
  }

  double get subtotal => items.fold(0, (sum, e) => sum + (e.product.price * e.quantity));
  double get shippingCost => items.isEmpty ? 0 : 0;
  double get total => subtotal + shippingCost;
  int get itemCount => items.fold(0, (sum, e) => sum + e.quantity);
}

// ─────────────────────────────────────────────
// MARKETPLACE LANDING PAGE
// ─────────────────────────────────────────────
class MarketplaceLandingPage extends StatefulWidget {
  const MarketplaceLandingPage({super.key});

  @override
  State<MarketplaceLandingPage> createState() => _MarketplaceLandingPageState();
}

class _MarketplaceLandingPageState extends State<MarketplaceLandingPage> {
  final _cart = CartState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text('Shop', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w800, fontSize: 20)),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())).then((_) => setState(() {})),
                  ),
                  if (_cart.itemCount > 0)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Text('${_cart.itemCount}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
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
                // Black Friday Banner
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF3A1A1A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(right: 16, top: 0, bottom: 0, child: Center(child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('40% OFF', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                            Text('Black Friday', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ))),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🛒 Student Deals', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            Text('Shop. Save.\nThrive.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick nav
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ShopNavTile(emoji: '⚡', label: 'Transact', onTap: () {}),
                      _ShopNavTile(emoji: '💳', label: 'Transact', onTap: () {}),
                      _ShopNavTile(emoji: '🛒', label: 'Buy', onTap: () {}),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products & services',
                        hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Color(0xFFAAAAAA), size: 18),
                        suffixIcon: Icon(Icons.tune_rounded, color: Color(0xFFAAAAAA), size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Recommended header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recommended', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                      Row(children: [
                        Text('Filter V', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),

          // Products grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ProductCard(
                  product: products[i],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: products[i]))).then((_) => setState(() {})),
                  onAddToCart: () {
                    _cart.add(products[i]);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${products[i].name} added to cart'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.primary,
                    ));
                  },
                ),
                childCount: products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          ),

          // Popular Tutors section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Text('Popular Tutors', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                ),
                SizedBox(
                  height: 72,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final t in [
                        {'name': 'John D', 'from': 'Carltonville', 'to': 'Johannesburg', 'time': 'now 1 min'},
                        {'name': 'John D', 'from': 'Carltonville', 'to': 'Johannesburg', 'time': 'now 1 min'},
                      ])
                        Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Center(child: Text('J', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(t['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    Text('${t['from']} → ${t['to']}', style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
                                    Text(t['time']!, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT CARD
// ─────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  const _ProductCard({required this.product, required this.onTap, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final discount = ((product.originalPrice - product.price) / product.originalPrice * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 50))),
                ),
                if (product.isNew)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                      child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border, size: 14, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A), height: 1.2),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(product.brand, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('R${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      const SizedBox(width: 4),
                      Text('R${product.originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA), decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.star_rounded, size: 11, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(product.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ]),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add_shopping_cart_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT DETAIL PAGE
// ─────────────────────────────────────────────
class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedColor = 0;
  int _qty = 1;
  final _cart = CartState();

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final discount = ((p.originalPrice - p.price) / p.originalPrice * 100).round();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1A1A1A)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
              ),
              if (_cart.itemCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Text('${_cart.itemCount}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image
                  Container(
                    height: 260,
                    color: const Color(0xFFF5F5F5),
                    child: Stack(
                      children: [
                        Center(child: Text(p.emoji, style: const TextStyle(fontSize: 100))),
                        Positioned(
                          top: 12, right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.favorite_border, size: 20, color: AppColors.primary),
                          ),
                        ),
                        if (discount > 0)
                          Positioned(
                            top: 12, left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                              child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                                  Text(p.brand, style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
                                ],
                              ),
                            ),
                            // Share
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF555555)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Price
                        Row(
                          children: [
                            Text('R${p.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                            const SizedBox(width: 8),
                            Text('R${p.originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA), decoration: TextDecoration.lineThrough)),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Rating
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < p.rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 16, color: const Color(0xFFF59E0B),
                            )),
                            const SizedBox(width: 6),
                            Text('${p.rating} (${p.reviews} reviews)', style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Colors
                        if (p.colors.isNotEmpty) ...[
                          const Text('Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(p.colors.length, (i) {
                              final color = Color(int.parse(p.colors[i].replaceAll('#', '0xFF')));
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = i),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedColor == i ? AppColors.primary : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Description
                        const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 6),
                        Text(p.description, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5)),

                        const SizedBox(height: 16),

                        // Seller
                        const Text('Seller', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: Center(child: Text(p.sellerAvatar, style: const TextStyle(fontSize: 18))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.seller, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    const Text('Product Owner', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                                  ],
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary), onPressed: () {}),
                              IconButton(icon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary), onPressed: () {}),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Verify product
                        const Text('Verify this Product', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 6),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter number here...',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                // Qty
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => setState(() { if (_qty > 1) _qty--; }), icon: const Icon(Icons.remove, size: 16)),
                      Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(onPressed: () => setState(() => _qty++), icon: const Icon(Icons.add, size: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      for (int i = 0; i < _qty; i++) { _cart.add(p); }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                    },
                    child: Text('Checkout($_qty)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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

// ─────────────────────────────────────────────
// CART PAGE
// ─────────────────────────────────────────────
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  final _cart = CartState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Cart', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Apply Promo Code', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF888888),
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'My Cart'), Tab(text: 'Wishlist')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // Cart
          _cart.items.isEmpty
              ? const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🛒', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('Your cart is empty', style: TextStyle(color: Color(0xFF999999), fontSize: 16)),
                  ],
                ))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cart.items.length,
                        itemBuilder: (_, i) {
                          final item = _cart.items[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              children: [
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                                  ),
                                  child: Center(child: Text(item.product.emoji, style: const TextStyle(fontSize: 36))),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                          maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text('R${item.product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => setState(() => _cart.updateQuantity(item.product.id, item.quantity - 1)),
                                              child: Container(
                                                width: 24, height: 24,
                                                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(6)),
                                                child: const Icon(Icons.remove, size: 14),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                            ),
                                            GestureDetector(
                                              onTap: () => setState(() => _cart.updateQuantity(item.product.id, item.quantity + 1)),
                                              child: Container(
                                                width: 24, height: 24,
                                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                                                child: const Icon(Icons.add, size: 14, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFCCCCCC), size: 20),
                                  onPressed: () => setState(() => _cart.remove(item.product.id)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Order summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        children: [
                          _OrderRow('Subtotal', 'R${_cart.subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          _OrderRow('Shipping Cost', _cart.shippingCost == 0 ? 'R0.00' : 'R${_cart.shippingCost.toStringAsFixed(2)}'),
                          const Divider(height: 16),
                          _OrderRow('Total', 'R${_cart.total.toStringAsFixed(2)}', bold: true),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPaymentPage())),
                              child: const Text('Proceed to Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          // Wishlist tab
          const Center(child: Text('Wishlist coming soon', style: TextStyle(color: Color(0xFF999999)))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHECKOUT — PAYMENT PAGE
// ─────────────────────────────────────────────
class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({super.key});

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  final _cart = CartState();
  int _step = 0; // 0=Payment 1=Address 2=Review
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  _StepChip(
                    label: ['Payment', 'Address', 'Review'][i],
                    isActive: i == _step,
                    isDone: i < _step,
                  ),
                  if (i < 2) Container(width: 24, height: 1, color: const Color(0xFFEEEEEE)),
                ],
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _step == 0
                  ? _PaymentForm(
                      selectedMethod: _selectedPaymentMethod,
                      onSelect: (m) => setState(() => _selectedPaymentMethod = m),
                    )
                  : _step == 1
                      ? _ShippingForm()
                      : _ReviewStep(cart: _cart),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFEEEEEE)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back', style: TextStyle(color: Color(0xFF555555))),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_step == 0 && _selectedPaymentMethod == null)
                          ? const Color(0xFFCCCCCC)
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (_step == 0 && _selectedPaymentMethod == null)
                        ? null
                        : () {
                            if (_step < 2) {
                              setState(() => _step++);
                            } else {
                              // Place order
                              CartState().items.clear();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
                                (route) => false,
                              );
                            }
                          },
                    child: Text(
                      _step == 2 ? 'Place Order' : 'Continue',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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

// ─────────────────────────────────────────────
// CHECKOUT STEPS
// ─────────────────────────────────────────────
class _ShippingForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fullname', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
        const SizedBox(height: 6),
        _Field(hint: 'Enter fullname'),
        const SizedBox(height: 12),
        const Text('Phone number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
        const SizedBox(height: 6),
        _Field(hint: 'Enter phone number'),
        const SizedBox(height: 16),
        const Text('Shipping Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Province', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              const SizedBox(height: 4),
              _Field(hint: 'Select province'),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Left Area', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              const SizedBox(height: 4),
              _Field(hint: 'Select province'),
            ])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('City', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              const SizedBox(height: 4),
              _Field(hint: 'Select City'),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Johannesburg', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              const SizedBox(height: 4),
              _Field(hint: 'Johannesburg'),
            ])),
          ],
        ),
        const SizedBox(height: 10),
        const Text('Email Address', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
        const SizedBox(height: 4),
        _Field(hint: '12/Street name/Johannesburg'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Postal Code', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              const SizedBox(height: 4),
              _Field(hint: '2001'),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Province', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              const SizedBox(height: 4),
              _Field(hint: 'Enter street address'),
            ])),
          ],
        ),
      ],
    );
  }
}

class _PaymentForm extends StatelessWidget {
  final String? selectedMethod;
  final ValueChanged<String> onSelect;
  const _PaymentForm({required this.selectedMethod, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 4),
        const Text('Please select a payment method to continue', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
        const SizedBox(height: 12),
        for (final method in ['Gude Wallet', 'Credit/Debit Card', 'EFT / Instant Pay'])
          GestureDetector(
            onTap: () => onSelect(method),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedMethod == method ? AppColors.primary : const Color(0xFFEEEEEE),
                  width: selectedMethod == method ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method == 'Gude Wallet' ? Icons.account_balance_wallet_outlined
                        : method.contains('Card') ? Icons.credit_card_outlined
                        : Icons.swap_horiz_rounded,
                    color: selectedMethod == method ? AppColors.primary : const Color(0xFF888888),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(method, style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: selectedMethod == method ? AppColors.primary : const Color(0xFF1A1A1A),
                  )),
                  const Spacer(),
                  if (selectedMethod == method)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: const Text('Selected', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final CartState cart;
  const _ReviewStep({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 12),
        ...cart.items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(item.product.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('x${item.quantity}', style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  ],
                ),
              ),
              Text('R${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}),
            ],
          ),
        )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _OrderRow('Subtotal', 'R${cart.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _OrderRow('Shipping Cost', 'R0.00'),
              const Divider(height: 16),
              _OrderRow('Total', 'R${cart.total.toStringAsFixed(2)}', bold: true),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ORDER SUCCESS PAGE
// ─────────────────────────────────────────────
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A), size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Checkout', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 16)),
                centerTitle: true,
              ),

              // Step indicator (all done)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    _StepChip(
                      label: ['Payment', 'Address', 'Review'][i],
                      isActive: false,
                      isDone: true,
                    ),
                    if (i < 2) Container(width: 24, height: 1, color: AppColors.primary),
                  ],
                ],
              ),

              const SizedBox(height: 40),

              // Success animation
              Container(
                width: 120, height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FFF4),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🎉', style: TextStyle(fontSize: 56))),
              ),

              const SizedBox(height: 24),

              const Text(
                'Your order has been\nplaced successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A), height: 1.3),
              ),

              const SizedBox(height: 12),

              const Text(
                'Thank you for shopping at Gude! Feel free to continue shopping and explore our wide range of products. Happy Shopping!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.5),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Continue Shopping', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back', style: TextStyle(color: Color(0xFF888888))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _OrderRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF888888))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: bold ? AppColors.primary : const Color(0xFF1A1A1A))),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String hint;
  const _Field({required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;
  const _StepChip({required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isDone || isActive ? AppColors.primary : const Color(0xFFEEEEEE),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Icon(
                    label == 'Address' ? Icons.location_on_outlined
                        : label == 'Payment' ? Icons.payment_outlined
                        : Icons.rate_review_outlined,
                    size: 14,
                    color: isActive ? Colors.white : const Color(0xFF888888),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 9, color: isActive || isDone ? AppColors.primary : const Color(0xFF888888), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ShopNavTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _ShopNavTile({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}