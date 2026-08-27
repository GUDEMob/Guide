import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/wallet_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CASH WITHDRAW SCREEN
// Step 0 → Enter details (amount, pin, store)
// Step 1 → Success (green check, barcode, download voucher)
// ─────────────────────────────────────────────────────────────────────────────

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  int _step = 0; // 0 = form, 1 = success

  final _amountCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _pinObscure = true;
  bool _storeExpanded = false;
  String? _selectedStore;

  /// The pocket passed via GoRouter extra — resolved in initState.
  Pocket? _sourcePocket;

  static const _stores = [
    _StoreData('Boxer', Color(0xFFD22027)),
    _StoreData('Checkers', Color(0xFF007A3D)),
    _StoreData('PnP', Color(0xFF0072CE)),
    _StoreData('Shoprite', Color(0xFFD22027)),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

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
    _amountCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  // ── Live balance — always reads from the service ───────────────────────────

  double get _balance {
    if (_sourcePocket == null) return 0.0;
    final live = WalletService()
        .pockets
        .where((p) => p.id == _sourcePocket!.id)
        .toList();
    return live.isNotEmpty ? live.first.balance : _sourcePocket!.balance;
  }

  // ── Validation & submit ────────────────────────────────────────────────────

  void _submit() {
    final raw = _amountCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      _err('Please enter an amount');
      return;
    }
    final amount = double.tryParse(raw);
    if (amount == null) {
      _err('Invalid amount');
      return;
    }
    if (amount < 20) {
      _err('Minimum withdrawal is R20.00');
      return;
    }
    if (amount > 4500) {
      _err('Maximum withdrawal is R4500.00');
      return;
    }
    if (amount > _balance) {
      _err('Insufficient balance');
      return;
    }

    final pin = _pinCtrl.text.trim();
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      _err('PIN must be exactly 4 digits');
      return;
    }
    if (_selectedStore == null) {
      _err('Please choose a retail partner');
      return;
    }

    // Debit the pocket so the wallet reflects the withdrawal
    if (_sourcePocket != null) {
      final label = 'Cash Withdrawal – $_selectedStore';
      final success =
          WalletService().debitPocket(_sourcePocket!.id, amount, label);
      if (!success) {
        _err('Insufficient balance');
        return;
      }
    }

    setState(() => _step = 1);
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: const Color(0xFFFF3B3C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Guidecode generator ────────────────────────────────────────────────────

  String _guidecode() {
    final n = DateTime.now().millisecondsSinceEpoch;
    return 'FPNP ${(n % 10000).toString().padLeft(4, '0')} '
        '${((n ~/ 10000) % 10000).toString().padLeft(4, '0')} '
        '${(n % 100).toString().padLeft(2, '0')}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: _step == 1 ? _successView() : _formView(),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, size: 18, color: Color(0xFF232323)),
          onPressed: () =>
              _step == 0 ? context.go('/wallet') : setState(() => _step = 0),
        ),
        title: Text(
          _step == 1 ? 'CASH WTHDRAW' : 'CASH WITHDRAW',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF232323),
            letterSpacing: 0.8,
          ),
        ),
        actions: _step == 1
            ? [
                IconButton(
                  icon: const Icon(Icons.download_outlined,
                      color: Color(0xFF232323), size: 22),
                  onPressed: () {},
                ),
              ]
            : null,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: null,
              backgroundColor: Color(0xFFFF3B3C),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3B3C)),
            ),
          ),
        ),
      );

  // ── FORM VIEW ──────────────────────────────────────────────────────────────

  Widget _formView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Blue info banner ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFF1E90FF), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Get a guidecode to withdraw cash at a till point.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1E90FF),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── From Account ──
                const _FieldLabel('From Account'),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _sourcePocket != null
                          ? _sourcePocket!.color.withOpacity(0.4)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Show pocket emoji if available, otherwise bank icon
                      _sourcePocket != null
                          ? Text(_sourcePocket!.emoji,
                              style: const TextStyle(fontSize: 18))
                          : const Icon(Icons.account_balance_outlined,
                              size: 20, color: Color(0xFF999999)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sourcePocket?.name ?? 'Current balance',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _sourcePocket != null
                                    ? const Color(0xFF232323)
                                    : const Color(0xFF999999),
                              ),
                            ),
                            if (_sourcePocket != null)
                              const Text(
                                'Available balance',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: Color(0xFF999999),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        'R${_balance.toStringAsFixed(2)} ZAR',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              _sourcePocket?.color ?? const Color(0xFF232323),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Amount ──
                const _FieldLabel('Amount'),
                const SizedBox(height: 8),
                _StyledField(
                  controller: _amountCtrl,
                  hint: 'R 0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                ),
                const SizedBox(height: 6),
                const _HintText(
                    'Withdraw amount must be from R20.00ZAR to R6500.00ZAR'),

                const SizedBox(height: 18),

                // ── Pin ──
                const _FieldLabel('Pin'),
                const SizedBox(height: 8),
                _StyledField(
                  controller: _pinCtrl,
                  hint: 'PIN',
                  obscureText: _pinObscure,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _pinObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFFBBBBBB),
                      size: 18,
                    ),
                    onPressed: () => setState(() => _pinObscure = !_pinObscure),
                  ),
                ),
                const SizedBox(height: 6),
                const _HintText(
                    'Please create a secret pin 4 digits for money withdrawal'),

                const SizedBox(height: 18),

                // ── Choose retail partner label ──
                const _FieldLabel('Please choose a retail Partners'),
                const SizedBox(height: 8),

                // ── Store selector row ──
                GestureDetector(
                  onTap: () => setState(() => _storeExpanded = !_storeExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedStore ?? 'Choose a Store',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: _selectedStore != null
                                  ? const Color(0xFF232323)
                                  : const Color(0xFFBBBBBB),
                            ),
                          ),
                        ),
                        Icon(
                          _storeExpanded
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.chevron_right_rounded,
                          color: const Color(0xFF999999),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Store logo grid (shown when expanded) ──
                if (_storeExpanded) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _stores
                        .map((s) => _StoreLogo(
                              store: s,
                              selected: _selectedStore == s.name,
                              onTap: () => setState(() {
                                _selectedStore = s.name;
                                _storeExpanded = false;
                              }),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // ── Get Guidecode button pinned to bottom ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B3C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Get Guidecode',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── SUCCESS VIEW ───────────────────────────────────────────────────────────

  Widget _successView() {
    final code = _guidecode();
    final rawAmt = _amountCtrl.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmt) ?? 0.0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Green check circle ──
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Amount ──
                Text(
                  'R${amount.toStringAsFixed(2)} ZAR',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF232323),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Withdrawal Successfully',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),

                if (_sourcePocket != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Deducted from ${_sourcePocket!.emoji} ${_sourcePocket!.name}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _sourcePocket!.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ── Barcode ──
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: CustomPaint(painter: _BarcodePainter()),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        code,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF232323),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Security note ──
                const Text(
                  'For security reasons, this voucher will only be valid for 3 hours. Please ensure it is used within this time period.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF555555),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Red left-bar accent + Download Voucher ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B3C),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Download Voucher',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF232323),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Support note ──
                const Text(
                  '*for assistance, please contact us on 01115818552',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ── Go back to wallet ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/wallet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B3C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Go back to wallet',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF232323),
        ),
      );
}

class _HintText extends StatelessWidget {
  final String text;
  const _HintText(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Color(0xFF999999),
          height: 1.45,
        ),
      );
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  const _StyledField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF232323),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color(0xFFBBBBBB),
        ),
        counterText: '',
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF3B3C), width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE DATA + LOGO TILE
// ─────────────────────────────────────────────────────────────────────────────

class _StoreData {
  final String name;
  final Color color;
  const _StoreData(this.name, this.color);
}

class _StoreLogo extends StatelessWidget {
  final _StoreData store;
  final bool selected;
  final VoidCallback onTap;

  const _StoreLogo({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 90,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFFF3B3C) : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: _StoreLogoContent(store: store)),
      ),
    );
  }
}

class _StoreLogoContent extends StatelessWidget {
  final _StoreData store;
  const _StoreLogoContent({required this.store});

  @override
  Widget build(BuildContext context) {
    switch (store.name) {
      case 'Boxer':
        return _BoxerLogo();
      case 'Checkers':
        return _CheckersLogo();
      case 'PnP':
        return _PnPLogo();
      case 'Shoprite':
        return _ShopriteLogo();
      default:
        return Text(
          store.name,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: store.color,
          ),
        );
    }
  }
}

class _BoxerLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD22027),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'BOXER',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _CheckersLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Checkers',
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF007A3D),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _PnPLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0072CE),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('P',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
        const SizedBox(width: 2),
        const Text('n',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF232323))),
        const SizedBox(width: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFD22027),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('P',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
      ],
    );
  }
}

class _ShopriteLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD22027),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'S',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BARCODE PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeCap = StrokeCap.square;

    const pattern = [
      2,
      1,
      3,
      1,
      1,
      2,
      1,
      3,
      2,
      1,
      1,
      2,
      3,
      1,
      2,
      1,
      1,
      3,
      1,
      2,
      1,
      1,
      2,
      3,
      1,
      2,
      1,
      3,
      1,
      1,
      2,
      1,
      3,
      2,
      1,
      1,
      2,
      3,
      1,
      2,
      1,
      2,
      1,
      1,
      3,
      2,
      1,
      1,
      2,
      3,
      1,
      2,
      1,
      3,
      1,
      1,
      2,
      1,
      3,
      2,
      3,
      1,
      1,
      2,
      1,
      3,
      1,
      2,
      1,
      1,
      3,
      2,
      1,
      2,
      3,
      1,
      1,
      2,
      3,
      1,
    ];

    final totalUnits =
        pattern.fold<int>(0, (sum, v) => sum + v) + pattern.length;
    final unitW = size.width / totalUnits;

    double x = 0;
    bool isBar = true;
    for (int i = 0; i < pattern.length; i++) {
      final w = pattern[i] * unitW;
      if (isBar) {
        paint.strokeWidth = w;
        canvas.drawLine(
          Offset(x + w / 2, 0),
          Offset(x + w / 2, size.height),
          paint,
        );
      }
      x += w + unitW;
      isBar = !isBar;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
