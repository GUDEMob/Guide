// lib/features/auth/presentation/signup_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/widgets/gude_logo.dart';
import 'package:gude_app/services/user_role_service.dart';

class _C {
  static const primary = Color(0xFFE30613);
  static const primaryDark = Color(0xFFB0000E);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const border = Color(0xFFE8E8E8);
  static const focusBorder = Color(0xFF444444); // dark grey focus, NOT red
  static const inputBg = Color(0xFFFAFAFA);
}

// ─────────────────────────────────────────────────────────────
// SIGNUP PAGE
// ─────────────────────────────────────────────────────────────
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String _userType = ''; // 'student', 'institution', 'buyer'
  final _pageCtrl = PageController();

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _city = TextEditingController();
  final _customInstitution = TextEditingController();
  final _institutionName = TextEditingController();
  final _registrationNumber = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _selectedInstitution;
  bool _showCustomInput = false;
  String? _institutionDomain;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _city.dispose();
    _customInstitution.dispose();
    _institutionName.dispose();
    _registrationNumber.dispose();
    super.dispose();
  }

  void _selectUserType(String type) => setState(() => _userType = type);

  void _proceedToForm() {
    if (_userType.isEmpty) return;
    _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _goBack() => _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final userService = UserRoleService();
    userService.userType = _userType;
    userService.userName = _name.text.trim();

    if (_userType == 'institution') {
      userService.institutionName = _institutionName.text.trim();
      userService.role = 'institution';
      context.go('/institution/marketplace');
    } else if (_userType == 'buyer') {
      userService.role = 'buyer';
      context.go('/onboarding');
    } else {
      userService.role = 'student';
      context.go('/onboarding');
    }
  }

  static const List<Map<String, dynamic>> _institutions = [
    {'name': 'University of Cape Town (UCT)', 'domain': 'uct.ac.za'},
    {'name': 'University of the Witwatersrand (Wits)', 'domain': 'wits.ac.za'},
    {'name': 'Stellenbosch University (SU)', 'domain': 'sun.ac.za'},
    {'name': 'University of KwaZulu-Natal (UKZN)', 'domain': 'ukzn.ac.za'},
    {'name': 'University of Pretoria (UP)', 'domain': 'up.ac.za'},
    {'name': 'University of Johannesburg (UJ)', 'domain': 'uj.ac.za'},
    {'name': 'Tshwane University of Technology (TUT)', 'domain': 'tut.ac.za'},
    {
      'name': 'Cape Peninsula University of Technology (CPUT)',
      'domain': 'cput.ac.za'
    },
    {'name': 'Durban University of Technology (DUT)', 'domain': 'dut.ac.za'},
    {'name': 'Nelson Mandela University (NMU)', 'domain': 'mandela.ac.za'},
    {'name': 'University of the Western Cape (UWC)', 'domain': 'uwc.ac.za'},
    {'name': 'University of the Free State (UFS)', 'domain': 'ufs.ac.za'},
    {'name': 'Rhodes University (RU)', 'domain': 'ru.ac.za'},
    {'name': 'North-West University (NWU)', 'domain': 'nwu.ac.za'},
    {'name': 'University of Limpopo (UL)', 'domain': 'ul.ac.za'},
    {'name': 'University of Fort Hare (UFH)', 'domain': 'ufh.ac.za'},
    {'name': 'University of Venda (UniVen)', 'domain': 'univen.ac.za'},
    {'name': 'Walter Sisulu University (WSU)', 'domain': 'wsu.ac.za'},
    {'name': 'Vaal University of Technology (VUT)', 'domain': 'vut.ac.za'},
    {
      'name': 'Mangosuthu University of Technology (MUT)',
      'domain': 'mut.ac.za'
    },
    {'name': 'Central University of Technology (CUT)', 'domain': 'cut.ac.za'},
    {'name': 'Ekurhuleni East TVET College', 'domain': 'ekurhulenieast.edu.za'},
    {'name': 'Coastal KZN TVET College', 'domain': 'coastalkzn.edu.za'},
    {'name': 'College of Cape Town TVET', 'domain': 'cct.edu.za'},
    {'name': 'South West Gauteng TVET College', 'domain': 'swgc.edu.za'},
    {'name': 'Northlink TVET College', 'domain': 'northlink.edu.za'},
    {'name': 'Sedibeng TVET College', 'domain': 'sedibeng.edu.za'},
    {'name': 'Other (type below)', 'domain': ''},
  ];

  String? _getDomain() {
    if (_selectedInstitution == null) return null;
    return (_institutions.firstWhere(
      (i) => i['name'] == _selectedInstitution,
      orElse: () => {'domain': ''},
    ))['domain'] as String?;
  }

  String? _validateName(String? v) {
    if (v == null || v.isEmpty) return 'Full name is required';
    if (_userType == 'student' && v.trim().split(' ').length < 2)
      return 'Enter first and last name';
    return null;
  }

  String? _validateInstitutionName(String? v) {
    if (_userType == 'institution') {
      if (v == null || v.isEmpty) return 'Institution name is required';
    }
    return null;
  }

  String? _validateRegistrationNumber(String? v) {
    if (_userType == 'institution') {
      if (v == null || v.isEmpty) return 'Registration number is required';
      if (v.length < 5) return 'Please enter a valid registration number';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';

    if (_userType == 'student') {
      final domain = _getDomain();
      if (domain != null && domain.isNotEmpty) {
        if (!v.toLowerCase().endsWith('@$domain'))
          return 'Use your student email ending in @$domain';
        return null;
      }
      final re =
          RegExp(r'^[^@]+@[^@]+\.(ac\.za|edu\.za)$', caseSensitive: false);
      if (!re.hasMatch(v))
        return 'Use your official student email (.ac.za or .edu.za)';
    } else if (_userType == 'institution') {
      final re =
          RegExp(r'^[^@]+@[^@]+\.(ac\.za|edu\.za)$', caseSensitive: false);
      if (!re.hasMatch(v))
        return 'Use your institution email ending in .ac.za or .edu.za';
    } else {
      final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!re.hasMatch(v)) return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? _validateConfirm(String? v) =>
      v != _password.text ? 'Passwords do not match' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _RoleSelectionPage(
            selectedUserType: _userType,
            onSelectUserType: _selectUserType,
            onNext: _proceedToForm,
            onLogin: () => context.go('/login'),
          ),
          _FormPage(
            userType: _userType,
            formKey: _formKey,
            name: _name,
            email: _email,
            password: _password,
            confirmPassword: _confirmPassword,
            city: _city,
            customInstitution: _customInstitution,
            institutionName: _institutionName,
            registrationNumber: _registrationNumber,
            obscure: _obscure,
            obscureConfirm: _obscureConfirm,
            showCustomInput: _showCustomInput,
            selectedInstitution: _selectedInstitution,
            institutions: _institutions,
            getDomain: _getDomain,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            onToggleObscureConfirm: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onInstitutionChanged: (v) => setState(() {
              _selectedInstitution = v;
              _showCustomInput = v == 'Other (type below)';
              _email.clear();
            }),
            validateName: _validateName,
            validateInstitutionName: _validateInstitutionName,
            validateRegistrationNumber: _validateRegistrationNumber,
            validateEmail: _validateEmail,
            validatePassword: _validatePassword,
            validateConfirm: _validateConfirm,
            onBack: _goBack,
            onSubmit: _submit,
            onLogin: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ROLE SELECTION PAGE
// ─────────────────────────────────────────────────────────────
class _RoleSelectionPage extends StatelessWidget {
  final String selectedUserType;
  final void Function(String) onSelectUserType;
  final VoidCallback onNext, onLogin;

  const _RoleSelectionPage({
    required this.selectedUserType,
    required this.onSelectUserType,
    required this.onNext,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _SignupHero(
            title: 'Get Started',
            subtitle: "Join the Gude community today!",
            illustration: '🚀',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join as',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _C.dark,
                      letterSpacing: -0.8),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose how you want to use Gude',
                  style: TextStyle(fontSize: 13, color: _C.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        emoji: '🎓',
                        title: 'Sign up as\na Student',
                        subtitle:
                            'Sell skills, earn income,\nmanage your wallet',
                        selected: selectedUserType == 'student',
                        onTap: () => onSelectUserType('student'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _RoleCard(
                        emoji: '🏛️',
                        title: 'Sign up as\nan Institution',
                        subtitle:
                            'Post jobs, find talent,\nmanage applications',
                        selected: selectedUserType == 'institution',
                        onTap: () => onSelectUserType('institution'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        emoji: '🛒',
                        title: 'Sign up as\na Buyer',
                        subtitle: 'Hire students, buy\nservices & products',
                        selected: selectedUserType == 'buyer',
                        onTap: () => onSelectUserType('buyer'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Container()),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedUserType.isEmpty
                          ? const Color(0xFFDDDDDD)
                          : _C.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: selectedUserType.isEmpty ? 0 : 4,
                      shadowColor: _C.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: selectedUserType.isEmpty ? null : onNext,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedUserType.isEmpty
                              ? 'Select a role to continue'
                              : 'Continue as ${selectedUserType == 'student' ? 'Student' : selectedUserType == 'institution' ? 'Institution' : 'Buyer'}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        if (selectedUserType.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Divider(),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                      icon: Icons.apple_rounded, label: 'Apple', onTap: () {}),
                ]),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: onLogin,
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: _C.grey, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                                color: _C.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
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

// ─────────────────────────────────────────────────────────────
// FORM PAGE
// ─────────────────────────────────────────────────────────────
class _FormPage extends StatelessWidget {
  final String userType;
  final GlobalKey<FormState> formKey;
  final TextEditingController name,
      email,
      password,
      confirmPassword,
      city,
      customInstitution,
      institutionName,
      registrationNumber;
  final bool obscure, obscureConfirm, showCustomInput;
  final String? selectedInstitution;
  final List<Map<String, dynamic>> institutions;
  final String? Function() getDomain;
  final VoidCallback onToggleObscure,
      onToggleObscureConfirm,
      onBack,
      onSubmit,
      onLogin;
  final void Function(String?) onInstitutionChanged;
  final String? Function(String?) validateName,
      validateInstitutionName,
      validateRegistrationNumber,
      validateEmail,
      validatePassword,
      validateConfirm;

  const _FormPage({
    required this.userType,
    required this.formKey,
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.city,
    required this.customInstitution,
    required this.institutionName,
    required this.registrationNumber,
    required this.obscure,
    required this.obscureConfirm,
    required this.showCustomInput,
    required this.selectedInstitution,
    required this.institutions,
    required this.getDomain,
    required this.onToggleObscure,
    required this.onToggleObscureConfirm,
    required this.onBack,
    required this.onSubmit,
    required this.onLogin,
    required this.onInstitutionChanged,
    required this.validateName,
    required this.validateInstitutionName,
    required this.validateRegistrationNumber,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isStudent = userType == 'student';
    final isInstitution = userType == 'institution';
    final domain = getDomain();
    final emailHint = isStudent
        ? (domain != null && domain.isNotEmpty
            ? 'studentnumber@$domain'
            : 'studentnumber@university.ac.za')
        : isInstitution
            ? 'institution@domain.ac.za'
            : 'your@email.com';

    return SingleChildScrollView(
      child: Column(
        children: [
          _SignupHero(
            title: 'Almost there',
            subtitle: isStudent
                ? 'Create your student account to get started.'
                : isInstitution
                    ? 'Create your institution account to post jobs.'
                    : 'Create your buyer account to get started.',
            illustration: isStudent
                ? '🎓'
                : isInstitution
                    ? '🏛️'
                    : '🛒',
            showBack: true,
            onBack: onBack,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                    ),
                    child: Row(children: [
                      _tab('Log In', false, onLogin),
                      _tab('Sign Up', true, () {}),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  const Text('Signup',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: _C.dark,
                          letterSpacing: -0.8)),
                  const SizedBox(height: 20),

                  // Full Name
                  _label('Full Name *'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: name,
                    hint: isInstitution
                        ? 'Enter institution contact name'
                        : 'Enter full name',
                    icon: Icons.person_outline,
                    validator: validateName,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),

                  // Institution-specific fields
                  if (isInstitution) ...[
                    _label('Institution Name *'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: institutionName,
                      hint: 'e.g. University of Cape Town',
                      icon: Icons.business_outlined,
                      validator: validateInstitutionName,
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),
                    _label('Registration Number *'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: registrationNumber,
                      hint: 'e.g. 2024/123456',
                      icon: Icons.verified_outlined,
                      validator: validateRegistrationNumber,
                    ),
                    const SizedBox(height: 14),
                    _label('Email Address *'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: email,
                      hint: emailHint,
                      icon: Icons.email_outlined,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Student fields
                  if (isStudent) ...[
                    _label('University / TVET College *'),
                    const SizedBox(height: 6),
                    _DropdownField(
                      value: selectedInstitution,
                      hint: 'Select your institution',
                      icon: Icons.school_outlined,
                      items: institutions
                          .map((i) => DropdownMenuItem<String>(
                                value: i['name'] as String,
                                child: Text(
                                  i['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ))
                          .toList(),
                      validator: (v) =>
                          v == null ? 'Please select your institution' : null,
                      onChanged: onInstitutionChanged,
                    ),
                    if (showCustomInput) ...[
                      const SizedBox(height: 10),
                      _inputField(
                        controller: customInstitution,
                        hint: 'Type your institution name',
                        icon: Icons.edit_outlined,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please enter your institution'
                            : null,
                        capitalization: TextCapitalization.words,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _label('University or college email *'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: email,
                      hint: emailHint,
                      icon: Icons.email_outlined,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (domain != null && domain.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text('Must end in @$domain',
                            style:
                                const TextStyle(fontSize: 10, color: _C.grey)),
                      ),
                    ],
                    const SizedBox(height: 14),
                  ],

                  // Buyer fields
                  if (!isStudent && !isInstitution) ...[
                    _label('Email Address *'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: email,
                      hint: emailHint,
                      icon: Icons.email_outlined,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // City
                  _label('City *'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: city,
                    hint: 'Enter city',
                    icon: Icons.location_city_outlined,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'City is required' : null,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  _label('Create Password *'),
                  const SizedBox(height: 6),
                  _PasswordField(
                    controller: password,
                    hint: 'Enter Password',
                    obscure: obscure,
                    onToggle: onToggleObscure,
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 14),

                  // Confirm password
                  _label('Confirm Password *'),
                  const SizedBox(height: 6),
                  _PasswordField(
                    controller: confirmPassword,
                    hint: 'Confirm Password',
                    obscure: obscureConfirm,
                    onToggle: onToggleObscureConfirm,
                    validator: validateConfirm,
                  ),
                  const SizedBox(height: 28),

                  // Submit
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
                      onPressed: onSubmit,
                      child: Text(
                        isStudent
                            ? 'Create Student Account'
                            : isInstitution
                                ? 'Create Institution Account'
                                : 'Create Buyer Account',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _Divider(),
                  const SizedBox(height: 16),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  ]),

                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: onLogin,
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: _C.grey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Log In',
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
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _C.grey,
          letterSpacing: 0.2));

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? _C.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _C.primary : _C.grey,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: _C.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
        filled: true,
        fillColor: _C.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border)),
        // CHANGED: focus border is dark grey, not red
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.focusBorder, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED: SIGNUP HERO SECTION
// ─────────────────────────────────────────────────────────────
class _SignupHero extends StatelessWidget {
  final String title, subtitle, illustration;
  final bool showBack;
  final VoidCallback? onBack;

  const _SignupHero({
    required this.title,
    required this.subtitle,
    required this.illustration,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
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
            top: -25,
            right: -15,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          if (showBack) ...[
                            GestureDetector(
                              onTap: onBack,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.arrow_back_ios_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          GudeLockup(logoSize: 36, textColor: Colors.white),
                        ]),
                        const Spacer(),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
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
                    width: 80,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(illustration,
                          style: const TextStyle(fontSize: 42)),
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

// ─────────────────────────────────────────────────────────────
// ROLE CARD
// ─────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _C.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _C.primary : const Color(0xFFEEEEEE),
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _C.primary.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? _C.primary.withOpacity(0.12)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 22))),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? _C.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _C.primary : const Color(0xFFCCCCCC),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? _C.primary : _C.dark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: _C.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PASSWORD FIELD
// ─────────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: _C.dark),
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
        fillColor: _C.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border)),
        // CHANGED: focus border is dark grey, not red
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.focusBorder, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DROPDOWN FIELD
// ─────────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?)? validator;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: _C.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFBBBBBB), size: 20),
        filled: true,
        fillColor: _C.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border)),
        // CHANGED: focus border is dark grey, not red
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.focusBorder, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444))),
      ),
      items: items,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────
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
