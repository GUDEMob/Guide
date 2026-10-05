import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';

class PshaMembersPage extends StatefulWidget {
  const PshaMembersPage({super.key});

  @override
  State<PshaMembersPage> createState() => _PshaMembersPageState();
}

class _PshaMembersPageState extends State<PshaMembersPage> {
  final store = PshaPortalStore.instance;
  final searchController = TextEditingController();
  String query = '';
  bool activeOnly = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMember,
        backgroundColor: AccommodationColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add member'),
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final normalized = query.trim().toLowerCase();
            final visible = store.providers.where((provider) {
              final matchesStatus = !activeOnly || provider.active;
              final matchesQuery = normalized.isEmpty ||
                  provider.name.toLowerCase().contains(normalized) ||
                  provider.buildings.any((building) =>
                      building.name.toLowerCase().contains(normalized) ||
                      building.city.toLowerCase().contains(normalized));
              return matchesStatus && matchesQuery;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PortalPageHeader(
                          eyebrow: 'Network administration',
                          title: 'Members & buildings',
                          subtitle:
                              'Manage participating providers and their residence portfolio.',
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: searchController,
                          onChanged: (value) => setState(() => query = value),
                          decoration: portalInputDecoration(
                            'Search providers, buildings or cities',
                            icon: Icons.search_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment(
                                    value: false,
                                    label: Text('All members'),
                                  ),
                                  ButtonSegment(
                                    value: true,
                                    label: Text('Active'),
                                  ),
                                ],
                                selected: {activeOnly},
                                showSelectedIcon: false,
                                onSelectionChanged: (value) => setState(
                                  () => activeOnly = value.first,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        PortalSectionTitle(
                          'Member providers',
                          trailing: '${visible.length} shown',
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MemberCard(
                          provider: visible[index],
                          onOpen: () => _openProvider(visible[index]),
                          onStatusChanged: (value) => store.setProviderActive(
                            visible[index].id,
                            value,
                          ),
                        ),
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openProvider(PshaMemberProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _ProviderDetailSheet(
        store: store,
        providerId: provider.id,
      ),
    );
  }

  Future<void> _openAddMember() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _AddMemberSheet(store: store),
    );
    if (added == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member provider added to PSHA.')),
      );
    }
  }
}

class _MemberCard extends StatelessWidget {
  final PshaMemberProvider provider;
  final VoidCallback onOpen;
  final ValueChanged<bool> onStatusChanged;

  const _MemberCard({
    required this.provider,
    required this.onOpen,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    AccommodationColors.primary.withValues(alpha: 0.1),
                child: Text(
                  provider.name.substring(0, 1),
                  style: const TextStyle(
                    color: AccommodationColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      provider.contact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: provider.active,
                activeTrackColor: AccommodationColors.green,
                onChanged: onStatusChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MemberStat(
                value: '${provider.buildings.length}',
                label: 'Buildings',
              ),
              _MemberStat(
                value: NumberFormat.compact().format(provider.studentCount),
                label: 'Students',
              ),
              _MemberStat(
                value: '${provider.engagement}%',
                label: 'Engagement',
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.domain_outlined, size: 18),
            label: const Text('Manage buildings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AccommodationColors.ink,
              minimumSize: const Size.fromHeight(42),
              side: const BorderSide(color: AccommodationColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberStat extends StatelessWidget {
  final String value;
  final String label;

  const _MemberStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AccommodationColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AccommodationColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderDetailSheet extends StatelessWidget {
  final PshaPortalStore store;
  final String providerId;

  const _ProviderDetailSheet({
    required this.store,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final provider =
            store.providers.firstWhere((item) => item.id == providerId);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              Text(
                provider.name,
                style: const TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${provider.buildings.length} registered buildings  |  ${NumberFormat.decimalPattern().format(provider.studentCount)} students',
                style: const TextStyle(
                  color: AccommodationColors.muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 18),
              const PortalSectionTitle('Building portfolio'),
              const SizedBox(height: 10),
              for (final building in provider.buildings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AccommodationColors.canvas,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AccommodationColors.line),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.apartment_rounded,
                            color: AccommodationColors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                building.name,
                                style: const TextStyle(
                                  color: AccommodationColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${building.city}  |  ${building.students}/${building.capacity} students',
                                style: const TextStyle(
                                  color: AccommodationColors.muted,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${building.occupancy}%',
                          style: const TextStyle(
                            color: AccommodationColors.green,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _AddBuildingDialog(
                    store: store,
                    providerId: provider.id,
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add building'),
                style: FilledButton.styleFrom(
                  backgroundColor: AccommodationColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddBuildingDialog extends StatefulWidget {
  final PshaPortalStore store;
  final String providerId;

  const _AddBuildingDialog({
    required this.store,
    required this.providerId,
  });

  @override
  State<_AddBuildingDialog> createState() => _AddBuildingDialogState();
}

class _AddBuildingDialogState extends State<_AddBuildingDialog> {
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final studentsController = TextEditingController();
  final capacityController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    studentsController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add building'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: portalInputDecoration('Building name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cityController,
              decoration: portalInputDecoration('City'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: studentsController,
              keyboardType: TextInputType.number,
              decoration: portalInputDecoration('Current students'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: portalInputDecoration('Capacity'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    final students = int.tryParse(studentsController.text.trim());
    final capacity = int.tryParse(capacityController.text.trim());
    if (nameController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        students == null ||
        capacity == null ||
        capacity < students) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Check the building details and capacity.')),
      );
      return;
    }
    widget.store.addBuilding(
      providerId: widget.providerId,
      name: nameController.text.trim(),
      city: cityController.text.trim(),
      students: students,
      capacity: capacity,
    );
    Navigator.pop(context);
  }
}

class _AddMemberSheet extends StatefulWidget {
  final PshaPortalStore store;

  const _AddMemberSheet({required this.store});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final buildingController = TextEditingController();
  final cityController = TextEditingController();
  final studentsController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    buildingController.dispose();
    cityController.dispose();
    studentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add PSHA member',
                style: TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameController,
                decoration: portalInputDecoration('Provider name'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: portalInputDecoration('Contact email'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: buildingController,
                decoration: portalInputDecoration('First building'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: cityController,
                decoration: portalInputDecoration('City'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: studentsController,
                keyboardType: TextInputType.number,
                decoration: portalInputDecoration('Current student count'),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Create member'),
                style: FilledButton.styleFrom(
                  backgroundColor: AccommodationColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final students = int.tryParse(studentsController.text.trim());
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        buildingController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        students == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all member details.')),
      );
      return;
    }
    widget.store.addProvider(
      name: nameController.text.trim(),
      contact: emailController.text.trim(),
      buildingName: buildingController.text.trim(),
      city: cityController.text.trim(),
      students: students,
    );
    Navigator.pop(context, true);
  }
}
