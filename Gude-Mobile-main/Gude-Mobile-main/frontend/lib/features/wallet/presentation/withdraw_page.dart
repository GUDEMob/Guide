import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});
  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  int _step = 0;
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  String? _selectedStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => _step == 0 ? context.go('/wallet') : setState(() => _step--)),
        title: const Text('CASH WITHDRAW', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: _step == 2 ? _success() : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text('Get a guidecode to withdraw cash at a till point.',
                style: TextStyle(fontSize: 12, color: Colors.blue))),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('From Account', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.inputBorder), borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [
              Icon(Icons.account_balance, size: 18, color: AppColors.textGrey),
              SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current balance', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                Text('R100.00 ZAR', style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Amount', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 6),
          TextField(controller: _amountController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'R 0.00')),
          const SizedBox(height: 6),
          const Text('Withdraw amount must be from R20.00ZAR to R4500.00ZAR',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
          const SizedBox(height: 16),
          const Text('Pin', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 6),
          TextField(controller: _pinController, obscureText: true, keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'PIN')),
          const SizedBox(height: 6),
          const Text('Please create a secret pin 4 digits for money withdrawal',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
          const SizedBox(height: 16),
          const Text('Please choose a retail Partners', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedStore,
            decoration: const InputDecoration(hintText: 'Choose a Store'),
            items: ['Boxer', 'Checkers', 'PnP', 'Spar'].map((s) =>
              DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _selectedStore = v),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _step = 2),
            child: const Text('Get Guidecode'),
          ),
        ]),
      ),
    );
  }

  Widget _success() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text('R100.00 ZAR', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text('Withdrawal Successfully', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Column(children: [
              Text('FFNP 54AE 8953 02', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
              SizedBox(height: 8),
              Text('For security reasons, this voucher will only be valid for 3 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Download Voucher')),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.go('/wallet'),
            child: const Text('Go back to wallet', style: TextStyle(color: AppColors.primary))),
        ]),
      ),
    );
  }
}
