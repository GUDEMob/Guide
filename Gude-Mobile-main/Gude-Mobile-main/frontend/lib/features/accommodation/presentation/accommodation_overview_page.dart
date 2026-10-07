import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';

enum _AccommodationDashboardSort { residence, resident, funding }

class AccommodationOverviewPage extends StatefulWidget {
  const AccommodationOverviewPage({super.key});

  @override
  State<AccommodationOverviewPage> createState() =>
      _AccommodationOverviewPageState();
}

class _AccommodationOverviewPageState extends State<AccommodationOverviewPage> {
  final store = AccommodationPortalStore.instance;
  final _searchController = TextEditingController();
  String _query = '';
  AccommodationFundingType? _funding;
  _AccommodationDashboardSort _sort = _AccommodationDashboardSort.residence;

  @override
  void initState() {
    super.initState();
    store.hydrateProviderName();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/accommodation/opportunities'),
        backgroundColor: AccommodationColors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post job'),
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final query = _query.trim().toLowerCase();
            final openRequests = store.requests.where((request) {
              if (request.resolved) return false;
              return query.isEmpty ||
                  request.title.toLowerCase().contains(query) ||
                  request.category.toLowerCase().contains(query) ||
                  request.residence.toLowerCase().contains(query) ||
                  request.student.toLowerCase().contains(query);
            }).toList();
            final matchingBeds = store.beds.where((bed) {
              final student = bed.student;
              final fundingMatches =
                  _funding == null || student?.fundingType == _funding;
              final queryMatches = query.isEmpty ||
                  bed.residence.toLowerCase().contains(query) ||
                  bed.city.toLowerCase().contains(query) ||
                  bed.bedNumber.toLowerCase().contains(query) ||
                  (student?.name.toLowerCase().contains(query) ?? false) ||
                  (student?.studentNumber.toLowerCase().contains(query) ??
                      false) ||
                  (student?.institution.toLowerCase().contains(query) ??
                      false) ||
                  (student?.fundingType.label.toLowerCase().contains(query) ??
                      false);
              return fundingMatches && queryMatches;
            }).toList()
              ..sort((a, b) => switch (_sort) {
                    _AccommodationDashboardSort.residence =>
                      '${a.residence}${a.bedNumber}'
                          .compareTo('${b.residence}${b.bedNumber}'),
                    _AccommodationDashboardSort.resident =>
                      (a.student?.name ?? 'ZZZ')
                          .compareTo(b.student?.name ?? 'ZZZ'),
                    _AccommodationDashboardSort.funding =>
                      (a.student?.fundingType.label ?? 'ZZZ')
                          .compareTo(b.student?.fundingType.label ?? 'ZZZ'),
                  });
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
              children: [
                PortalPageHeader(
                  eyebrow: 'Residence experience',
                  title: store.providerName,
                  subtitle:
                      '${store.residences.length} residences connected to Gude',
                  icon: Icons.apartment_rounded,
                  accent: AccommodationColors.green,
                  secondary: AccommodationColors.blue,
                  backRoute: '/login',
                  action: IconButton.filledTonal(
                    tooltip: 'Notifications',
                    onPressed: () => _showRequestCenter(
                      title: 'Notifications',
                      subtitle: 'Resident requests that need your attention.',
                    ),
                    icon: Badge(
                      label: Text('${store.openRequestCount}'),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AccommodationColors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                PortalSearchBar(
                  controller: _searchController,
                  hint: 'Search residents, beds, schools or complaints',
                  accent: AccommodationColors.green,
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 10),
                _DashboardFilters(
                  funding: _funding,
                  sort: _sort,
                  onFundingChanged: (value) => setState(() => _funding = value),
                  onSortChanged: (value) => setState(() => _sort = value),
                ),
                const SizedBox(height: 14),
                PortalSummaryBand(
                  colors: const [
                    AccommodationColors.green,
                    AccommodationColors.blue,
                  ],
                  items: [
                    PortalSummaryItem(
                      value: '${store.totalBedCount}',
                      label: 'Total beds',
                      icon: Icons.bed_rounded,
                      onTap: () => context.go('/accommodation/residents'),
                    ),
                    PortalSummaryItem(
                      value: '${store.occupiedBedCount}',
                      label: 'Occupied',
                      icon: Icons.person_rounded,
                      onTap: () => context.go('/accommodation/residents'),
                    ),
                    PortalSummaryItem(
                      value: '${store.availableBedCount}',
                      label: 'Available',
                      icon: Icons.bed_outlined,
                      onTap: () => context.go('/accommodation/residents'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _OccupancySnapshot(
                  store: store,
                  onOpenRegistry: _showResidentReach,
                ),
                if (query.isNotEmpty || _funding != null) ...[
                  const SizedBox(height: 20),
                  PortalSectionTitle(
                    'Search results',
                    trailing: '${matchingBeds.length} records',
                  ),
                  const SizedBox(height: 10),
                  if (matchingBeds.isEmpty)
                    const _EmptyDashboardResults()
                  else
                    for (final bed in matchingBeds.take(4))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DashboardBedResult(
                          bed: bed,
                          onTap: () => context.go('/accommodation/residents'),
                        ),
                      ),
                ],
                const SizedBox(height: 16),
                _ResidencePulseCard(
                  engagement: store.engagementRate,
                  opportunities: store.openOpportunityCount,
                  onCommunityTap: () => context.go('/accommodation/community'),
                  onOpportunitiesTap: () =>
                      context.go('/accommodation/opportunities'),
                ),
                const SizedBox(height: 20),
                const PortalSectionTitle('Quick actions'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.bed_outlined,
                        label: 'Manage beds',
                        color: AccommodationColors.green,
                        onTap: () => context.go('/accommodation/residents'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.support_agent_outlined,
                        label: 'Complaints',
                        color: AccommodationColors.primary,
                        onTap: () =>
                            context.go('/accommodation/service?tab=complaints'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.campaign_outlined,
                        label: 'Announcement',
                        color: AccommodationColors.blue,
                        onTap: () => context
                            .go('/accommodation/service?tab=announcements'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_business_outlined,
                        label: 'Post a job',
                        color: AccommodationColors.orange,
                        onTap: () => context.go('/accommodation/opportunities'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                PortalSectionTitle(
                  'Resident requests',
                  trailing: '${openRequests.length} open',
                ),
                const SizedBox(height: 10),
                for (final request in openRequests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _RequestRow(
                      request: request,
                      onResolve: () {
                        store.resolveRequest(request.id);
                        _showMessage('Request marked as resolved.');
                      },
                    ),
                  ),
                if (openRequests.isEmpty) const _EmptyRequestSearch(),
                const SizedBox(height: 12),
                const PortalSectionTitle('Latest community activity'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AccommodationColors.line),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0;
                          i < store.communityPosts.take(3).length;
                          i++)
                        _ActivityRow(
                          post: store.communityPosts[i],
                          showDivider: i < 2,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showResidentReach() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _ResidentReachSheet(
        store: store,
        onOpenRegistry: () {
          Navigator.pop(sheetContext);
          context.go('/accommodation/residents');
        },
      ),
    );
  }

  void _showRequestCenter({
    String title = 'Resident requests',
    String subtitle = 'Review and resolve open support requests.',
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _RequestCenterSheet(
        store: store,
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}

class _DashboardFilters extends StatelessWidget {
  final AccommodationFundingType? funding;
  final _AccommodationDashboardSort sort;
  final ValueChanged<AccommodationFundingType?> onFundingChanged;
  final ValueChanged<_AccommodationDashboardSort> onSortChanged;

  const _DashboardFilters({
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
          child: DropdownButtonFormField<AccommodationFundingType?>(
            initialValue: funding,
            isExpanded: true,
            decoration: _filterDecoration('Funding'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All funding'),
              ),
              ...AccommodationFundingType.values.map(
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
          child: DropdownButtonFormField<_AccommodationDashboardSort>(
            initialValue: sort,
            isExpanded: true,
            decoration: _filterDecoration('Sort records'),
            items: const [
              DropdownMenuItem(
                value: _AccommodationDashboardSort.residence,
                child: Text('Residence'),
              ),
              DropdownMenuItem(
                value: _AccommodationDashboardSort.resident,
                child: Text('Resident'),
              ),
              DropdownMenuItem(
                value: _AccommodationDashboardSort.funding,
                child: Text('Funding'),
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

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AccommodationColors.line),
      ),
    );
  }
}

class _OccupancySnapshot extends StatelessWidget {
  final AccommodationPortalStore store;
  final VoidCallback onOpenRegistry;

  const _OccupancySnapshot({
    required this.store,
    required this.onOpenRegistry,
  });

  @override
  Widget build(BuildContext context) {
    final availableResidences = store.availableBedsByResidence.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Material(
      color: const Color(0xFF211815),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpenRegistry,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.hotel_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bed occupancy',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${store.occupiedBedCount} of ${store.totalBedCount} beds occupied',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${store.occupancyRate}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: store.totalBedCount == 0
                      ? 0
                      : store.occupiedBedCount / store.totalBedCount,
                  minHeight: 7,
                  color: AccommodationColors.green,
                  backgroundColor: Colors.white24,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SnapshotStat(
                      value: '${store.availableBedCount}',
                      label: 'available beds',
                      color: AccommodationColors.green,
                    ),
                  ),
                  Expanded(
                    child: _SnapshotStat(
                      value:
                          '${store.fundingBreakdown[AccommodationFundingType.nsfas] ?? 0}',
                      label: 'NSFAS residents',
                      color: AccommodationColors.blue,
                    ),
                  ),
                  Expanded(
                    child: _SnapshotStat(
                      value: '${availableResidences.length}',
                      label: 'residences with space',
                      color: AccommodationColors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnapshotStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SnapshotStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 9),
        ),
      ],
    );
  }
}

class _DashboardBedResult extends StatelessWidget {
  final AccommodationBed bed;
  final VoidCallback onTap;

  const _DashboardBedResult({required this.bed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final student = bed.student;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AccommodationColors.line),
          ),
          child: Row(
            children: [
              Icon(
                bed.occupied ? Icons.person_rounded : Icons.bed_outlined,
                color: bed.occupied
                    ? AccommodationColors.green
                    : AccommodationColors.orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student?.name ?? 'Available bed ${bed.bedNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      student == null
                          ? '${bed.residence} | Room ${bed.room}'
                          : '${student.institution} | ${student.fundingType.label}',
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
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDashboardResults extends StatelessWidget {
  const _EmptyDashboardResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_off_rounded, color: AccommodationColors.muted),
          SizedBox(width: 10),
          Expanded(child: Text('No accommodation records match your search.')),
        ],
      ),
    );
  }
}

class _ResidencePulseCard extends StatelessWidget {
  final int engagement;
  final int opportunities;
  final VoidCallback onCommunityTap;
  final VoidCallback onOpportunitiesTap;

  const _ResidencePulseCard({
    required this.engagement,
    required this.opportunities,
    required this.onCommunityTap,
    required this.onOpportunitiesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AccommodationColors.line),
        boxShadow: [
          BoxShadow(
            color: AccommodationColors.ink.withValues(alpha: 0.04),
            blurRadius: 14,
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AccommodationColors.green,
                      AccommodationColors.blue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.query_stats_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Residence pulse',
                      style: TextStyle(
                        color: AccommodationColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Live resident engagement and opportunities',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PulseAction(
                  icon: Icons.insights_rounded,
                  label: 'Engagement',
                  value: '$engagement%',
                  color: AccommodationColors.green,
                  onTap: onCommunityTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PulseAction(
                  icon: Icons.work_rounded,
                  label: 'Open jobs',
                  value: '$opportunities',
                  color: AccommodationColors.orange,
                  onTap: onOpportunitiesTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _PulseAction({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRequestSearch extends StatelessWidget {
  const _EmptyRequestSearch();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: AccommodationColors.muted),
          SizedBox(height: 6),
          Text(
            'No open requests match your search.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AccommodationColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentReachSheet extends StatelessWidget {
  final AccommodationPortalStore store;
  final VoidCallback onOpenRegistry;

  const _ResidentReachSheet({
    required this.store,
    required this.onOpenRegistry,
  });

  @override
  Widget build(BuildContext context) {
    final residenceCount = store.residences.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Occupancy by residence',
              style: TextStyle(
                color: AccommodationColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${store.occupiedBedCount} of ${store.totalBedCount} beds occupied across $residenceCount residences',
              style: const TextStyle(
                color: AccommodationColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < residenceCount; index++) ...[
              _ResidenceReachRow(
                name: store.residences[index],
                residents: store.beds
                    .where(
                      (bed) =>
                          bed.residence == store.residences[index] &&
                          bed.occupied,
                    )
                    .length,
                capacity: store.beds
                    .where(
                      (bed) => bed.residence == store.residences[index],
                    )
                    .length,
              ),
              if (index < residenceCount - 1) const SizedBox(height: 14),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onOpenRegistry,
              icon: const Icon(Icons.bed_outlined),
              label: const Text('Open bed registry'),
              style: FilledButton.styleFrom(
                backgroundColor: AccommodationColors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
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
}

class _ResidenceReachRow extends StatelessWidget {
  final String name;
  final int residents;
  final int capacity;

  const _ResidenceReachRow({
    required this.name,
    required this.residents,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$residents / $capacity occupied',
              style: const TextStyle(
                color: AccommodationColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: capacity == 0 ? 0 : residents / capacity,
            minHeight: 7,
            backgroundColor: AccommodationColors.blue.withValues(alpha: 0.1),
            color: AccommodationColors.blue,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${capacity - residents} beds available',
          style: const TextStyle(
            color: AccommodationColors.green,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RequestCenterSheet extends StatelessWidget {
  final AccommodationPortalStore store;
  final String title;
  final String subtitle;

  const _RequestCenterSheet({
    required this.store,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.78,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final requests =
                  store.requests.where((request) => !request.resolved).toList();
              return Column(
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
                    child: requests.isEmpty
                        ? const _AllRequestsResolved()
                        : ListView.separated(
                            itemCount: requests.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 9),
                            itemBuilder: (context, index) {
                              final request = requests[index];
                              return _RequestCenterRow(
                                request: request,
                                onResolve: () {
                                  store.resolveRequest(request.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Request marked as resolved.'),
                                    ),
                                  );
                                },
                              );
                            },
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

class _RequestCenterRow extends StatelessWidget {
  final ResidentRequest request;
  final VoidCallback onResolve;

  const _RequestCenterRow({
    required this.request,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (request.priority) {
      RequestPriority.high => AccommodationColors.primary,
      RequestPriority.medium => AccommodationColors.orange,
      RequestPriority.low => AccommodationColors.blue,
    };
    final priority = switch (request.priority) {
      RequestPriority.high => 'High priority',
      RequestPriority.medium => 'Medium priority',
      RequestPriority.low => 'Low priority',
    };

    return Container(
      padding: const EdgeInsets.all(12),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.support_agent_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.student}  |  ${request.residence}',
                      style: const TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Mark resolved',
                onPressed: onResolve,
                icon: const Icon(Icons.check_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _RequestTag(text: request.category, color: color),
              _RequestTag(text: priority, color: color),
              _RequestTag(
                text: request.age,
                color: AccommodationColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestTag extends StatelessWidget {
  final String text;
  final Color color;

  const _RequestTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AllRequestsResolved extends StatelessWidget {
  const _AllRequestsResolved();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE8F5EF),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AccommodationColors.green,
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
            'There are no open resident requests.',
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AccommodationColors.ink,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AccommodationColors.line),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final ResidentRequest request;
  final VoidCallback onResolve;

  const _RequestRow({required this.request, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final color = switch (request.priority) {
      RequestPriority.high => AccommodationColors.primary,
      RequestPriority.medium => AccommodationColors.orange,
      RequestPriority.low => AccommodationColors.blue,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent_rounded, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AccommodationColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${request.category}  |  ${request.age}',
                  style: const TextStyle(
                    color: AccommodationColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Resolve request',
            onPressed: onResolve,
            icon: const Icon(Icons.check_circle_outline_rounded),
            color: AccommodationColors.green,
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final CommunityPost post;
  final bool showDivider;

  const _ActivityRow({required this.post, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final icon = switch (post.type) {
      CommunityPostType.announcement => Icons.campaign_outlined,
      CommunityPostType.event => Icons.event_outlined,
      CommunityPostType.survey => Icons.poll_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AccommodationColors.line))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: AccommodationColors.blue, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AccommodationColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${post.audience}  |  ${post.published}',
                  style: const TextStyle(
                    color: AccommodationColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${post.engagement}',
            style: const TextStyle(
              color: AccommodationColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
