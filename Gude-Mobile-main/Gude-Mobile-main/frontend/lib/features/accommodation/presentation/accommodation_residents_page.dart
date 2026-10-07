import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';

enum _BedStatusFilter { all, occupied, available }

enum _BedSort { residence, resident, funding }

class AccommodationResidentsPage extends StatefulWidget {
  const AccommodationResidentsPage({super.key});

  @override
  State<AccommodationResidentsPage> createState() =>
      _AccommodationResidentsPageState();
}

class _AccommodationResidentsPageState
    extends State<AccommodationResidentsPage> {
  final store = AccommodationPortalStore.instance;
  final _searchController = TextEditingController();
  String _query = '';
  _BedStatusFilter _status = _BedStatusFilter.all;
  _BedSort _sort = _BedSort.residence;
  AccommodationFundingType? _funding;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final records = _visibleBeds();
            final locations = store.availableBedsByResidence.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PortalPageHeader(
                          eyebrow: 'Residence operations',
                          title: 'Beds & residents',
                          subtitle:
                              'Manage placements, student funding and availability.',
                          icon: Icons.bed_rounded,
                          accent: AccommodationColors.green,
                          secondary: AccommodationColors.blue,
                          backRoute: '/accommodation/overview',
                        ),
                        const SizedBox(height: 14),
                        PortalSearchBar(
                          controller: _searchController,
                          hint: 'Search resident, school, residence or bed',
                          accent: AccommodationColors.green,
                          onChanged: (value) => setState(() => _query = value),
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
                              onTap: () => setState(
                                () => _status = _BedStatusFilter.all,
                              ),
                            ),
                            PortalSummaryItem(
                              value: '${store.occupiedBedCount}',
                              label: 'Occupied',
                              icon: Icons.person_rounded,
                              onTap: () => setState(
                                () => _status = _BedStatusFilter.occupied,
                              ),
                            ),
                            PortalSummaryItem(
                              value: '${store.availableBedCount}',
                              label: 'Available',
                              icon: Icons.bed_outlined,
                              onTap: () => setState(
                                () => _status = _BedStatusFilter.available,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _OccupancyStrip(
                          occupied: store.occupiedBedCount,
                          total: store.totalBedCount,
                          rate: store.occupancyRate,
                        ),
                        const SizedBox(height: 16),
                        _StatusSelector(
                          value: _status,
                          onChanged: (value) => setState(() => _status = value),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PortalDropdown<AccommodationFundingType?>(
                                value: _funding,
                                label: 'Funding',
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
                                onChanged: (value) =>
                                    setState(() => _funding = value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PortalDropdown<_BedSort>(
                                value: _sort,
                                label: 'Sort by',
                                items: const [
                                  DropdownMenuItem(
                                    value: _BedSort.residence,
                                    child: Text('Residence'),
                                  ),
                                  DropdownMenuItem(
                                    value: _BedSort.resident,
                                    child: Text('Resident'),
                                  ),
                                  DropdownMenuItem(
                                    value: _BedSort.funding,
                                    child: Text('Funding'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _sort = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FundingPanel(
                          breakdown: store.fundingBreakdown,
                          total: store.occupiedBedCount,
                          onSelected: (type) => setState(() {
                            _funding = type;
                            _status = _BedStatusFilter.occupied;
                          }),
                        ),
                        const SizedBox(height: 20),
                        PortalSectionTitle(
                          'Available locations',
                          trailing: '${locations.length} residences',
                        ),
                        const SizedBox(height: 10),
                        _LocationAvailability(
                          locations: locations,
                          onSelected: (location) {
                            final residence = location.split(',').first;
                            _searchController.text = residence;
                            setState(() {
                              _query = residence;
                              _status = _BedStatusFilter.available;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        PortalSectionTitle(
                          'Placement records',
                          trailing: '${records.length} shown',
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                if (records.isEmpty)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverToBoxAdapter(child: _EmptyRecords()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final bed = records[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _BedCard(
                            bed: bed,
                            onTap: () => bed.occupied
                                ? _showResident(bed)
                                : _assignResident(bed),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<AccommodationBed> _visibleBeds() {
    final query = _query.trim().toLowerCase();
    final values = store.beds.where((bed) {
      final student = bed.student;
      final statusMatches = switch (_status) {
        _BedStatusFilter.all => true,
        _BedStatusFilter.occupied => bed.occupied,
        _BedStatusFilter.available => !bed.occupied,
      };
      final fundingMatches =
          _funding == null || student?.fundingType == _funding;
      final queryMatches = query.isEmpty ||
          bed.residence.toLowerCase().contains(query) ||
          bed.city.toLowerCase().contains(query) ||
          bed.room.toLowerCase().contains(query) ||
          bed.bedNumber.toLowerCase().contains(query) ||
          (student?.name.toLowerCase().contains(query) ?? false) ||
          (student?.studentNumber.toLowerCase().contains(query) ?? false) ||
          (student?.institution.toLowerCase().contains(query) ?? false) ||
          (student?.fundingType.label.toLowerCase().contains(query) ?? false);
      return statusMatches && fundingMatches && queryMatches;
    }).toList();

    values.sort((a, b) => switch (_sort) {
          _BedSort.residence => '${a.residence}${a.bedNumber}'
              .compareTo('${b.residence}${b.bedNumber}'),
          _BedSort.resident =>
            (a.student?.name ?? 'ZZZ').compareTo(b.student?.name ?? 'ZZZ'),
          _BedSort.funding => (a.student?.fundingType.label ?? 'ZZZ')
              .compareTo(b.student?.fundingType.label ?? 'ZZZ'),
        });
    return values;
  }

  Future<void> _assignResident(AccommodationBed bed) async {
    final name = TextEditingController();
    final number = TextEditingController();
    final institution = TextEditingController();
    var funding = AccommodationFundingType.nsfas;
    final assigned = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Assign ${bed.residence} bed ${bed.bedNumber}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AccommodationColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: portalInputDecoration(
                    'Student name',
                    icon: Icons.person_outline_rounded,
                    accent: AccommodationColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: number,
                  decoration: portalInputDecoration(
                    'Student number',
                    icon: Icons.badge_outlined,
                    accent: AccommodationColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: institution,
                  textCapitalization: TextCapitalization.words,
                  decoration: portalInputDecoration(
                    'School or institution',
                    icon: Icons.school_outlined,
                    accent: AccommodationColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<AccommodationFundingType>(
                  initialValue: funding,
                  decoration: portalInputDecoration(
                    'Funding type',
                    icon: Icons.account_balance_wallet_outlined,
                    accent: AccommodationColors.green,
                  ),
                  items: AccommodationFundingType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => funding = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    if (name.text.trim().isEmpty ||
                        number.text.trim().isEmpty ||
                        institution.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Complete all student details.'),
                        ),
                      );
                      return;
                    }
                    store.assignStudentToBed(
                      bedId: bed.id,
                      name: name.text,
                      studentNumber: number.text,
                      institution: institution.text,
                      fundingType: funding,
                    );
                    Navigator.pop(sheetContext, true);
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Assign resident'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AccommodationColors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    name.dispose();
    number.dispose();
    institution.dispose();
    if (assigned == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resident assigned to bed.')),
      );
    }
  }

  void _showResident(AccommodationBed bed) {
    final student = bed.student!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE5F4EE),
                  foregroundColor: AccommodationColors.green,
                  child: Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    student.name,
                    style: const TextStyle(
                      color: AccommodationColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Student number', value: student.studentNumber),
            _DetailRow(label: 'Institution', value: student.institution),
            _DetailRow(label: 'Funding', value: student.fundingType.label),
            _DetailRow(label: 'Residence', value: bed.residence),
            _DetailRow(
              label: 'Placement',
              value: 'Room ${bed.room}, bed ${bed.bedNumber}',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                store.vacateBed(bed.id);
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bed marked as available.')),
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Vacate bed'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AccommodationColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccupancyStrip extends StatelessWidget {
  final int occupied;
  final int total;
  final int rate;

  const _OccupancyStrip({
    required this.occupied,
    required this.total,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF211815),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live occupancy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: total == 0 ? 0 : occupied / total,
                    color: AccommodationColors.green,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$rate%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final _BedStatusFilter value;
  final ValueChanged<_BedStatusFilter> onChanged;

  const _StatusSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_BedStatusFilter>(
      segments: const [
        ButtonSegment(value: _BedStatusFilter.all, label: Text('All')),
        ButtonSegment(
          value: _BedStatusFilter.occupied,
          label: Text('Occupied'),
        ),
        ButtonSegment(
          value: _BedStatusFilter.available,
          label: Text('Available'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (values) => onChanged(values.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : AccommodationColors.muted,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AccommodationColors.green
              : Colors.white,
        ),
      ),
    );
  }
}

class _PortalDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PortalDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AccommodationColors.line),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _FundingPanel extends StatelessWidget {
  final Map<AccommodationFundingType, int> breakdown;
  final int total;
  final ValueChanged<AccommodationFundingType> onSelected;

  const _FundingPanel({
    required this.breakdown,
    required this.total,
    required this.onSelected,
  });

  static const colors = {
    AccommodationFundingType.private: AccommodationColors.blue,
    AccommodationFundingType.bursary: AccommodationColors.orange,
    AccommodationFundingType.nsfas: AccommodationColors.green,
    AccommodationFundingType.other: AccommodationColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: CustomPaint(
              painter: _FundingChartPainter(
                values: breakdown,
                colors: colors,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'residents',
                      style: TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Funding mix',
                  style: TextStyle(
                    color: AccommodationColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (final type in AccommodationFundingType.values)
                  InkWell(
                    onTap: () => onSelected(type),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors[type],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              type.label,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          Text(
                            '${breakdown[type] ?? 0}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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

class _FundingChartPainter extends CustomPainter {
  final Map<AccommodationFundingType, int> values;
  final Map<AccommodationFundingType, Color> colors;

  const _FundingChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) return;
    final rect = Offset.zero & size;
    var start = -math.pi / 2;
    for (final type in AccommodationFundingType.values) {
      final sweep = (values[type] ?? 0) / total * math.pi * 2;
      canvas.drawArc(
        rect.deflate(8),
        start,
        sweep - 0.025,
        false,
        Paint()
          ..color = colors[type]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _FundingChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _LocationAvailability extends StatelessWidget {
  final List<MapEntry<String, int>> locations;
  final ValueChanged<String> onSelected;

  const _LocationAvailability({
    required this.locations,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: locations
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => onSelected(entry.key),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AccommodationColors.line),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AccommodationColors.green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${entry.value} beds',
                          style: const TextStyle(
                            color: AccommodationColors.green,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 19),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BedCard extends StatelessWidget {
  final AccommodationBed bed;
  final VoidCallback onTap;

  const _BedCard({required this.bed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final student = bed.student;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AccommodationColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bed.occupied
                      ? const Color(0xFFE5F4EE)
                      : const Color(0xFFFFEEE1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  bed.occupied ? Icons.person_rounded : Icons.bed_outlined,
                  color: bed.occupied
                      ? AccommodationColors.green
                      : AccommodationColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student?.name ?? 'Available bed ${bed.bedNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student == null
                          ? '${bed.residence} | Room ${bed.room}'
                          : '${student.institution} | ${student.fundingType.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    if (student != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${bed.residence} | Bed ${bed.bedNumber} | ${student.studentNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AccommodationColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                bed.occupied
                    ? Icons.chevron_right_rounded
                    : Icons.person_add_alt_1_rounded,
                color: bed.occupied
                    ? AccommodationColors.muted
                    : AccommodationColors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(color: AccommodationColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 34,
            color: AccommodationColors.muted,
          ),
          SizedBox(height: 8),
          Text('No bed or resident records match these filters.'),
        ],
      ),
    );
  }
}
