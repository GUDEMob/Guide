import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';
import 'package:gude_app/features/psha/presentation/psha_ui.dart';
import 'package:intl/intl.dart';

enum _BedFilter { all, occupied, available }

enum _BedSort { location, student, funding }

class PshaOccupancyPage extends StatefulWidget {
  const PshaOccupancyPage({super.key});

  @override
  State<PshaOccupancyPage> createState() => _PshaOccupancyPageState();
}

class _PshaOccupancyPageState extends State<PshaOccupancyPage> {
  final store = PshaPortalStore.instance;
  final _searchController = TextEditingController();
  String _query = '';
  _BedFilter _status = _BedFilter.all;
  _BedSort _sort = _BedSort.location;
  PshaFundingType? _funding;

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
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final records = _visibleRecords();
            final locations = store.availableBedsByLocation.entries.toList()
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
                          eyebrow: 'Accommodation operations',
                          title: 'Beds & students',
                          subtitle:
                              'Track occupancy, funding and student placement across the network.',
                          icon: Icons.bed_rounded,
                          accent: PshaColors.primary,
                          secondary: PshaColors.teal,
                          backRoute: '/psha/overview',
                        ),
                        const SizedBox(height: 14),
                        PortalSearchBar(
                          controller: _searchController,
                          hint: 'Search student, institution, building or bed',
                          accent: PshaColors.primary,
                          onChanged: (value) => setState(() => _query = value),
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
                              value: number.format(store.totalBedCount),
                              label: 'Total beds',
                              icon: Icons.bed_rounded,
                              onTap: () =>
                                  setState(() => _status = _BedFilter.all),
                            ),
                            PortalSummaryItem(
                              value: number.format(store.occupiedBedCount),
                              label: 'Occupied',
                              icon: Icons.person_rounded,
                              onTap: () => setState(
                                () => _status = _BedFilter.occupied,
                              ),
                            ),
                            PortalSummaryItem(
                              value: number.format(store.availableBedCount),
                              label: 'Available',
                              icon: Icons.bed_outlined,
                              onTap: () => setState(
                                () => _status = _BedFilter.available,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _StatusRail(
                          selected: _status,
                          onChanged: (value) => setState(() => _status = value),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _FilterDropdown<PshaFundingType?>(
                                value: _funding,
                                label: 'Funding',
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
                                onChanged: (value) =>
                                    setState(() => _funding = value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _FilterDropdown<_BedSort>(
                                value: _sort,
                                label: 'Sort by',
                                items: const [
                                  DropdownMenuItem(
                                    value: _BedSort.location,
                                    child: Text('Location'),
                                  ),
                                  DropdownMenuItem(
                                    value: _BedSort.student,
                                    child: Text('Student'),
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
                          values: store.fundingBreakdown,
                          total: store.occupiedBedCount,
                          onSelect: (type) => setState(() {
                            _funding = type;
                            _status = _BedFilter.occupied;
                          }),
                        ),
                        const SizedBox(height: 20),
                        PortalSectionTitle(
                          'Available bed locations',
                          trailing: '${locations.length} locations',
                        ),
                        const SizedBox(height: 10),
                        _AvailableLocations(
                          locations: locations.take(5).toList(),
                          onSelect: (location) {
                            _searchController.text = location.split(',').first;
                            setState(() {
                              _query = _searchController.text;
                              _status = _BedFilter.available;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        PortalSectionTitle(
                          'Bed & student records',
                          trailing: '${number.format(records.length)} shown',
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                if (records.isEmpty)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverToBoxAdapter(child: _EmptyBedResults()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _BedRecordCard(
                          record: records[index],
                          onTap: () => records[index].occupied
                              ? _showStudentDetails(records[index])
                              : _showAssignStudent(records[index]),
                        ),
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

  List<PshaBedRecord> _visibleRecords() {
    final query = _query.trim().toLowerCase();
    final records = store.bedRecords.where((record) {
      final student = record.student;
      final matchesStatus = switch (_status) {
        _BedFilter.all => true,
        _BedFilter.occupied => record.occupied,
        _BedFilter.available => !record.occupied,
      };
      final matchesFunding = _funding == null ||
          (student != null && student.fundingType == _funding);
      final matchesQuery = query.isEmpty ||
          record.providerName.toLowerCase().contains(query) ||
          record.buildingName.toLowerCase().contains(query) ||
          record.city.toLowerCase().contains(query) ||
          record.bedNumber.toLowerCase().contains(query) ||
          (student != null &&
              (student.name.toLowerCase().contains(query) ||
                  student.studentNumber.toLowerCase().contains(query) ||
                  student.institution.toLowerCase().contains(query) ||
                  student.fundingType.label.toLowerCase().contains(query)));
      return matchesStatus && matchesFunding && matchesQuery;
    }).toList();

    records.sort((a, b) => switch (_sort) {
          _BedSort.location =>
            '${a.city}${a.buildingName}${a.bedNumber}'.compareTo(
              '${b.city}${b.buildingName}${b.bedNumber}',
            ),
          _BedSort.student =>
            (a.student?.name ?? 'zzzz').compareTo(b.student?.name ?? 'zzzz'),
          _BedSort.funding => (a.student?.fundingType.label ?? 'zzzz')
              .compareTo(b.student?.fundingType.label ?? 'zzzz'),
        });
    return records;
  }

  Future<void> _showAssignStudent(PshaBedRecord record) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _AssignStudentSheet(store: store, record: record),
    );
  }

  void _showStudentDetails(PshaBedRecord record) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) => _StudentDetailsSheet(
        record: record,
        onVacate: () {
          store.vacateBed(record.id);
          Navigator.pop(sheetContext);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${record.bedNumber} marked available.')),
          );
        },
      ),
    );
  }
}

class _StatusRail extends StatelessWidget {
  final _BedFilter selected;
  final ValueChanged<_BedFilter> onChanged;

  const _StatusRail({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _BedFilter.values.map((filter) {
        final isSelected = selected == filter;
        final label = switch (filter) {
          _BedFilter.all => 'All beds',
          _BedFilter.occupied => 'Occupied',
          _BedFilter.available => 'Available',
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: filter == _BedFilter.available ? 0 : 7,
            ),
            child: ChoiceChip(
              label: SizedBox(
                width: double.infinity,
                child: Text(label, textAlign: TextAlign.center),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              selectedColor: PshaColors.primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: PshaColors.line),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : PshaColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
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
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ),
      style: const TextStyle(
        color: PshaColors.ink,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FundingPanel extends StatelessWidget {
  final Map<PshaFundingType, int> values;
  final int total;
  final ValueChanged<PshaFundingType> onSelect;

  const _FundingPanel({
    required this.values,
    required this.total,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PshaColors.line),
        boxShadow: [
          BoxShadow(
            color: PshaColors.deep.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(112),
                  painter: _FundingDonutPainter(values: values, total: total),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.compact().format(total),
                      style: const TextStyle(
                        color: PshaColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'students',
                      style: TextStyle(color: PshaColors.muted, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Funding breakdown',
                  style: TextStyle(
                    color: PshaColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                for (final type in PshaFundingType.values)
                  _FundingLegendRow(
                    type: type,
                    value: values[type] ?? 0,
                    total: total,
                    onTap: () => onSelect(type),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FundingLegendRow extends StatelessWidget {
  final PshaFundingType type;
  final int value;
  final int total;
  final VoidCallback onTap;

  const _FundingLegendRow({
    required this.type,
    required this.value,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _fundingColor(type);
    final percentage = total == 0 ? 0 : ((value / total) * 100).round();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                type.label,
                style: const TextStyle(
                  color: PshaColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                color: PshaColors.ink,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundingDonutPainter extends CustomPainter {
  final Map<PshaFundingType, int> values;
  final int total;

  const _FundingDonutPainter({required this.values, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.butt;
    var start = -math.pi / 2;
    for (final type in PshaFundingType.values) {
      final value = values[type] ?? 0;
      final sweep = total == 0 ? 0.0 : (value / total) * math.pi * 2;
      paint.color = _fundingColor(type);
      canvas.drawArc(rect.deflate(12), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _FundingDonutPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.total != total;
}

class _AvailableLocations extends StatelessWidget {
  final List<MapEntry<String, int>> locations;
  final ValueChanged<String> onSelect;

  const _AvailableLocations({
    required this.locations,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PshaColors.line),
      ),
      child: Column(
        children: [
          for (var index = 0; index < locations.length; index++)
            InkWell(
              onTap: () => onSelect(locations[index].key),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: index < locations.length - 1
                      ? const Border(
                          bottom: BorderSide(color: PshaColors.line),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: PshaColors.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: PshaColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        locations[index].key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: PshaColors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${locations[index].value} beds',
                      style: const TextStyle(
                        color: PshaColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: PshaColors.muted,
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

class _BedRecordCard extends StatelessWidget {
  final PshaBedRecord record;
  final VoidCallback onTap;

  const _BedRecordCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final student = record.student;
    final color = student == null
        ? PshaColors.primary
        : _fundingColor(student.fundingType);
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
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  student == null ? Icons.bed_outlined : Icons.person_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student?.name ?? 'Available bed',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PshaColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _StatusPill(
                          label: student?.fundingType.label ?? 'Available',
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student == null
                          ? '${record.providerName}  |  ${record.buildingName}'
                          : '${student.studentNumber}  |  ${student.institution}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PshaColors.muted,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${record.buildingName}, ${record.city}  |  ${record.bedNumber}',
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
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: PshaColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AssignStudentSheet extends StatefulWidget {
  final PshaPortalStore store;
  final PshaBedRecord record;

  const _AssignStudentSheet({required this.store, required this.record});

  @override
  State<_AssignStudentSheet> createState() => _AssignStudentSheetState();
}

class _AssignStudentSheetState extends State<_AssignStudentSheet> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _institution = TextEditingController();
  PshaFundingType _funding = PshaFundingType.nsfas;

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _institution.dispose();
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
                'Assign student to bed',
                style: TextStyle(
                  color: PshaColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.record.bedNumber}  |  ${widget.record.buildingName}, ${widget.record.city}',
                style: const TextStyle(color: PshaColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _input('Student name', Icons.person_outline),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _number,
                decoration: _input('Student number', Icons.badge_outlined),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _institution,
                textCapitalization: TextCapitalization.words,
                decoration:
                    _input('School / institution', Icons.school_outlined),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<PshaFundingType>(
                initialValue: _funding,
                decoration: _input('Funding type', Icons.payments_outlined),
                items: PshaFundingType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _funding = value);
                },
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Assign student'),
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

  InputDecoration _input(String label, IconData icon) => portalInputDecoration(
        label,
        icon: icon,
        accent: PshaColors.primary,
        line: PshaColors.line,
      );

  void _submit() {
    if (_name.text.trim().isEmpty ||
        _number.text.trim().isEmpty ||
        _institution.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all student fields.')),
      );
      return;
    }
    widget.store.assignStudentToBed(
      bedId: widget.record.id,
      name: _name.text.trim(),
      studentNumber: _number.text.trim(),
      institution: _institution.text.trim(),
      fundingType: _funding,
    );
    Navigator.pop(context);
  }
}

class _StudentDetailsSheet extends StatelessWidget {
  final PshaBedRecord record;
  final VoidCallback onVacate;

  const _StudentDetailsSheet({required this.record, required this.onVacate});

  @override
  Widget build(BuildContext context) {
    final student = record.student!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.name,
              style: const TextStyle(
                color: PshaColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${record.bedNumber}  |  ${record.buildingName}, ${record.city}',
              style: const TextStyle(color: PshaColors.muted, fontSize: 11),
            ),
            const SizedBox(height: 16),
            _DetailRow(
                Icons.badge_outlined, 'Student number', student.studentNumber),
            _DetailRow(
                Icons.school_outlined, 'Institution', student.institution),
            _DetailRow(
                Icons.payments_outlined, 'Funding', student.fundingType.label),
            _DetailRow(
                Icons.business_outlined, 'Provider', record.providerName),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onVacate,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Vacate bed'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PshaColors.deep,
                side: const BorderSide(color: PshaColors.line),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: PshaColors.primary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: PshaColors.muted, fontSize: 11),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: PshaColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBedResults extends StatelessWidget {
  const _EmptyBedResults();

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
          Icon(Icons.search_off_rounded, color: PshaColors.muted),
          SizedBox(height: 7),
          Text(
            'No bed or student records match these filters.',
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

Color _fundingColor(PshaFundingType type) => switch (type) {
      PshaFundingType.selfFunded => PshaColors.blue,
      PshaFundingType.bursary => PshaColors.teal,
      PshaFundingType.nsfas => PshaColors.primary,
      PshaFundingType.other => PshaColors.amber,
    };
