import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _C {
  static const primary = Color(0xFFE30613);
  static const dark    = Color(0xFF1A1A1A);
  static const grey    = Color(0xFF888888);
  static const border  = Color(0xFFE0E0E0);
  static const inputBg = Color(0xFFFAFAFA);
}

// ─────────────────────────────────────────────
// FORGOT PASSWORD PAGE
// Matches the Figma: back button, logo, Log in/Sign up tabs,
// Name + Email + OTP + Password fields, Sign up CTA + Google
// ─────────────────────────────────────────────
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _otp      = TextEditingController();
  final _password = TextEditingController();
  bool _obscure   = true;
  bool _sent      = false; // tracks if OTP was sent

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    // In a real app: validate and call backend
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios_rounded,
                          size: 14, color: _C.dark),
                      SizedBox(width: 4),
                      Text('back',
                          style: TextStyle(
                              fontSize: 13,
                              color: _C.dark,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),

              // ── Logo ─────────────────────────────
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('G',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('GUDE',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _C.dark,
                          letterSpacing: -0.5)),
                ],
              ),

              // ── Tabs: Log in / Sign up ────────────
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _tab('Log in', false,
                        () => context.go('/login')),
                    const SizedBox(width: 4),
                    _tab('Sign up', true, () {}),
                  ],
                ),
              ),

              // ── Title ────────────────────────────
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Create account',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _C.dark,
                        letterSpacing: -0.3)),
              ),
              const SizedBox(height: 20),

              // ── Fields ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Names
                    _label('Names'),
                    const SizedBox(height: 6),
                    _field(
                      controller: _name,
                      hint: 'Enter full names',
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),

                    // Email
                    _label('Email Address'),
                    const SizedBox(height: 6),
                    _field(
                      controller: _email,
                      hint: 'Enter email address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // OTP
                    _label('Otp pin'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _otp,
                            hint: 'Enter pin',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _sent = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: _sent
                                  ? const Color(0xFFEEEEEE)
                                  : _C.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _sent ? 'Resend' : 'Send OTP',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _sent
                                      ? _C.grey
                                      : Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _label('Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      style: const TextStyle(
                          fontSize: 14, color: _C.dark),
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 13),
                        filled: true,
                        fillColor: _C.inputBg,
                        contentPadding:
                            const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 14),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: const Color(0xFFBBBBBB),
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: _C.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: _C.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: _C.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.dark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text('Sign up',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Google sign-in
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.dark,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          side: const BorderSide(
                              color: _C.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Text('G',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFDB4437))),
                        label: const Text('Sign in with Google',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login redirect
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                                fontSize: 13, color: _C.grey),
                            children: [
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                    color: _C.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _C.grey),
      );

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _C.dark : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _C.grey,
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        style: const TextStyle(fontSize: 14, color: _C.dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: Color(0xFFBBBBBB), fontSize: 13),
          filled: true,
          fillColor: _C.inputBg,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 13, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: _C.primary, width: 1.5),
          ),
        ),
      );
}