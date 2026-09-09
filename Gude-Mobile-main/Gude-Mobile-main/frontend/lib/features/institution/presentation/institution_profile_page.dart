import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/user_role_service.dart';

class _C {
  static const primary = Color(0xFFE50914);
  static const orange = Color(0xFFFF6B00);
  static const amber = Color(0xFFFFB000);
  static const ink = Color(0xFF211815);
  static const muted = Color(0xFF80665C);
  static const line = Color(0xFFF0D8CE);
  static const canvas = Color(0xFFFFF8F3);
  static const success = Color(0xFF16875D);
  static const danger = Color(0xFFDC2626);
}

class InstitutionProfilePage extends StatefulWidget {
  const InstitutionProfilePage({super.key});

  @override
  State<InstitutionProfilePage> createState() => _InstitutionProfilePageState();
}

class _InstitutionProfilePageState extends State<InstitutionProfilePage> {
  final userService = UserRoleService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isEditing = false;
  bool _applicationAlerts = true;
  bool _weeklyDigest = true;
  bool _publicProfile = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = userService.institutionName.trim().isEmpty
        ? 'Braam Institution'
        : userService.institutionName.trim();
    _emailController.text = 'institution@domain.ac.za';
    _regNumberController.text = 'REG2024/12345';
    _contactController.text = 'Admissions Office';
    _cityController.text = 'Johannesburg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _regNumberController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final institutionName = _nameController.text.trim().isEmpty
        ? 'Your Institution'
        : _nameController.text.trim();

    return Scaffold(
      backgroundColor: _C.canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: _C.ink,
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              onPressed: () => context.go('/institution/marketplace'),
            ),
            title: const Text(
              'Institution Profile',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: _isEditing ? 'Save profile' : 'Edit profile',
                icon: Icon(
                  _isEditing ? Icons.save_outlined : Icons.edit_outlined,
                  color: _C.primary,
                ),
                onPressed: _toggleEdit,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(
                    name: institutionName,
                    email: _emailController.text,
                    regNumber: _regNumberController.text,
                    isEditing: _isEditing,
                    nameController: _nameController,
                    emailController: _emailController,
                    regNumberController: _regNumberController,
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      _StatTile(
                        icon: Icons.work_outline_rounded,
                        value: '12',
                        label: 'Posts',
                        color: _C.primary,
                      ),
                      SizedBox(width: 10),
                      _StatTile(
                        icon: Icons.people_outline_rounded,
                        value: '126',
                        label: 'Applicants',
                        color: _C.success,
                      ),
                      SizedBox(width: 10),
                      _StatTile(
                        icon: Icons.campaign_outlined,
                        value: '3',
                        label: 'Alerts',
                        color: _C.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Verified Information'),
                  const _Panel(
                    children: [
                      _InfoRow(
                        icon: Icons.verified_outlined,
                        label: 'Email verified',
                        value: 'Active',
                        color: _C.success,
                      ),
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Registration verified',
                        value: 'Approved',
                        color: _C.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Organisation Details'),
                  _Panel(
                    children: [
                      _EditableRow(
                        editing: _isEditing,
                        icon: Icons.badge_outlined,
                        label: 'Contact person',
                        controller: _contactController,
                      ),
                      _EditableRow(
                        editing: _isEditing,
                        icon: Icons.location_on_outlined,
                        label: 'City',
                        controller: _cityController,
                      ),
                      const _InfoRow(
                        icon: Icons.category_outlined,
                        label: 'Account type',
                        value: 'Institution',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Preferences'),
                  _Panel(
                    children: [
                      _SwitchRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Application alerts',
                        subtitle: 'Notify me when students apply.',
                        value: _applicationAlerts,
                        onChanged: (value) =>
                            setState(() => _applicationAlerts = value),
                      ),
                      _SwitchRow(
                        icon: Icons.summarize_outlined,
                        title: 'Weekly digest',
                        subtitle: 'Receive a weekly hiring summary.',
                        value: _weeklyDigest,
                        onChanged: (value) =>
                            setState(() => _weeklyDigest = value),
                      ),
                      _SwitchRow(
                        icon: Icons.public_outlined,
                        title: 'Public partner profile',
                        subtitle: 'Show your institution in opportunity lists.',
                        value: _publicProfile,
                        onChanged: (value) =>
                            setState(() => _publicProfile = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Account'),
                  _Panel(
                    children: [
                      _ActionRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Security settings',
                        value: 'Manage',
                        onTap: () =>
                            _showSnack('Security settings coming next.'),
                      ),
                      _ActionRow(
                        icon: Icons.support_agent_outlined,
                        label: 'Institution support',
                        value: 'Contact',
                        onTap: () => _showSnack('Support channel coming next.'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.danger,
                      side:
                          BorderSide(color: _C.danger.withValues(alpha: 0.25)),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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

  void _toggleEdit() {
    if (_isEditing) {
      setState(() {
        userService.institutionName = _nameController.text.trim();
        _isEditing = false;
      });
      _showSnack('Profile updated.');
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLogoutDialog() {
    final router = GoRouter.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to role selection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              UserRoleService().clear();
              Future.microtask(() => router.go('/signup'));
            },
            style: FilledButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String name;
  final String email;
  final String regNumber;
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController regNumberController;

  const _HeroCard({
    required this.name,
    required this.email,
    required this.regNumber,
    required this.isEditing,
    required this.nameController,
    required this.emailController,
    required this.regNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.primary, _C.orange, _C.amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _C.orange.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 14),
          if (isEditing)
            _HeroField(controller: nameController, hint: 'Institution name')
          else
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          const SizedBox(height: 8),
          if (isEditing) ...[
            _HeroField(controller: emailController, hint: 'Email'),
            const SizedBox(height: 8),
            _HeroField(
              controller: regNumberController,
              hint: 'Registration number',
            ),
          ] else ...[
            Text(
              email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              regNumber,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _HeroField({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.4),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: _C.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _C.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: _C.ink,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final List<Widget> children;

  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.line),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color = _C.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _C.ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final bool editing;
  final IconData icon;
  final String label;
  final TextEditingController controller;

  const _EditableRow({
    required this.editing,
    required this.icon,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: _C.muted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: editing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: _C.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.text,
                        style: const TextStyle(
                          color: _C.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
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

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      activeThumbColor: _C.primary,
      secondary: Icon(icon, color: _C.orange),
      title: Text(
        title,
        style: const TextStyle(
          color: _C.ink,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: _C.muted, fontSize: 11),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: _C.muted),
      title: Text(
        label,
        style: const TextStyle(
          color: _C.ink,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _C.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: _C.muted),
        ],
      ),
    );
  }
}
