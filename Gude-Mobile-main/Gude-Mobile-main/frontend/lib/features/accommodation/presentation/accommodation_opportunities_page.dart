import 'package:flutter/material.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';

class AccommodationOpportunitiesPage extends StatefulWidget {
  const AccommodationOpportunitiesPage({super.key});

  @override
  State<AccommodationOpportunitiesPage> createState() =>
      _AccommodationOpportunitiesPageState();
}

class _AccommodationOpportunitiesPageState
    extends State<AccommodationOpportunitiesPage> {
  final store = AccommodationPortalStore.instance;
  bool showOpenOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        backgroundColor: AccommodationColors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post opportunity'),
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final visible = showOpenOnly
                ? store.opportunities.where((item) => item.isOpen).toList()
                : store.opportunities;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PortalPageHeader(
                          eyebrow: 'Student work marketplace',
                          title: 'Opportunities',
                          subtitle:
                              'Create legitimate residence work and track student interest.',
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryTile(
                                value: '${store.openOpportunityCount}',
                                label: 'Open roles',
                                color: AccommodationColors.orange,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SummaryTile(
                                value: '${store.totalApplicants}',
                                label: 'Applicants',
                                color: AccommodationColors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('Open')),
                            ButtonSegment(value: false, label: Text('All')),
                          ],
                          selected: {showOpenOnly},
                          onSelectionChanged: (selection) =>
                              setState(() => showOpenOnly = selection.first),
                          showSelectedIcon: false,
                        ),
                        const SizedBox(height: 18),
                        PortalSectionTitle(
                          'Residence opportunities',
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
                        child: _OpportunityCard(
                          opportunity: visible[index],
                          onApplicants: () => _showApplicants(visible[index]),
                          onStatusChanged: (value) => store.setOpportunityOpen(
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

  Future<void> _openCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _CreateOpportunitySheet(store: store),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opportunity published to residents.')),
      );
    }
  }

  void _showApplicants(ResidenceOpportunity opportunity) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) => _ApplicantsSheet(opportunity: opportunity),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 9),
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
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final ResidenceOpportunity opportunity;
  final VoidCallback onApplicants;
  final ValueChanged<bool> onStatusChanged;

  const _OpportunityCard({
    required this.opportunity,
    required this.onApplicants,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opportunity.residence,
                      style: const TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: opportunity.isOpen,
                activeTrackColor: AccommodationColors.green,
                onChanged: onStatusChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(Icons.payments_outlined, opportunity.pay),
              _InfoPill(Icons.schedule_outlined, opportunity.schedule),
              _InfoPill(
                Icons.visibility_outlined,
                '${opportunity.views} views',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  opportunity.isOpen ? 'Accepting applications' : 'Closed',
                  style: TextStyle(
                    color: opportunity.isOpen
                        ? AccommodationColors.green
                        : AccommodationColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onApplicants,
                icon: const Icon(Icons.people_outline_rounded, size: 18),
                label: Text('${opportunity.applicants} applicants'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AccommodationColors.canvas,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AccommodationColors.muted),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AccommodationColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateOpportunitySheet extends StatefulWidget {
  final AccommodationPortalStore store;

  const _CreateOpportunitySheet({required this.store});

  @override
  State<_CreateOpportunitySheet> createState() =>
      _CreateOpportunitySheetState();
}

class _CreateOpportunitySheetState extends State<_CreateOpportunitySheet> {
  final titleController = TextEditingController();
  final payController = TextEditingController();
  final scheduleController = TextEditingController();
  String residence = 'All residences';

  @override
  void dispose() {
    titleController.dispose();
    payController.dispose();
    scheduleController.dispose();
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
                'Post a residence opportunity',
                style: TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                decoration: portalInputDecoration(
                  'Opportunity title',
                  icon: Icons.work_outline_rounded,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: payController,
                decoration: portalInputDecoration(
                  'Pay or stipend',
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: scheduleController,
                decoration: portalInputDecoration(
                  'Schedule',
                  icon: Icons.schedule_outlined,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: residence,
                decoration: portalInputDecoration(
                  'Residence',
                  icon: Icons.apartment_outlined,
                ),
                items: ['All residences', ...widget.store.residences]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => residence = value ?? residence),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.publish_rounded),
                label: const Text('Publish opportunity'),
                style: FilledButton.styleFrom(
                  backgroundColor: AccommodationColors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _publish() {
    final title = titleController.text.trim();
    final pay = payController.text.trim();
    final schedule = scheduleController.text.trim();
    if (title.isEmpty || pay.isEmpty || schedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all opportunity fields.')),
      );
      return;
    }
    widget.store.createOpportunity(
      title: title,
      pay: pay,
      schedule: schedule,
      residence: residence,
    );
    Navigator.pop(context, true);
  }
}

class _ApplicantsSheet extends StatelessWidget {
  final ResidenceOpportunity opportunity;

  const _ApplicantsSheet({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    const applicants = [
      ('Amina K.', 'Statistics student', 'Verified experience'),
      ('Keanu N.', 'Computer science student', 'Available this week'),
      ('Naledi M.', 'Administration student', 'Residence member'),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              opportunity.title,
              style: const TextStyle(
                color: AccommodationColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${opportunity.applicants} total applicants',
              style: const TextStyle(
                color: AccommodationColors.muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            for (final applicant in applicants)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      AccommodationColors.blue.withValues(alpha: 0.1),
                  child: Text(applicant.$1.substring(0, 1)),
                ),
                title: Text(
                  applicant.$1,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${applicant.$2}  |  ${applicant.$3}'),
                trailing: IconButton(
                  tooltip: 'View applicant',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${applicant.$1} profile.')),
                  ),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
