import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class QuickActionsPage extends StatefulWidget {
  const QuickActionsPage({super.key});
  @override
  State<QuickActionsPage> createState() => _QuickActionsPageState();
}

class _QuickActionsPageState extends State<QuickActionsPage> {
  final Map<String, bool> _favourites = {
    'Send Money': true, 'Withdraw': true, 'Transfer': true, 'My Pockets': true,
  };
  final Map<String, bool> _more = {
    'Buy airtime': false, 'Buy Data': false, 'Pay Bills': false,
    'Buy electricity': false, 'Buy voucher': false, 'Payshop': false, 'My benefits': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.go('/wallet')),
        title: const Text('QUICK ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Add More Quick Actions', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('My Favourite Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        ..._favourites.keys.map((k) => _ActionTile(label: k, checked: _favourites[k]!,
          onChanged: (v) => setState(() => _favourites[k] = v!))),
        const SizedBox(height: 16),
        const Text('Choose Favourite Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        ..._more.keys.map((k) => _ActionTile(label: k, checked: _more[k]!,
          onChanged: (v) => setState(() => _more[k] = v!))),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;
  const _ActionTile({required this.label, required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Checkbox(value: checked, onChanged: onChanged, activeColor: AppColors.primary),
      ]),
    );
  }
}
