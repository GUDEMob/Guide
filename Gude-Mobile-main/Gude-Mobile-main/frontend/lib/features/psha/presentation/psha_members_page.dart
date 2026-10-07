import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';
import 'package:gude_app/features/psha/presentation/psha_ui.dart';

InputDecoration _pshaInputDecoration(String label, {IconData? icon}) {
  return portalInputDecoration(
    label,
    icon: icon,
    accent: PshaColors.primary,
    line: PshaColors.line,
  );
}

class PshaMembersPage extends StatefulWidget {
  final String? initialProviderId;

  const PshaMembersPage({super.key, this.initialProviderId});

  @override
  State<PshaMembersPage> createState() => _PshaMembersPageState();
}

class _PshaMembersPageState extends State<PshaMembersPage> {
  final store = PshaPortalStore.instance;
  final searchController = TextEditingController();
  String query = '';
  bool activeOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.initialProviderId == null) return;
      final index = store.providers.indexWhere(
        (provider) => provider.id == widget.initialProviderId,
      );
      if (index >= 0) _openProvider(store.providers[index]);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final number = NumberFormat.decimalPattern();
    return Scaffold(
      backgroundColor: PshaColors.canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMember,
        backgroundColor: PshaColors.primary,
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
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PortalPageHeader(
                          eyebrow: 'Network administration',
                          title: 'Members & buildings',
                          subtitle:
                              'Manage participating providers and their residence portfolio.',
                          icon: Icons.apartment_rounded,
                          accent: PshaColors.primary,
                          secondary: PshaColors.teal,
                          backRoute: '/psha/overview',
                        ),
                        const SizedBox(height: 16),
                        PortalSearchBar(
                          controller: searchController,
                          hint: 'Search providers, buildings or cities',
                          accent: PshaColors.primary,
                          onChanged: (value) => setState(() => query = value),
                        ),
                        const SizedBox(height: 14),
                        PortalSummaryBand(
                          colors: const [
                            PshaColors.deep,
                            PshaColors.primary,
                            PshaColors.teal,
                          ],
                          items: [
                            PortalSummaryItem(
                              value: '${store.activeProviderCount}',
                              label: 'Active',
                              icon: Icons.verified_rounded,
                              onTap: () => setState(() => activeOnly = true),
                            ),
                            PortalSummaryItem(
                              value: '${store.buildingCount}',
                              label: 'Buildings',
                              icon: Icons.apartment_rounded,
                              onTap: () => _showMetric(
                                '${store.buildingCount} buildings across the network.',
                              ),
                            ),
                            PortalSummaryItem(
                              value: number.format(store.studentCount),
                              label: 'Students',
                              icon: Icons.groups_2_rounded,
                              onTap: () => _showMetric(
                                '${number.format(store.studentCount)} students housed by members.',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.fromSeed(
                                    seedColor: PshaColors.primary,
                                  ),
                                ),
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
                if (visible.isEmpty)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverToBoxAdapter(child: _EmptyMemberState()),
                  )
                else
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

  void _showMetric(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _EmptyMemberState extends StatelessWidget {
  const _EmptyMemberState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PshaColors.line),
      ),
      child: const Column(
        children: [
          Icon(Icons.domain_disabled_rounded, color: PshaColors.muted),
          SizedBox(height: 8),
          Text(
            'No member providers match these filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PshaColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PshaColors.line),
        boxShadow: [
          BoxShadow(
            color: PshaColors.deep.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PshaColors.primary, PshaColors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  provider.name.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        color: PshaColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.contact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PshaColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: provider.active
                                ? PshaColors.primary
                                : PshaColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          provider.active ? 'Active member' : 'Inactive member',
                          style: TextStyle(
                            color: provider.active
                                ? PshaColors.primary
                                : PshaColors.muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: provider.active,
                activeTrackColor: PshaColors.primary,
                onChanged: onStatusChanged,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1, color: PshaColors.line),
          ),
          Row(
            children: [
              _MemberStat(
                value: '${provider.buildings.length}',
                label: 'Buildings',
                icon: Icons.apartment_rounded,
                color: PshaColors.primary,
              ),
              const _StatDivider(),
              _MemberStat(
                value: NumberFormat.compact().format(provider.studentCount),
                label: 'Students',
                icon: Icons.groups_2_rounded,
                color: PshaColors.blue,
              ),
              const _StatDivider(),
              _MemberStat(
                value: '${provider.opportunities}',
                label: 'Opportunities',
                icon: Icons.work_rounded,
                color: PshaColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 17,
                color: PshaColors.teal,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Student engagement',
                  style: TextStyle(
                    color: PshaColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${provider.engagement}%',
                style: const TextStyle(
                  color: PshaColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: provider.engagement / 100,
              minHeight: 6,
              color: PshaColors.primary,
              backgroundColor: PshaColors.primary.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 13),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.domain_outlined, size: 18),
            label: const Text('Manage buildings'),
            style: FilledButton.styleFrom(
              foregroundColor: PshaColors.deep,
              backgroundColor: PshaColors.primary.withValues(alpha: 0.1),
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
  final IconData icon;
  final Color color;

  const _MemberStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: PshaColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PshaColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 42,
      child: VerticalDivider(width: 14, color: PshaColors.line),
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
                      borderRadius: BorderRadius.circular(16),
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
                            color: PshaColors.primary,
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
                  backgroundColor: PshaColors.primary,
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
              decoration: _pshaInputDecoration('Building name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cityController,
              decoration: _pshaInputDecoration('City'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: studentsController,
              keyboardType: TextInputType.number,
              decoration: _pshaInputDecoration('Current students'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: _pshaInputDecoration('Capacity'),
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
          style: FilledButton.styleFrom(
            backgroundColor: PshaColors.primary,
            foregroundColor: Colors.white,
          ),
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
                decoration: _pshaInputDecoration('Provider name'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _pshaInputDecoration('Contact email'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: buildingController,
                decoration: _pshaInputDecoration('First building'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: cityController,
                decoration: _pshaInputDecoration('City'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: studentsController,
                keyboardType: TextInputType.number,
                decoration: _pshaInputDecoration('Current student count'),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Create member'),
                style: FilledButton.styleFrom(
                  backgroundColor: PshaColors.primary,
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
