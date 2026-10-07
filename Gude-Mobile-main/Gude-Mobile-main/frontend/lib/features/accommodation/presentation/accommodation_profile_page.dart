import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/services/user_role_service.dart';

class AccommodationProfilePage extends StatefulWidget {
  const AccommodationProfilePage({super.key});

  @override
  State<AccommodationProfilePage> createState() =>
      _AccommodationProfilePageState();
}

class _AccommodationProfilePageState extends State<AccommodationProfilePage> {
  final store = AccommodationPortalStore.instance;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController contactController;
  late final TextEditingController cityController;
  bool editing = false;
  bool requestAlerts = true;
  bool weeklyReport = true;

  @override
  void initState() {
    super.initState();
    store.hydrateProviderName();
    nameController = TextEditingController(text: store.providerName);
    emailController = TextEditingController(text: store.contactEmail);
    contactController = TextEditingController(text: store.contactPerson);
    cityController = TextEditingController(text: store.city);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
          children: [
            PortalPageHeader(
              eyebrow: 'Provider account',
              title: 'Profile',
              subtitle: 'Manage your organisation and connected residences.',
              icon: Icons.apartment_rounded,
              accent: AccommodationColors.green,
              secondary: AccommodationColors.blue,
              backRoute: '/accommodation/overview',
              action: IconButton.filledTonal(
                tooltip: editing ? 'Save profile' : 'Edit profile',
                onPressed: _toggleEditing,
                icon: Icon(editing ? Icons.save_outlined : Icons.edit_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AccommodationColors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ProviderSummary(store: store),
            const SizedBox(height: 14),
            PortalSummaryBand(
              colors: const [
                AccommodationColors.green,
                AccommodationColors.blue,
              ],
              items: [
                PortalSummaryItem(
                  value: '${store.residences.length}',
                  label: 'Residences',
                  icon: Icons.apartment_rounded,
                  onTap: () => _showMessage(
                    '${store.residences.length} residences connected.',
                  ),
                ),
                PortalSummaryItem(
                  value: '${store.residentCount}',
                  label: 'Residents',
                  icon: Icons.groups_2_rounded,
                  onTap: () => _showMessage(
                    '${store.residentCount} residents currently reached.',
                  ),
                ),
                PortalSummaryItem(
                  value: '${store.engagementRate}%',
                  label: 'Engagement',
                  icon: Icons.insights_rounded,
                  onTap: () => _showMessage(
                    'Monthly engagement is ${store.engagementRate}%.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const PortalSectionTitle('Organisation details'),
            const SizedBox(height: 10),
            _DetailsPanel(
              editing: editing,
              nameController: nameController,
              emailController: emailController,
              contactController: contactController,
              cityController: cityController,
            ),
            const SizedBox(height: 20),
            PortalSectionTitle(
              'Residences',
              trailing: '${store.residences.length} connected',
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < store.residences.length; i++) ...[
              _ResidenceCard(
                name: store.residences[i],
                residents: store.beds
                    .where(
                      (bed) =>
                          bed.residence == store.residences[i] && bed.occupied,
                    )
                    .length,
                status: i == 0 ? 'Primary residence' : 'Active',
                onSettings: () => _showMessage(
                  '${store.residences[i]} settings selected.',
                ),
              ),
              if (i < store.residences.length - 1) const SizedBox(height: 9),
            ],
            const SizedBox(height: 20),
            const PortalSectionTitle('Notifications'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AccommodationColors.line),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Resident request alerts'),
                    subtitle: const Text('Notify staff about new requests.'),
                    value: requestAlerts,
                    onChanged: (value) => setState(() => requestAlerts = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    title: const Text('Weekly impact report'),
                    subtitle:
                        const Text('Receive engagement and opportunity data.'),
                    value: weeklyReport,
                    onChanged: (value) => setState(() => weeklyReport = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const PortalSectionTitle('Workspace'),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _switchToUniversity,
              icon: const Icon(Icons.account_balance_outlined),
              label: const Text('Switch to university workspace'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AccommodationColors.ink,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AccommodationColors.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEditing() {
    if (!editing) {
      setState(() => editing = true);
      return;
    }
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      _showMessage('Organisation name and email are required.');
      return;
    }
    store.updateProfile(
      name: name,
      email: email,
      contact: contactController.text.trim(),
      location: cityController.text.trim(),
    );
    setState(() => editing = false);
    _showMessage('Provider profile updated.');
  }

  void _switchToUniversity() {
    UserRoleService().organisationType = 'university';
    context.go('/institution/marketplace');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
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

class _ProviderSummary extends StatelessWidget {
  final AccommodationPortalStore store;

  const _ProviderSummary({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AccommodationColors.green,
            AccommodationColors.blue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AccommodationColors.blue.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.apartment_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.providerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Verified accommodation provider',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 17),
                SizedBox(width: 5),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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

class _ResidenceCard extends StatelessWidget {
  final String name;
  final int residents;
  final String status;
  final VoidCallback onSettings;

  const _ResidenceCard({
    required this.name,
    required this.residents,
    required this.status,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
        boxShadow: [
          BoxShadow(
            color: AccommodationColors.ink.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AccommodationColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: AccommodationColors.blue,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AccommodationColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$residents residents  |  $status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AccommodationColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Residence settings',
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined, size: 19),
            style: IconButton.styleFrom(
              foregroundColor: AccommodationColors.green,
              backgroundColor: AccommodationColors.green.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final bool editing;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController contactController;
  final TextEditingController cityController;

  const _DetailsPanel({
    required this.editing,
    required this.nameController,
    required this.emailController,
    required this.contactController,
    required this.cityController,
  });

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return Column(
        children: [
          TextField(
            controller: nameController,
            decoration: portalInputDecoration(
              'Organisation name',
              icon: Icons.business_outlined,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: portalInputDecoration(
              'Contact email',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: contactController,
            decoration: portalInputDecoration(
              'Contact person',
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: cityController,
            decoration: portalInputDecoration(
              'City',
              icon: Icons.location_on_outlined,
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        children: [
          _InfoRow(
              Icons.business_outlined, 'Organisation', nameController.text),
          const Divider(height: 1),
          _InfoRow(Icons.email_outlined, 'Email', emailController.text),
          const Divider(height: 1),
          _InfoRow(Icons.badge_outlined, 'Contact', contactController.text),
          const Divider(height: 1),
          _InfoRow(Icons.location_on_outlined, 'City', cityController.text),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AccommodationColors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AccommodationColors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AccommodationColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AccommodationColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
