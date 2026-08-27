import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _showVoucher = false;
  final _voucherController = TextEditingController();
  int _selectedTab = 0;
  final List<Map<String, dynamic>> _cartItems = [
    {'name': 'Loop Silicone Strong Magnetic Watch', 'price': 15.25, 'oldPrice': 30.00, 'qty': 1},
    {'name': 'Loop Silicone Strong Magnetic Watch', 'price': 15.26, 'oldPrice': 100.00,'qty': 1},
  ];

  double get _subtotal => _cartItems.fold(0, (s, i) => s + i['price'] * i['qty']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: TextButton.icon(
          onPressed: () => context.go('/marketplace'),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 18),
          label: const Text('My Cart', style: TextStyle(color: AppColors.textDark)),
        ),
        actions: [
          TextButton(onPressed: () => setState(() => _showVoucher = true),
            child: const Text('Voucher Code', style: TextStyle(color: AppColors.primary))),
        ],
      ),
      body: Column(children: [
        // Tab
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: _selectedTab == 0 ? AppColors.primary : Colors.transparent, width: 2))),
              child: Text('My Cart', textAlign: TextAlign.center,
                style: TextStyle(color: _selectedTab == 0 ? AppColors.primary : AppColors.textGrey,
                  fontWeight: FontWeight.w600)),
            ),
          )),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: _selectedTab == 1 ? AppColors.primary : Colors.transparent, width: 2))),
              child: Text('Wishlist', textAlign: TextAlign.center,
                style: TextStyle(color: _selectedTab == 1 ? AppColors.primary : AppColors.textGrey,
                  fontWeight: FontWeight.w600)),
            ),
          )),
        ]),
        Expanded(
          child: _selectedTab == 0
            ? _cartItems.isEmpty ? _emptyState('cart') : _cartList()
            : _emptyState('wishlist'),
        ),
        if (_selectedTab == 0 && _cartItems.isNotEmpty) _orderInfo(),
      ]),
    );
  }

  Widget _cartList() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ..._cartItems.asMap().entries.map((e) => _CartItem(
        item: e.value,
        onRemove: () => setState(() => _cartItems.removeAt(e.key)),
        onQtyChange: (q) => setState(() => _cartItems[e.key]['qty'] = q),
      )),
    ]);
  }

  Widget _emptyState(String type) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(type == 'cart' ? Icons.shopping_cart_outlined : Icons.favorite_border,
        size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text('Your $type is empty',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(type == 'cart'
        ? "Looks like you have not added anything in your cart."
        : "Tap heart button to start saving your favorite items.",
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => context.go('/marketplace'),
        child: const Text('Explore Categories'),
      ),
      const SizedBox(height: 8),
      TextButton(onPressed: () => context.go('/marketplace'), child: const Text('Back')),
    ]));
  }

  Widget _orderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(children: [
        if (_showVoucher) ...[
          TextField(controller: _voucherController,
            decoration: const InputDecoration(hintText: 'Enter voucher number')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Apply'))),
            const SizedBox(width: 8),
            TextButton(onPressed: () => setState(() => _showVoucher = false),
              child: const Text('Cancel')),
          ]),
          const SizedBox(height: 8),
        ],
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Order Info', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(),
        ]),
        const SizedBox(height: 8),
        _row('Subtotal', 'R${_subtotal.toStringAsFixed(2)}'),
        _row('Shipping Cost', 'R0.00'),
        const Divider(),
        _row('Total', 'R${_subtotal.toStringAsFixed(2)}', bold: true),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          child: Text('Checkout(${_cartItems.length})'),
        ),
        TextButton(onPressed: () => context.go('/marketplace'), child: const Text('Back')),
      ]),
    );
  }

  Widget _row(String l, String r, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(color: bold ? AppColors.textDark : AppColors.textGrey, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(r, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}

class _CartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;
  const _CartItem({required this.item, required this.onRemove, required this.onQtyChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(width: 60, height: 60,
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.watch, color: Colors.grey)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          Row(children: [
            Text('R${item['price']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text('R${item['oldPrice']}',
              style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.textGrey, fontSize: 11)),
          ]),
          Row(children: [
            GestureDetector(
              onTap: () { if (item['qty'] > 1) onQtyChange(item['qty'] - 1); },
              child: Container(width: 24, height: 24,
                decoration: BoxDecoration(border: Border.all(color: AppColors.inputBorder), borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.remove, size: 14)),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${item['qty']}')),
            GestureDetector(
              onTap: () => onQtyChange(item['qty'] + 1),
              child: Container(width: 24, height: 24,
                decoration: BoxDecoration(border: Border.all(color: AppColors.inputBorder), borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.add, size: 14)),
            ),
          ]),
        ])),
        IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.primary), onPressed: onRemove),
      ]),
    );
  }
}
