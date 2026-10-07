import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';
import 'package:gude_app/features/psha/presentation/psha_ui.dart';

enum _DashboardSort { engagement, students, availability, name }

class PshaOverviewPage extends StatefulWidget {
  const PshaOverviewPage({super.key});

  @override
  State<PshaOverviewPage> createState() => _PshaOverviewPageState();
}

class _PshaOverviewPageState extends State<PshaOverviewPage> {
  final store = PshaPortalStore.instance;
  final _searchController = TextEditingController();
  String _query = '';
  PshaFundingType? _funding;
  _DashboardSort _sort = _DashboardSort.engagement;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final number = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: PshaColors.canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/psha/members'),
        backgroundColor: PshaColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add member'),
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final query = _query.trim().toLowerCase();
            final visibleProviders = store.providers.where((provider) {
              final providerBeds = store.bedRecords
                  .where((record) => record.providerId == provider.id)
                  .toList(growable: false);
              final matchesFunding = _funding == null ||
                  providerBeds.any(
                    (record) => record.student?.fundingType == _funding,
                  );
              final matchesSearch = query.isEmpty ||
                  provider.name.toLowerCase().contains(query) ||
                  provider.contact.toLowerCase().contains(query) ||
                  provider.buildings.any(
                    (building) =>
                        building.name.toLowerCase().contains(query) ||
                        building.city.toLowerCase().contains(query),
                  ) ||
                  providerBeds.any((record) {
                    final student = record.student;
                    return record.bedNumber.toLowerCase().contains(query) ||
                        (student != null &&
                            (student.name.toLowerCase().contains(query) ||
                                student.studentNumber
                                    .toLowerCase()
                                    .contains(query) ||
                                student.institution
                                    .toLowerCase()
                                    .contains(query) ||
                                student.fundingType.label
                                    .toLowerCase()
                                    .contains(query)));
                  }) ||
                  store.complaints.any(
                    (complaint) =>
                        complaint.providerName == provider.name &&
                        (complaint.title.toLowerCase().contains(query) ||
                            complaint.studentName
                                .toLowerCase()
                                .contains(query)),
                  );
              return matchesFunding && matchesSearch;
            }).toList();
            visibleProviders.sort((a, b) => switch (_sort) {
                  _DashboardSort.engagement =>
                    b.engagement.compareTo(a.engagement),
                  _DashboardSort.students => b.studentCount.compareTo(
                      a.studentCount,
                    ),
                  _DashboardSort.availability => store.bedRecords
                      .where((record) =>
                          record.providerId == b.id && !record.occupied)
                      .length
                      .compareTo(
                        store.bedRecords
                            .where((record) =>
                                record.providerId == a.id && !record.occupied)
                            .length,
                      ),
                  _DashboardSort.name => a.name.compareTo(b.name),
                });

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
              children: [
                PortalPageHeader(
                  eyebrow: 'PSHA network command centre',
                  title: 'National overview',
                  subtitle:
                      '${store.activeProviderCount} active member providers reporting through Gude',
                  icon: Icons.hub_rounded,
                  accent: PshaColors.primary,
                  secondary: PshaColors.teal,
                  backRoute: '/login',
                  action: IconButton.filledTonal(
                    tooltip: 'Network notifications',
                    onPressed: () => _showNotificationCenter(context, store),
                    icon: Badge(
                      isLabelVisible: store.openAlertCount > 0,
                      label: Text('${store.openAlertCount}'),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: PshaColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                PortalSearchBar(
                  controller: _searchController,
                  hint: 'Search accommodation, students or records',
                  accent: PshaColors.primary,
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 10),
                _DashboardControls(
                  funding: _funding,
                  sort: _sort,
                  onFundingChanged: (value) => setState(() => _funding = value),
                  onSortChanged: (value) => setState(() => _sort = value),
                ),
                const SizedBox(height: 14),
                PortalSummaryBand(
                  colors: const [
                    PshaColors.deep,
                    PshaColors.primary,
                    PshaColors.secondary,
                  ],
                  items: [
                    PortalSummaryItem(
                      value: number.format(store.totalBedCount),
                      label: 'Total beds',
                      icon: Icons.bed_rounded,
                      onTap: () => context.go('/psha/occupancy'),
                    ),
                    PortalSummaryItem(
                      value: number.format(store.occupiedBedCount),
                      label: 'Occupied',
                      icon: Icons.person_rounded,
                      onTap: () => _showNetworkReach(context, store),
                    ),
                    PortalSummaryItem(
                      value: number.format(store.availableBedCount),
                      label: 'Available',
                      icon: Icons.bed_outlined,
                      onTap: () => context.go('/psha/occupancy'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _OccupancyBand(
                  occupancy: store.averageOccupancy,
                  locations: store.availableBedsByLocation.length,
                  onTap: () => _showOccupancy(context, store),
                ),
                const SizedBox(height: 16),
                _ImpactBand(
                  store: store,
                  onTap: () => context.go('/psha/impact'),
                ),
                const SizedBox(height: 20),
                const PortalSectionTitle('Resident services'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _OperationsTile(
                        icon: Icons.support_agent_rounded,
                        value: '${store.openComplaintCount}',
                        label: 'Open complaints',
                        color: PshaColors.amber,
                        onTap: () => context.go(
                          '/psha/operations?tab=complaints',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OperationsTile(
                        icon: Icons.campaign_rounded,
                        value: '${store.announcements.length}',
                        label: 'Announcements',
                        color: PshaColors.teal,
                        onTap: () => context.go(
                          '/psha/operations?tab=announcements',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                PortalSectionTitle(
                  'Member performance',
                  trailing: '${visibleProviders.length} shown',
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: PshaColors.line),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < visibleProviders.length; i++)
                        _ProviderRow(
                          provider: visibleProviders[i],
                          showDivider: i < visibleProviders.length - 1,
                          onTap: () => context.go(
                            '/psha/members?provider=${Uri.encodeQueryComponent(visibleProviders[i].id)}',
                          ),
                        ),
                      if (visibleProviders.isEmpty) const _NoMemberResults(),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const PortalSectionTitle('Network snapshot'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SnapshotTile(
                        icon: Icons.work_outline_rounded,
                        value: number.format(store.opportunityCount),
                        label: 'Student opportunities',
                        color: PshaColors.amber,
                        onTap: () => context.go('/psha/impact'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SnapshotTile(
                        icon: Icons.insights_rounded,
                        value: '${store.averageEngagement}%',
                        label: 'Student engagement',
                        color: PshaColors.primary,
                        onTap: () => context.go('/psha/impact'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showNotificationCenter(
    BuildContext context,
    PshaPortalStore store,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _NetworkAlertsSheet(
        store: store,
        onReview: (alert) {
          store.markAlertReviewed(alert.id);
          Navigator.pop(sheetContext);
          context.go(
            '/psha/members?provider=${Uri.encodeQueryComponent(alert.providerId)}',
          );
        },
      ),
    );
  }

  void _showNetworkReach(BuildContext context, PshaPortalStore store) {
    _showBreakdown(context, store, _NetworkBreakdownMode.students);
  }

  void _showOccupancy(BuildContext context, PshaPortalStore store) {
    _showBreakdown(context, store, _NetworkBreakdownMode.occupancy);
  }

  void _showBreakdown(
    BuildContext context,
    PshaPortalStore store,
    _NetworkBreakdownMode mode,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _NetworkBreakdownSheet(
        store: store,
        mode: mode,
        onProviderTap: (providerId) {
          Navigator.pop(sheetContext);
          context.go(
            '/psha/members?provider=${Uri.encodeQueryComponent(providerId)}',
          );
        },
        onViewAll: () {
          Navigator.pop(sheetContext);
          context.go('/psha/members');
        },
      ),
    );
  }
}

class _DashboardControls extends StatelessWidget {
  final PshaFundingType? funding;
  final _DashboardSort sort;
  final ValueChanged<PshaFundingType?> onFundingChanged;
  final ValueChanged<_DashboardSort> onSortChanged;

  const _DashboardControls({
    required this.funding,
    required this.sort,
    required this.onFundingChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<PshaFundingType?>(
            initialValue: funding,
            isExpanded: true,
            decoration: _decoration('Funding', Icons.payments_outlined),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All funding'),
              ),
              ...PshaFundingType.values.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.label),
                ),
              ),
            ],
            onChanged: onFundingChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<_DashboardSort>(
            initialValue: sort,
            isExpanded: true,
            decoration: _decoration('Sort', Icons.sort_rounded),
            items: const [
              DropdownMenuItem(
                value: _DashboardSort.engagement,
                child: Text('Engagement'),
              ),
              DropdownMenuItem(
                value: _DashboardSort.students,
                child: Text('Students'),
              ),
              DropdownMenuItem(
                value: _DashboardSort.availability,
                child: Text('Availability'),
              ),
              DropdownMenuItem(
                value: _DashboardSort.name,
                child: Text('Name'),
              ),
            ],
            onChanged: (value) {
              if (value != null) onSortChanged(value);
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PshaColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PshaColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PshaColors.primary, width: 1.4),
        ),
      );
}

class _OccupancyBand extends StatelessWidget {
  final int occupancy;
  final int locations;
  final VoidCallback onTap;

  const _OccupancyBand({
    required this.occupancy,
    required this.locations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PshaColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PshaColors.primary, PshaColors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bed_rounded, color: Colors.white),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accommodation registry',
                      style: TextStyle(
                        color: PshaColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$occupancy% occupied  |  Availability across $locations locations',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PshaColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancy / 100,
                        minHeight: 5,
                        color: PshaColors.primary,
                        backgroundColor:
                            PshaColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: PshaColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperationsTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OperationsTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PshaColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: PshaColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: PshaColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PshaColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoMemberResults extends StatelessWidget {
  const _NoMemberResults();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: PshaColors.muted),
          SizedBox(height: 6),
          Text(
            'No members or buildings match your search.',
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

class _ImpactBand extends StatelessWidget {
  final PshaPortalStore store;
  final VoidCallback onTap;

  const _ImpactBand({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: PshaColors.deep,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.public_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student success network',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Live, aggregated member impact across participating residences.',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SnapshotTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: PshaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 21),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: color.withValues(alpha: 0.75),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AccommodationColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final PshaMemberProvider provider;
  final bool showDivider;
  final VoidCallback onTap;

  const _ProviderRow({
    required this.provider,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: AccommodationColors.line),
                )
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AccommodationColors.blue.withValues(alpha: 0.1),
              child: Text(
                provider.name.substring(0, 1),
                style: const TextStyle(
                  color: AccommodationColors.blue,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AccommodationColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${provider.buildings.length} buildings  |  ${NumberFormat.decimalPattern().format(provider.studentCount)} students',
                    style: const TextStyle(
                      color: AccommodationColors.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
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
            const SizedBox(width: 3),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AccommodationColors.muted),
          ],
        ),
      ),
    );
  }
}

enum _NetworkBreakdownMode { students, occupancy }

class _NetworkBreakdownSheet extends StatelessWidget {
  final PshaPortalStore store;
  final _NetworkBreakdownMode mode;
  final ValueChanged<String> onProviderTap;
  final VoidCallback onViewAll;

  const _NetworkBreakdownSheet({
    required this.store,
    required this.mode,
    required this.onProviderTap,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final showingStudents = mode == _NetworkBreakdownMode.students;
    final title = showingStudents ? 'Students housed' : 'Network occupancy';
    final subtitle = showingStudents
        ? '${NumberFormat.decimalPattern().format(store.studentCount)} students across ${store.buildingCount} buildings'
        : '${store.averageOccupancy}% average occupancy across the network';

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AccommodationColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: store.providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final provider = store.providers[index];
                    final occupancy = _providerOccupancy(provider);
                    final value = showingStudents
                        ? NumberFormat.decimalPattern()
                            .format(provider.studentCount)
                        : '$occupancy%';
                    final progress = showingStudents
                        ? provider.studentCount / store.studentCount
                        : occupancy / 100;
                    return _NetworkBreakdownRow(
                      provider: provider,
                      value: value,
                      progress: progress,
                      color: showingStudents
                          ? AccommodationColors.blue
                          : PshaColors.primary,
                      onTap: () => onProviderTap(provider.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onViewAll,
                icon: const Icon(Icons.business_outlined),
                label: const Text('Manage all members'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AccommodationColors.ink,
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AccommodationColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkBreakdownRow extends StatelessWidget {
  final PshaMemberProvider provider;
  final String value;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const _NetworkBreakdownRow({
    required this.provider,
    required this.value,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: AccommodationColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AccommodationColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Text(
                      provider.name.substring(0, 1),
                      style: TextStyle(
                        color: color,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AccommodationColors.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${provider.buildings.length} buildings',
                          style: const TextStyle(
                            color: AccommodationColors.muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AccommodationColors.muted,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 6,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkAlertsSheet extends StatelessWidget {
  final PshaPortalStore store;
  final ValueChanged<PshaNetworkAlert> onReview;

  const _NetworkAlertsSheet({
    required this.store,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.72,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final alerts =
                  store.alerts.where((alert) => !alert.reviewed).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Network notifications',
                    style: TextStyle(
                      color: AccommodationColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alerts.isEmpty
                        ? 'No member updates need attention.'
                        : '${alerts.length} member updates need your attention.',
                    style: const TextStyle(
                      color: AccommodationColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: alerts.isEmpty
                        ? const _NoNetworkAlerts()
                        : ListView.separated(
                            itemCount: alerts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 9),
                            itemBuilder: (context, index) => _NetworkAlertRow(
                              alert: alerts[index],
                              onReview: () => onReview(alerts[index]),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NetworkAlertRow extends StatelessWidget {
  final PshaNetworkAlert alert;
  final VoidCallback onReview;

  const _NetworkAlertRow({required this.alert, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final needsAttention = alert.type == PshaAlertType.attention;
    final color = needsAttention ? PshaColors.amber : PshaColors.teal;
    final icon = needsAttention
        ? Icons.warning_amber_rounded
        : Icons.description_outlined;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AccommodationColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      alert.detail,
                      style: const TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                alert.age,
                style: const TextStyle(
                  color: AccommodationColors.muted,
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Review member'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoNetworkAlerts extends StatelessWidget {
  const _NoNetworkAlerts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE8F5EF),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: PshaColors.primary,
              size: 30,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'All caught up',
            style: TextStyle(
              color: AccommodationColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'There are no network updates to review.',
            style: TextStyle(
              color: AccommodationColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

int _providerOccupancy(PshaMemberProvider provider) {
  if (provider.buildings.isEmpty) return 0;
  return (provider.buildings.fold(
            0,
            (total, building) => total + building.occupancy,
          ) /
          provider.buildings.length)
      .round();
}
