import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/wallet_service.dart';

// ─────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const green = Color(0xFF10B981);
}

// ─────────────────────────────────────────────────────────────
// SEND MONEY SCREEN
// Step 0 → Select Recipient
// Step 1 → Pay Details (amount, note)
// Step 2 → Confirm
// Step 3 → Success
// ─────────────────────────────────────────────────────────────
class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  // ── State ──────────────────────────────────────────────────
  int _step = 0;
  Map<String, dynamic>? _selectedContact;
  bool _useManualEntry = false;
  String _sortBy = 'Recent';

  /// The pocket the user is sending from — read from GoRouter extra.
  Pocket? _sourcePocket;

  final _manualNameCtrl = TextEditingController();
  final _manualHandleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _searchQuery = '';

  final List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Susan Precious',
      'number': '+2769335215',
      'initials': 'SP',
      'color': const Color(0xFFE91E63),
      'lastSentDate': DateTime.now().subtract(const Duration(days: 1)),
      'totalSent': 450.0,
    },
    {
      'name': 'Kinalwe Hope',
      'number': '+2761234567',
      'initials': 'KH',
      'color': const Color(0xFF4CAF50),
      'lastSentDate': DateTime.now().subtract(const Duration(days: 5)),
      'totalSent': 1200.0,
    },
    {
      'name': 'Pearl Hlogwane',
      'number': '+2769876543',
      'initials': 'PH',
      'color': const Color(0xFF9C27B0),
      'lastSentDate': DateTime.now().subtract(const Duration(days: 2)),
      'totalSent': 300.0,
    },
    {
      'name': 'Thabo Mbeki',
      'number': '+2761234578',
      'initials': 'TM',
      'color': const Color(0xFF3F51B5),
      'lastSentDate': DateTime.now().subtract(const Duration(hours: 3)),
      'totalSent': 75.0,
    },
  ];

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map && extra['pocket'] is Pocket) {
        setState(() => _sourcePocket = extra['pocket'] as Pocket);
      }
      // Fall back to the main account if nothing was passed
      _sourcePocket ??= WalletService().pockets.isNotEmpty
          ? WalletService().pockets.first
          : null;
    });
  }

  @override
  void dispose() {
    _manualNameCtrl.dispose();
    _manualHandleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Derived ────────────────────────────────────────────────
  List<Map<String, dynamic>> get _sortedContacts {
    final list = List<Map<String, dynamic>>.from(_contacts);
    switch (_sortBy) {
      case 'Recent':
        list.sort((a, b) => (b['lastSentDate'] as DateTime)
            .compareTo(a['lastSentDate'] as DateTime));
        break;
      case 'Most Sent':
        list.sort((a, b) =>
            (b['totalSent'] as double).compareTo(a['totalSent'] as double));
        break;
      case 'A-Z':
        list.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredContacts {
    final sorted = _sortedContacts;
    if (_searchQuery.isEmpty) return sorted;
    final q = _searchQuery.toLowerCase();
    return sorted
        .where((c) =>
            (c['name'] as String).toLowerCase().contains(q) ||
            (c['number'] as String).toLowerCase().contains(q))
        .toList();
  }

  String get _recipientName {
    if (_useManualEntry) {
      final t = _manualNameCtrl.text.trim();
      return t.isEmpty ? 'New Contact' : t;
    }
    return (_selectedContact?['name'] as String?) ?? '';
  }

  bool get _canProceedStep0 => _useManualEntry
      ? _manualNameCtrl.text.trim().isNotEmpty &&
          _manualHandleCtrl.text.trim().isNotEmpty
      : _selectedContact != null;

  bool get _canProceedStep1 {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    return amount > 0;
  }

  /// Always reads the live balance from the service so it stays
  /// accurate after the debit without needing to rebuild the pocket ref.
  double get _sourcePocketBalance {
    if (_sourcePocket == null) return 0.0;
    final live = WalletService()
        .pockets
        .where((p) => p.id == _sourcePocket!.id)
        .toList();
    return live.isNotEmpty ? live.first.balance : _sourcePocket!.balance;
  }

  // ── Send & debit ───────────────────────────────────────────
  void _send() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) return;

    final walletService = WalletService();
    final pocketId = _sourcePocket?.id ?? walletService.pockets.first.id;

    final note = _noteCtrl.text.trim();
    final label = note.isNotEmpty
        ? 'Sent to $_recipientName ($note)'
        : 'Sent to $_recipientName';

    final success = walletService.debitPocket(pocketId, amount, label);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Color(0xFFE30613),
        ),
      );
      return;
    }

    setState(() => _step = 3);
  }

  // ── Dialogs / Sheets ───────────────────────────────────────
  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Contact',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                hintText: 'e.g. John Doe',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                hintText: '+27 12 345 6789',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF999999))),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final number = numberCtrl.text.trim();
              if (name.isNotEmpty && number.isNotEmpty) {
                final initials =
                    name.split(' ').map((e) => e[0]).join().toUpperCase();
                final colors = [
                  0xFFE91E63,
                  0xFF4CAF50,
                  0xFF9C27B0,
                  0xFF3F51B5,
                  0xFFFF9800,
                  0xFF00BCD4,
                ];
                final color = Color(colors[_contacts.length % colors.length]);
                setState(() {
                  _contacts.add({
                    'name': name,
                    'number': number,
                    'initials': initials,
                    'color': color,
                    'lastSentDate': DateTime.now(),
                    'totalSent': 0.0,
                  });
                });
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please fill in both fields')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _C.primary),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          for (final opt in ['Recent', 'Most Sent', 'A-Z'])
            ListTile(
              title: Text(opt),
              trailing: _sortBy == opt
                  ? const Icon(Icons.check, color: _C.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = opt);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            _step > 0 && _step < 3
                ? Icons.arrow_back_ios_rounded
                : Icons.close_rounded,
            color: _C.dark,
            size: 18,
          ),
          onPressed: () {
            if (_step > 0 && _step < 3) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          ['Send Money', 'Enter Amount', 'Confirm', 'Done'][_step],
          style: const TextStyle(
              color: _C.dark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        bottom: _step < 3
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: _StepIndicator(current: _step, total: 3))
            : null,
      ),
      floatingActionButton: _step == 0
          ? FloatingActionButton(
              onPressed: _showAddContactDialog,
              backgroundColor: _C.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: [_step0(), _step1(), _step2(), _step3()][_step],
      ),
    );
  }

  // ── STEP 0: Choose recipient ────────────────────────────────
  Widget _step0() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source pocket banner
                if (_sourcePocket != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _sourcePocket!.color.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _sourcePocket!.color.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Text(_sourcePocket!.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sending from',
                                style: TextStyle(fontSize: 10, color: _C.grey)),
                            Text(_sourcePocket!.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _C.dark)),
                          ]),
                      const Spacer(),
                      Text(
                        'R${_sourcePocketBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _sourcePocket!.color),
                      ),
                    ]),
                  ),

                // Search bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _C.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search contacts…',
                      hintStyle:
                          TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                      prefixIcon: Icon(Icons.search, color: _C.grey, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sort row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Contacts',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF999999))),
                    GestureDetector(
                      onTap: _showSortOptions,
                      child: Row(children: [
                        Text(_sortBy,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _C.primary,
                                fontWeight: FontWeight.w500)),
                        const Icon(Icons.arrow_drop_down, color: _C.primary),
                      ]),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Toggle: search vs manual
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _useManualEntry = false;
                        _selectedContact = null;
                      }),
                      child: _ToggleTab(
                          label: 'Search users',
                          icon: Icons.person_search_outlined,
                          selected: !_useManualEntry),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _useManualEntry = true;
                        _selectedContact = null;
                      }),
                      child: _ToggleTab(
                          label: 'Add manually',
                          icon: Icons.edit_outlined,
                          selected: _useManualEntry),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                if (_useManualEntry) ...[
                  const Text('Recipient Details',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.dark)),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter the name and Gude handle or phone number.',
                    style: TextStyle(fontSize: 12, color: _C.grey, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _label('Full Name *'),
                  const SizedBox(height: 6),
                  _inputField(
                      controller: _manualNameCtrl,
                      hint: 'e.g. John Dlamini',
                      icon: Icons.person_outline_rounded,
                      onChanged: () => setState(() {})),
                  const SizedBox(height: 14),
                  _label('Gude Handle or Phone Number *'),
                  const SizedBox(height: 6),
                  _inputField(
                      controller: _manualHandleCtrl,
                      hint: '@handle or 071 234 5678',
                      icon: Icons.alternate_email_rounded,
                      onChanged: () => setState(() {})),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.5)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFFF59E0B), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Make sure the handle or number is correct. Payments cannot be reversed once sent.',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF92400E),
                              height: 1.4),
                        ),
                      ),
                    ]),
                  ),
                ] else ...[
                  // Contact list
                  const Text('Recent Contacts',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.dark)),
                  const SizedBox(height: 12),
                  if (_filteredContacts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No contacts found',
                            style: TextStyle(color: _C.grey)),
                      ),
                    )
                  else
                    ...(_filteredContacts.map((c) => GestureDetector(
                          onTap: () => setState(() => _selectedContact = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _selectedContact?['name'] == c['name']
                                  ? _C.primary.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _selectedContact?['name'] == c['name']
                                    ? _C.primary
                                    : _C.border,
                                width: _selectedContact?['name'] == c['name']
                                    ? 1.8
                                    : 1,
                              ),
                            ),
                            child: Row(children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    (c['color'] as Color).withOpacity(0.15),
                                child: Text(
                                  c['initials'] as String,
                                  style: TextStyle(
                                      color: c['color'] as Color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'] as String,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _C.dark)),
                                    Text(c['number'] as String,
                                        style: const TextStyle(
                                            fontSize: 12, color: _C.grey)),
                                  ],
                                ),
                              ),
                              if (_selectedContact?['name'] == c['name'])
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                      color: _C.primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.check,
                                      size: 12, color: Colors.white),
                                ),
                            ]),
                          ),
                        ))),
                ],
              ],
            ),
          ),
        ),

        // CTA
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _canProceedStep0 ? _C.primary : const Color(0xFFDDDDDD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: _canProceedStep0 ? 4 : 0,
                shadowColor: _C.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed:
                  _canProceedStep0 ? () => setState(() => _step = 1) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      _canProceedStep0
                          ? 'Continue to Amount'
                          : 'Select a recipient',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  if (_canProceedStep0) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 1: Enter amount ─────────────────────────────────────
  Widget _step1() {
    return Column(
      key: const ValueKey(1),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipient summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _C.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _C.primary.withOpacity(0.15),
                      child: Text(
                        _recipientName.isNotEmpty
                            ? _recipientName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: _C.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sending to',
                            style: TextStyle(fontSize: 11, color: _C.grey)),
                        Text(_recipientName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _C.dark)),
                      ],
                    ),
                  ]),
                ),

                const SizedBox(height: 12),

                // Source pocket summary
                if (_sourcePocket != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _sourcePocket!.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _sourcePocket!.color.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Text(_sourcePocket!.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sending from',
                                style: TextStyle(fontSize: 11, color: _C.grey)),
                            Text(_sourcePocket!.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _C.dark)),
                          ]),
                      const Spacer(),
                      Text(
                        'R${_sourcePocketBalance.toStringAsFixed(2)} available',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _sourcePocket!.color),
                      ),
                    ]),
                  ),

                const SizedBox(height: 28),

                // Amount input
                Center(
                  child: Column(children: [
                    const Text('Amount',
                        style: TextStyle(fontSize: 13, color: _C.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('R',
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: _C.dark)),
                        const SizedBox(width: 4),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textAlign: TextAlign.center,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: _C.dark),
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFDDDDDD)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Available: R${_sourcePocketBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: _C.grey),
                    ),
                  ]),
                ),

                const SizedBox(height: 28),

                // Quick amounts
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['50', '100', '200', '500', '1000'].map((a) {
                    final selected = _amountCtrl.text == a;
                    return GestureDetector(
                      onTap: () => setState(() => _amountCtrl.text = a),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? _C.primary.withOpacity(0.1)
                              : _C.lightGrey,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: selected ? _C.primary : _C.border),
                        ),
                        child: Text('R$a',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? _C.primary : _C.dark)),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                _label('Note (optional)'),
                const SizedBox(height: 6),
                _inputField(
                    controller: _noteCtrl,
                    hint: 'e.g. Lunch money',
                    icon: Icons.note_outlined),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _canProceedStep1 ? _C.primary : const Color(0xFFDDDDDD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: _canProceedStep1 ? 4 : 0,
                shadowColor: _C.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed:
                  _canProceedStep1 ? () => setState(() => _step = 2) : null,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Review Transfer',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 2: Confirm ──────────────────────────────────────────
  Widget _step2() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final isOverBalance = amount > _sourcePocketBalance;

    return Column(
      key: const ValueKey(2),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  const Text('Transfer Summary',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.dark)),
                  const SizedBox(height: 16),
                  if (_sourcePocket != null)
                    _summaryRow('From',
                        '${_sourcePocket!.emoji} ${_sourcePocket!.name}'),
                  _summaryRow('To', _recipientName),
                  _summaryRow('Amount', 'R${amount.toStringAsFixed(2)}'),
                  _summaryRow('Fee', 'R0.00'),
                  const Divider(height: 20),
                  _summaryRow('Total', 'R${amount.toStringAsFixed(2)}',
                      bold: true),
                  if (_noteCtrl.text.isNotEmpty)
                    _summaryRow('Note', _noteCtrl.text),
                ]),
              ),
              const SizedBox(height: 16),

              // Insufficient balance warning
              if (isOverBalance)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFE30613).withOpacity(0.4)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.error_outline_rounded,
                        color: Color(0xFFE30613), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amount exceeds available balance. Please go back and enter a lower amount.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB71C1C),
                            height: 1.4),
                      ),
                    ),
                  ]),
                ),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.5)),
                ),
                child: const Row(children: [
                  Icon(Icons.lock_outline_rounded,
                      color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This transfer is secured and cannot be reversed once sent. Please review carefully.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF92400E), height: 1.4),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isOverBalance ? const Color(0xFFDDDDDD) : _C.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: isOverBalance ? 0 : 4,
                shadowColor: _C.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: isOverBalance ? null : _send,
              child: Text(
                'Send R${amount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 3: Success ──────────────────────────────────────────
  Widget _step3() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    return SafeArea(
      key: const ValueKey(3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(flex: 2),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
                color: Color(0xFFF0FFF4), shape: BoxShape.circle),
            child: const Center(
              child:
                  Icon(Icons.check_circle_rounded, size: 64, color: _C.green),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Transfer Successful!',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: _C.dark)),
          const SizedBox(height: 8),
          Text(
            'R${amount.toStringAsFixed(2)} has been sent to $_recipientName.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _C.grey, height: 1.5),
          ),
          if (_sourcePocket != null) ...[
            const SizedBox(height: 6),
            Text(
              'Deducted from ${_sourcePocket!.emoji} ${_sourcePocket!.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: _sourcePocket!.color,
                  fontWeight: FontWeight.w600),
            ),
          ],
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => context.go('/wallet'),
              child: const Text('Back to Wallet',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Shared helpers ───────────────────────────────────────────
  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: _C.grey));

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    VoidCallback? onChanged,
  }) =>
      TextFormField(
        controller: controller,
        onChanged: (_) => onChanged?.call(),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: _C.dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5)),
        ),
      );

  Widget _summaryRow(String label, String value, {bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: bold ? _C.dark : _C.grey,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    color: bold ? _C.primary : _C.dark)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// TOGGLE TAB
// ─────────────────────────────────────────────────────────────
class _ToggleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _ToggleTab(
      {required this.label, required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color:
            selected ? _C.primary.withOpacity(0.07) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _C.primary : _C.border,
          width: selected ? 1.8 : 1,
        ),
      ),
      child: Column(children: [
        Icon(icon,
            color: selected ? _C.primary : const Color(0xFF888888), size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? _C.primary : const Color(0xFF888888))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP INDICATOR
// ─────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current, total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: List.generate(
          total,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: i <= current ? _C.primary : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// RECEIVED MONEY SCREEN
// ─────────────────────────────────────────────────────────────
class ReceivedMoneyScreen extends StatelessWidget {
  const ReceivedMoneyScreen({super.key});

  static const _received = [
    {
      'name': 'James Mokoena',
      'initials': 'JM',
      'amount': 150.0,
      'date': 'Today, 10:30'
    },
    {
      'name': 'Sipho Ndlovu',
      'initials': 'SN',
      'amount': 300.0,
      'date': 'Yesterday, 15:42'
    },
    {
      'name': 'Amara Dube',
      'initials': 'AD',
      'amount': 450.0,
      'date': 'Mon, 09:00'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Received Money',
            style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _received.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
        itemBuilder: (_, i) {
          final r = _received[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                child: Text(r['initials'] as String,
                    style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['name'] as String,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A))),
                      Text(r['date'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888))),
                    ]),
              ),
              Text('+R${(r['amount'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981))),
            ]),
          );
        },
      ),
    );
  }
}
