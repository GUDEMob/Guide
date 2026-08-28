// lib/features/auth/presentation/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/widgets/gude_logo.dart';
import 'package:gude_app/services/user_role_service.dart';

class _C {
  static const primary = Color(0xFFE30613);
  static const primaryDark = Color(0xFFB0000E);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const border = Color(0xFFE0E0E0);
  static const focusBorder = Color(0xFF444444); // dark grey focus, NOT red
  static const inputBg = Color(0xFFFAFAFA);
  static const errorRed = Color(0xFFE30613);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _institutionCode = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = false;
  bool _emailError = false;
  bool _passwordError = false;
  String? _emailValidationError;
  String _role = 'student';
  String _userType = 'student';

  bool _isValidStudentEmail(String email) {
    final re = RegExp(r'^[^@]+@[^@]+\.(ac\.za|edu\.za)$', caseSensitive: false);
    return re.hasMatch(email.trim());
  }

  bool _isValidInstitutionEmail(String email) {
    final re = RegExp(r'^[^@]+@[^@]+\.(ac\.za|edu\.za)$', caseSensitive: false);
    return re.hasMatch(email.trim());
  }

  void _login() {
    setState(() {
      _emailError = _email.text.trim().isEmpty;
      _passwordError = _password.text.isEmpty;
      _emailValidationError = null;

      if (_userType == 'student' && !_emailError) {
        if (!_isValidStudentEmail(_email.text)) {
          _emailValidationError =
              'Use your student email ending in .ac.za or .edu.za';
          _emailError = true;
        }
      } else if (_userType == 'institution' && !_emailError) {
        if (!_isValidInstitutionEmail(_email.text)) {
          _emailValidationError =
              'Use your institution email ending in .ac.za or .edu.za';
          _emailError = true;
        }
      }
    });

    if (!_emailError && !_passwordError) {
      final userService = UserRoleService();
      userService.userType = _userType;
      userService.role = _role;

      if (_userType == 'institution') {
        userService.institutionName = _institutionCode.text.trim();
        context.go('/institution/marketplace');
      } else if (_userType == 'buyer') {
        context.go('/buyer/marketplace');
      } else {
        context.go('/home');
      }
    }
  }

  void _clearEmailErrors() => setState(() {
        _emailError = false;
        _emailValidationError = null;
      });

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _institutionCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(role: _role, userType: _userType),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoleToggle(
                      selected: _userType,
                      onChanged: (t) {
                        setState(() {
                          _userType = t;
                          if (t == 'institution')
                            _role = 'institution';
                          else if (t == 'student')
                            _role = 'student';
                          else
                            _role = 'buyer';
                        });
                        _clearEmailErrors();
                      },
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: _C.dark,
                          letterSpacing: -0.8),
                    ),
                    const SizedBox(height: 18),
                    _label('Email Address'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _email,
                      hint: _userType == 'student'
                          ? 'studentnumber@university.ac.za'
                          : _userType == 'institution'
                              ? 'institution@domain.ac.za'
                              : 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      hasError: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _clearEmailErrors,
                    ),
                    if (_emailError)
                      _ErrorText(_emailValidationError ?? 'Email is required'),
                    const SizedBox(height: 14),
                    if (_userType == 'institution') ...[
                      _label('Institution Name'),
                      const SizedBox(height: 6),
                      _InputField(
                        controller: _institutionCode,
                        hint: 'e.g. University of Cape Town',
                        prefixIcon: Icons.business_outlined,
                        hasError: false,
                        onChanged: () {},
                      ),
                      const SizedBox(height: 14),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _label('Password'),
                        GestureDetector(
                          onTap: () => context.go('/forgot-password'),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                                fontSize: 12,
                                color: _C.primary,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _PasswordField(
                      controller: _password,
                      hint: 'Enter Password',
                      obscure: _obscure,
                      hasError: _passwordError,
                      onToggle: () => setState(() => _obscure = !_obscure),
                      onChanged: () => setState(() => _passwordError = false),
                    ),
                    if (_passwordError) const _ErrorText('Enter your password'),
                    const SizedBox(height: 10),
                    Row(children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                          activeColor: _C.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Keep me logged in',
                          style: TextStyle(fontSize: 12, color: _C.grey)),
                    ]),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: _C.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _login,
                        child: Text(
                          _userType == 'institution'
                              ? 'Log in as Institution'
                              : _userType == 'buyer'
                                  ? 'Log in as Buyer'
                                  : 'Log in as Student',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialBtn(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                            onTap: () {}),
                        const SizedBox(width: 12),
                        _SocialBtn(
                            icon: Icons.facebook_rounded,
                            label: 'Facebook',
                            onTap: () {}),
                        const SizedBox(width: 12),
                        _SocialBtn(
                            icon: Icons.apple_rounded,
                            label: 'Apple',
                            onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: _C.grey, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Register Now',
                                style: TextStyle(
                                    color: _C.primary,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _C.grey,
          letterSpacing: 0.2));
}

class _HeroSection extends StatelessWidget {
  final String role;
  final String userType;
  const _HeroSection({required this.role, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE30613), Color(0xFFB0000E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GudeLockup(logoSize: 30, textColor: Colors.white),
                        const Spacer(),
                        const Text(
                          'Welcome\nBack',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userType == 'institution'
                              ? 'Post jobs and find talented students.'
                              : userType == 'buyer'
                                  ? 'Access services from talented students.'
                                  : 'You\'re one step away from unlocking\nthe key to a better student life.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('🧑‍🎓', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const _RoleToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('student', '🎓 Student'),
          _tab('institution', '🏛️ Institution'),
          _tab('buyer', '🛒 Buyer'),
        ],
      ),
    );
  }

  Widget _tab(String role, String label) {
    final isSelected = selected == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF888888),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool hasError;
  final TextInputType keyboardType;
  final VoidCallback? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.hasError = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged?.call(),
      style: const TextStyle(fontSize: 14, color: _C.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFFBBBBBB), size: 20),
        filled: true,
        fillColor: hasError ? _C.errorRed.withOpacity(0.04) : _C.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? _C.errorRed : _C.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? _C.errorRed : _C.border)),
        // CHANGED: focus border is dark grey unless there's an error
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: hasError ? _C.errorRed : _C.focusBorder, width: 1.5)),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool hasError;
  final VoidCallback onToggle;
  final VoidCallback? onChanged;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    this.hasError = false,
    required this.onToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: (_) => onChanged?.call(),
      style: const TextStyle(fontSize: 14, color: _C.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: Color(0xFFBBBBBB), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFFBBBBBB),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: hasError ? _C.errorRed.withOpacity(0.04) : _C.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? _C.errorRed : _C.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? _C.errorRed : _C.border)),
        // CHANGED: focus border is dark grey unless there's an error
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: hasError ? _C.errorRed : _C.focusBorder, width: 1.5)),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        message,
        style: const TextStyle(fontSize: 11, color: _C.errorRed),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 1, color: const Color(0xFFF0F0F0))),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('or', style: TextStyle(color: _C.grey, fontSize: 12)),
      ),
      Expanded(child: Container(height: 1, color: const Color(0xFFF0F0F0))),
    ]);
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF444444)),
      ),
    );
  }
}
