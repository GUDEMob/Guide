// lib/features/auth/presentation/student_verification_page.dart
// Steps: 0=ID doc → 1=Student card upload → 2=Bank card → 3=Done
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class _C {
  static const primary     = Color(0xFFE30613);
  static const primaryDark = Color(0xFFB0000E);
  static const dark        = Color(0xFF1A1A1A);
  static const grey        = Color(0xFF888888);
  static const border      = Color(0xFFE8E8E8);
  static const inputBg     = Color(0xFFFAFAFA);
  static const green       = Color(0xFF10B981);
}

enum _CardType { unknown, visa, mastercard, amex, discover }

_CardType _detectCardType(String number) {
  final n = number.replaceAll(' ', '');
  if (n.startsWith('4')) return _CardType.visa;
  if (RegExp(r'^5[1-5]').hasMatch(n) || RegExp(r'^2(2[2-9][1-9]|[3-6]\d{2}|7([01]\d|20))').hasMatch(n)) return _CardType.mastercard;
  if (RegExp(r'^3[47]').hasMatch(n)) return _CardType.amex;
  if (RegExp(r'^6(?:011|5)').hasMatch(n)) return _CardType.discover;
  return _CardType.unknown;
}

class StudentVerificationPage extends StatefulWidget {
  const StudentVerificationPage({super.key});
  @override
  State<StudentVerificationPage> createState() => _StudentVerificationPageState();
}

class _StudentVerificationPageState extends State<StudentVerificationPage>
    with SingleTickerProviderStateMixin {
  // 0 = ID doc, 1 = student card, 2 = bank card, 3 = done
  int _step = 0;

  // Step 0 – SA ID
  final _idCtrl = TextEditingController();
  String? _idImagePath; // simulated

  // Step 1 – Student card
  final _studentNoCtrl    = TextEditingController();
  String? _selectedInstitution;
  String? _studentCardPath; // simulated

  // Step 2 – Bank card
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl   = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl    = TextEditingController();
  bool _cardFlipped = false;
  _CardType _cardType = _CardType.unknown;

  late AnimationController _flipCtrl;
  late Animation<double>   _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
    _cardNumberCtrl.addListener(() {
      final d = _detectCardType(_cardNumberCtrl.text);
      if (d != _cardType) setState(() => _cardType = d);
    });
    _cardCvvCtrl.addListener(() {
      final has = _cardCvvCtrl.text.isNotEmpty;
      if (has && !_cardFlipped) { _flipCtrl.forward(); setState(() => _cardFlipped = true); }
      else if (!has && _cardFlipped) { _flipCtrl.reverse(); setState(() => _cardFlipped = false); }
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _idCtrl.dispose();
    _studentNoCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  String get _formattedNumber {
    final raw = _cardNumberCtrl.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < raw.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(raw[i]);
    }
    return buf.toString().padRight(19, '•'.padLeft(1));
  }

  String get _stepTitle {
    switch (_step) {
      case 0: return 'Identity Verification';
      case 1: return 'Student Card Upload';
      case 2: return 'Link Bank Card';
      default: return 'All Set!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
                onPressed: () => setState(() => _step--))
            : IconButton(
                icon: const Icon(Icons.close, color: _C.dark),
                onPressed: () => context.pop()),
        title: Text(_stepTitle,
            style: const TextStyle(color: _C.dark, fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepProgressBar(current: _step, total: 3),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _step == 0
            ? _IdStep(
                key: const ValueKey(0),
                ctrl: _idCtrl,
                hasUpload: _idImagePath != null,
                onPickImage: () => setState(() => _idImagePath = 'simulated'),
                onNext: () => setState(() => _step = 1),
              )
            : _step == 1
                ? _StudentCardStep(
                    key: const ValueKey(1),
                    studentNoCtrl: _studentNoCtrl,
                    selectedInstitution: _selectedInstitution,
                    hasCard: _studentCardPath != null,
                    onInstitutionChanged: (v) => setState(() => _selectedInstitution = v),
                    onPickCard: () => setState(() => _studentCardPath = 'simulated'),
                    onNext: () => setState(() => _step = 2),
                  )
                : _step == 2
                    ? _BankCardStep(
                        key: const ValueKey(2),
                        cardNumberCtrl: _cardNumberCtrl,
                        cardNameCtrl: _cardNameCtrl,
                        cardExpiryCtrl: _cardExpiryCtrl,
                        cardCvvCtrl: _cardCvvCtrl,
                        cardType: _cardType,
                        flipAnim: _flipAnim,
                        formattedNumber: _formattedNumber,
                        onCvvFocus: (focused) {
                          if (focused && !_cardFlipped) { _flipCtrl.forward(); setState(() => _cardFlipped = true); }
                          else if (!focused && _cardFlipped) { _flipCtrl.reverse(); setState(() => _cardFlipped = false); }
                        },
                        onNext: () => setState(() => _step = 3),
                      )
                    : _SuccessStep(
                        key: const ValueKey(3),
                        onDone: () => context.go('/home'),
                      ),
      ),
    );
  }
}

// ─── Step progress bar ──────────────────────────────────────────────
class _StepProgressBar extends StatelessWidget {
  final int current, total;
  const _StepProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: List.generate(total, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: done ? _C.green : active ? _C.primary : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step 0: SA ID ─────────────────────────────────────────────────
class _IdStep extends StatelessWidget {
  final TextEditingController ctrl;
  final bool hasUpload;
  final VoidCallback onPickImage, onNext;
  const _IdStep({super.key, required this.ctrl, required this.hasUpload, required this.onPickImage, required this.onNext});

  @override
  Widget build(BuildContext context) => _StepShell(
    emoji: '🪪',
    title: 'Verify your identity',
    subtitle: 'Enter your SA ID number and upload a photo of your ID document',
    onNext: onNext,
    nextLabel: 'Continue',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('SA ID Number'),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        maxLength: 13,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDeco('e.g. 9001015009087', Icons.badge_outlined),
      ),
      const SizedBox(height: 16),
      _label('ID Document Photo'),
      const SizedBox(height: 8),
      _UploadBox(
        label: hasUpload ? 'ID document uploaded ✓' : 'Tap to upload ID document',
        icon: hasUpload ? Icons.check_circle_outline : Icons.upload_file_outlined,
        isDone: hasUpload,
        onTap: onPickImage,
      ),
    ]),
  );
}

// ─── Step 1: Student card upload ────────────────────────────────────
class _StudentCardStep extends StatelessWidget {
  final TextEditingController studentNoCtrl;
  final String? selectedInstitution;
  final bool hasCard;
  final ValueChanged<String?> onInstitutionChanged;
  final VoidCallback onPickCard, onNext;

  const _StudentCardStep({
    super.key,
    required this.studentNoCtrl,
    required this.selectedInstitution,
    required this.hasCard,
    required this.onInstitutionChanged,
    required this.onPickCard,
    required this.onNext,
  });

  static const _institutions = [
    'UCT', 'Wits', 'Stellenbosch University', 'UKZN',
    'University of Pretoria', 'UJ', 'TUT', 'CPUT',
    'DUT', 'NMU', 'UWC', 'UFS', 'Rhodes', 'NWU', 'Other',
  ];

  @override
  Widget build(BuildContext context) => _StepShell(
    emoji: '🎓',
    title: 'Student card verification',
    subtitle: 'Upload your student card so we can verify your student status',
    onNext: onNext,
    nextLabel: 'Continue',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Institution'),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        initialValue: selectedInstitution,
        hint: const Text('Select your university / college',
            style: TextStyle(fontSize: 13, color: Color(0xFFBBBBBB))),
        items: _institutions.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onInstitutionChanged,
        decoration: _inputDeco(null, Icons.school_outlined),
      ),
      const SizedBox(height: 14),
      _label('Student Number'),
      const SizedBox(height: 6),
      TextFormField(
        controller: studentNoCtrl,
        decoration: _inputDeco('Enter your student number', Icons.numbers_outlined),
      ),
      const SizedBox(height: 16),
      _label('Student Card Photo'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFCCCC)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: _C.primary, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Your ID document must be uploaded first. Upload a clear photo of your student card.',
              style: TextStyle(fontSize: 11, color: Color(0xFF7F1D1D), height: 1.4),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      _UploadBox(
        label: hasCard ? 'Student card uploaded ✓' : 'Tap to upload student card',
        icon: hasCard ? Icons.check_circle_outline : Icons.badge_outlined,
        isDone: hasCard,
        onTap: onPickCard,
      ),
    ]),
  );
}

// ─── Upload box widget ───────────────────────────────────────────────
class _UploadBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone;
  final VoidCallback onTap;
  const _UploadBox({required this.label, required this.icon, required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF0FFF4) : _C.inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? _C.green : const Color(0xFFDDDDDD),
            width: isDone ? 1.5 : 1,
          ),
        ),
        child: Column(children: [
          Icon(icon, size: 32, color: isDone ? _C.green : _C.grey),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDone ? _C.green : _C.grey)),
          if (!isDone) ...[
            const SizedBox(height: 4),
            const Text('Camera, gallery, or files', style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
          ],
        ]),
      ),
    );
  }
}

// ─── Step 2: Bank card (unchanged logic) ─────────────────────────────
class _BankCardStep extends StatelessWidget {
  final TextEditingController cardNumberCtrl, cardNameCtrl, cardExpiryCtrl, cardCvvCtrl;
  final _CardType cardType;
  final Animation<double> flipAnim;
  final String formattedNumber;
  final ValueChanged<bool> onCvvFocus;
  final VoidCallback onNext;

  const _BankCardStep({
    super.key,
    required this.cardNumberCtrl,
    required this.cardNameCtrl,
    required this.cardExpiryCtrl,
    required this.cardCvvCtrl,
    required this.cardType,
    required this.flipAnim,
    required this.formattedNumber,
    required this.onCvvFocus,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Card flip preview
        AnimatedBuilder(
          animation: flipAnim,
          builder: (_, __) {
            final isFront = flipAnim.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(flipAnim.value * 3.14159),
              child: isFront
                  ? _CardFront(cardType: cardType, number: formattedNumber, name: cardNameCtrl.text.isEmpty ? 'YOUR NAME' : cardNameCtrl.text.toUpperCase(), expiry: cardExpiryCtrl.text.isEmpty ? 'MM/YY' : cardExpiryCtrl.text)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _CardBack(cvv: cardCvvCtrl.text),
                    ),
            );
          },
        ),
        const SizedBox(height: 24),
        if (cardType != _CardType.unknown)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _C.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _C.green.withOpacity(0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle, size: 14, color: _C.green),
              const SizedBox(width: 6),
              Text('${_cardTypeName(cardType)} detected', style: const TextStyle(fontSize: 12, color: _C.green, fontWeight: FontWeight.w600)),
            ]),
          ),
        _label('Card Number'),
        const SizedBox(height: 6),
        TextFormField(
          controller: cardNumberCtrl,
          keyboardType: TextInputType.number,
          maxLength: 19,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
          decoration: _inputDeco('0000 0000 0000 0000', Icons.credit_card_outlined),
        ),
        const SizedBox(height: 14),
        _label('Name on Card'),
        const SizedBox(height: 6),
        TextFormField(controller: cardNameCtrl, textCapitalization: TextCapitalization.characters, decoration: _inputDeco('YOUR FULL NAME', Icons.person_outline)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Expiry Date'), const SizedBox(height: 6),
            TextFormField(controller: cardExpiryCtrl, keyboardType: TextInputType.number, maxLength: 5, inputFormatters: [_ExpiryFormatter()], decoration: _inputDeco('MM/YY', Icons.calendar_today_outlined)),
          ])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('CVV'), const SizedBox(height: 6),
            Focus(
              onFocusChange: onCvvFocus,
              child: TextFormField(controller: cardCvvCtrl, keyboardType: TextInputType.number, maxLength: 4, obscureText: true, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: _inputDeco('•••', Icons.lock_outline_rounded)),
            ),
          ])),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _C.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 4, shadowColor: _C.primary.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: onNext,
            child: const Text('Link Card', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  String _cardTypeName(_CardType t) {
    switch (t) {
      case _CardType.visa: return 'Visa';
      case _CardType.mastercard: return 'Mastercard';
      case _CardType.amex: return 'Amex';
      case _CardType.discover: return 'Discover';
      default: return '';
    }
  }
}

class _CardFront extends StatelessWidget {
  final _CardType cardType;
  final String number, name, expiry;
  const _CardFront({required this.cardType, required this.number, required this.name, required this.expiry});

  LinearGradient get _gradient {
    switch (cardType) {
      case _CardType.visa: return const LinearGradient(colors: [Color(0xFF1A1F71), Color(0xFF2D4CC8)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case _CardType.mastercard: return const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case _CardType.amex: return const LinearGradient(colors: [Color(0xFF006FCF), Color(0xFF00A8E0)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      default: return const LinearGradient(colors: [Color(0xFFE30613), Color(0xFF8B000A)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(gradient: _gradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('GUDE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            Stack(children: [
              Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFFEB001B), shape: BoxShape.circle)),
              Positioned(left: 12, child: Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFFF79E1B).withOpacity(0.9), shape: BoxShape.circle))),
            ]),
          ]),
          const SizedBox(height: 12),
          Container(width: 34, height: 24, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(4)), child: CustomPaint(painter: _ChipPainter())),
          const Spacer(),
          Text(number, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 2.5)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CARD HOLDER', style: TextStyle(color: Colors.white60, fontSize: 9)),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('EXPIRES', style: TextStyle(color: Colors.white60, fontSize: 9)),
              Text(expiry, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ]),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final String cvv;
  const _CardBack({required this.cvv});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF333333), Color(0xFF1A1A1A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 30),
        Container(height: 40, color: const Color(0xFF111111)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: Container(height: 36, color: Colors.white, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 10), child: Text(cvv.isEmpty ? '•••' : cvv, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 4, color: Color(0xFF1A1A1A))))),
            const SizedBox(width: 12),
            const Text('CVV', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Step 3: Success ─────────────────────────────────────────────────
class _SuccessStep extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessStep({super.key, required this.onDone});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 120, height: 120, decoration: const BoxDecoration(color: Color(0xFFF0FFF4), shape: BoxShape.circle), child: const Center(child: Text('🎉', style: TextStyle(fontSize: 56)))),
        const SizedBox(height: 24),
        const Text('Verified!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 12),
        const Text('Your identity, student card, and bank card\nhave been successfully verified.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF888888), height: 1.5)),
        const SizedBox(height: 36),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE30613), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: onDone,
          child: const Text('Go to Home', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        )),
      ]),
    ),
  );
}

// ─── Step shell ──────────────────────────────────────────────────────
class _StepShell extends StatelessWidget {
  final String emoji, title, subtitle, nextLabel;
  final Widget child;
  final VoidCallback onNext;
  const _StepShell({required this.emoji, required this.title, required this.subtitle, required this.child, required this.onNext, required this.nextLabel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 72, height: 72, decoration: BoxDecoration(color: const Color(0xFFE30613).withOpacity(0.1), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 36))))),
        const SizedBox(height: 20),
        Center(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)))),
        const SizedBox(height: 6),
        Center(child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.5))),
        const SizedBox(height: 28),
        child,
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE30613), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 4, shadowColor: const Color(0xFFE30613).withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: onNext,
          child: Text(nextLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────
Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF888888)));

InputDecoration _inputDeco(String? hint, IconData icon) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
  prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
  filled: true, fillColor: const Color(0xFFFAFAFA),
  counterText: '',
  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE30613), width: 1.5)),
);

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) return oldValue;
    final buf = StringBuffer();
    for (int i = 0; i < text.length; i++) { if (i > 0 && i % 4 == 0) buf.write(' '); buf.write(text[i]); }
    final formatted = buf.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;
    if (text.length >= 3) text = '${text.substring(0, 2)}/${text.substring(2)}';
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB8964A)..strokeWidth = 0.7..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
  }
  @override
  bool shouldRepaint(_) => false;
}