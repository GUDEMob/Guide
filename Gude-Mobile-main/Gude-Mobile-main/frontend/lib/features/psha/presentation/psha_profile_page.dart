import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';
import 'package:gude_app/services/user_role_service.dart';

class PshaProfilePage extends StatefulWidget {
  const PshaProfilePage({super.key});

  @override
  State<PshaProfilePage> createState() => _PshaProfilePageState();
}

class _PshaProfilePageState extends State<PshaProfilePage> {
  final store = PshaPortalStore.instance;
  bool memberAlerts = true;
  bool monthlyReport = true;
  bool securityAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            const PortalPageHeader(
              eyebrow: 'Association administration',
              title: 'PSHA Admin',
              subtitle: 'Manage access, reporting and network settings.',
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AccommodationColors.ink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.associationName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          store.adminEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_rounded,
                      color: AccommodationColors.green),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const PortalSectionTitle('Administrators'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AccommodationColors.line),
              ),
              child: Column(
                children: [
                  const _AdminRow(
                    name: 'PSHA Network Admin',
                    email: 'admin@psha.org.za',
                    role: 'Owner',
                  ),
                  const Divider(height: 1),
                  const _AdminRow(
                    name: 'Impact Reporting Team',
                    email: 'impact@psha.org.za',
                    role: 'Analyst',
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_add_alt_1_rounded,
                        color: AccommodationColors.primary),
                    title: const Text(
                      'Invite administrator',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showMessage('Administrator invite opened.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const PortalSectionTitle('Notifications & reports'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AccommodationColors.line),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Member change alerts'),
                    subtitle: const Text('Provider and building updates.'),
                    value: memberAlerts,
                    onChanged: (value) => setState(() => memberAlerts = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    title: const Text('Monthly impact report'),
                    subtitle: const Text('Email the aggregated PSHA report.'),
                    value: monthlyReport,
                    onChanged: (value) => setState(() => monthlyReport = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    title: const Text('Security alerts'),
                    subtitle: const Text('Notify owners about admin access.'),
                    value: securityAlerts,
                    onChanged: (value) =>
                        setState(() => securityAlerts = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const PortalSectionTitle('Workspace'),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                UserRoleService().organisationType = 'accommodation';
                context.go('/accommodation/overview');
              },
              icon: const Icon(Icons.apartment_outlined),
              label: const Text('Preview provider workspace'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AccommodationColors.ink,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AccommodationColors.line),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AccommodationColors.primary,
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(
                  color: AccommodationColors.primary.withValues(alpha: 0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out of PSHA Admin?'),
        content: const Text('You will return to the Gude login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              UserRoleService().clear();
              context.go('/login');
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const _AdminRow({
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AccommodationColors.blue.withValues(alpha: 0.1),
        child: Text(
          name.substring(0, 1),
          style: const TextStyle(
            color: AccommodationColors.blue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(email),
      trailing: Text(
        role,
        style: const TextStyle(
          color: AccommodationColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
