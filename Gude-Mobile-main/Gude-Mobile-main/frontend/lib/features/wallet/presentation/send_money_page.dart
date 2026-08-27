import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});
  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  int _step = 0; // 0=select recipient, 1=pay details, 2=success
  int _selectedContact = -1;
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  bool _immediate = false;

  final List<Map<String, String>> _contacts = [
    {'name': 'Susan Precious', 'number': '+2769335215', 'initials': 'SP', 'color': '0xFFE91E63'},
    {'name': 'Kinalwe Hope',   'number': '+2761234567', 'initials': 'KH', 'color': '0xFF4CAF50'},
    {'name': 'PearlHlogwane',  'number': '+2769876543', 'initials': 'PH', 'color': '0xFF9C27B0'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => _step == 0 ? context.go('/wallet') : setState(() => _step--)),
        title: Column(children: [
          Text(_step == 2 ? 'Send Money' : 'Send Money',
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          Text(_step == 0 ? '1/1 Select Recipient' : _step == 1 ? 'Pay' : 'Transaction Details',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ]),
        actions: _step == 0 ? [] : [
          TextButton(onPressed: () {},
            child: const Text('Next', style: TextStyle(color: AppColors.primary))),
        ],
      ),
      body: _step == 0 ? _selectRecipient() : _step == 1 ? _payDetails() : _success(),
    );
  }

  Widget _selectRecipient() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Who do you want to send Money to?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            _tab('Contact', true),
            const SizedBox(width: 8),
            _tab('Group', false),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Contact Names', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const Icon(Icons.sort, color: AppColors.textGrey, size: 18),
          ]),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _contacts.length,
          itemBuilder: (_, i) {
            final c = _contacts[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(int.parse(c['color']!)),
                child: Text(c['initials']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Created by | 1 May 2025', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              selected: _selectedContact == i,
              onTap: () => setState(() => _selectedContact = i),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          OutlinedButton(
            onPressed: () => context.go('/wallet'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _selectedContact >= 0 ? () => setState(() => _step = 1) : null,
            child: const Text('Continue'),
          )),
        ]),
      ),
    ]);
  }

  Widget _payDetails() {
    if (_selectedContact < 0) return const SizedBox();
    final c = _contacts[_selectedContact];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Column(children: [
          CircleAvatar(
            radius: 36, backgroundColor: Color(int.parse(c['color']!)),
            child: Text(c['initials']!, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(c['number']!, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        ])),
        const SizedBox(height: 24),
        _detailRow('From Account', 'Current Balance', 'R190.00 ZAR'),
        const SizedBox(height: 16),
        _detailRow('To', c['name']!, c['number']!),
        const SizedBox(height: 16),
        const Text('Amount', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 6),
        TextField(controller: _amountController, keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'R 0.00')),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() => _immediate = false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: !_immediate ? AppColors.primary : AppColors.inputBorder)),
            child: Text('Normal EFT', style: TextStyle(color: !_immediate ? AppColors.primary : AppColors.textGrey)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () => setState(() => _immediate = true),
            style: ElevatedButton.styleFrom(backgroundColor: _immediate ? AppColors.primary : Colors.grey.shade300),
            child: const Text('Immediate EFT'),
          )),
        ]),
        const SizedBox(height: 16),
        const Text('My reference', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 6),
        TextField(controller: _refController, decoration: const InputDecoration(hintText: 'Reference')),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => setState(() => _step = 2),
          child: const Text('Send Money'),
        ),
      ]),
    );
  }

  Widget _success() {
    if (_selectedContact < 0) return const SizedBox();
    final c = _contacts[_selectedContact];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          Text('R${_amountController.text.isEmpty ? '100' : _amountController.text}.00 ZAR',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _detailRow('From Account', 'Current Account', 'R190.00 ZAR'),
          const Divider(height: 24),
          _detailRow('To', '1 recipient', ''),
          _detailRow('Date & Time', '20 June 2025, 20:48 PM', ''),
          _detailRow('Status', 'Successful', ''),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() { _step = 0; _selectedContact = -1; }),
            child: const Text('Send Money Again'),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.go('/wallet'),
            child: const Text('Back to Wallet', style: TextStyle(color: AppColors.primary))),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value, String sub) {
    return Row(children: [
      Icon(Icons.account_balance, size: 18, color: AppColors.textGrey),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ])),
    ]);
  }

  Widget _tab(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AppColors.primary : AppColors.inputBorder),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w500)),
    );
  }
}
