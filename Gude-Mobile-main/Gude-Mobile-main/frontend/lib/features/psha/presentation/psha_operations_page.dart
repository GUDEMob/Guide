import 'package:flutter/material.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';
import 'package:gude_app/features/psha/presentation/psha_ui.dart';

enum _OperationsView { complaints, announcements }

class PshaOperationsPage extends StatefulWidget {
  final String initialTab;

  const PshaOperationsPage({
    super.key,
    this.initialTab = 'complaints',
  });

  @override
  State<PshaOperationsPage> createState() => _PshaOperationsPageState();
}

class _PshaOperationsPageState extends State<PshaOperationsPage> {
  final store = PshaPortalStore.instance;
  final _searchController = TextEditingController();
  late _OperationsView _view;
  PshaComplaintStatus? _complaintStatus;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _view = widget.initialTab == 'announcements'
        ? _OperationsView.announcements
        : _OperationsView.complaints;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PshaColors.canvas,
      floatingActionButton: _view == _OperationsView.announcements
          ? FloatingActionButton.extended(
              onPressed: _openAnnouncementComposer,
              backgroundColor: PshaColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New announcement'),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final complaints = _visibleComplaints();
            final announcements = _visibleAnnouncements();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
              children: [
                const PortalPageHeader(
                  eyebrow: 'Network communications',
                  title: 'Service centre',
                  subtitle:
                      'Manage student complaints and member announcements.',
                  icon: Icons.support_agent_rounded,
                  accent: PshaColors.primary,
                  secondary: PshaColors.teal,
                  backRoute: '/psha/overview',
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
                      value: '${store.openComplaintCount}',
                      label: 'Open cases',
                      icon: Icons.support_agent_rounded,
                      onTap: () => setState(() {
                        _view = _OperationsView.complaints;
                        _complaintStatus = PshaComplaintStatus.open;
                      }),
                    ),
                    PortalSummaryItem(
                      value:
                          '${store.complaints.where((item) => item.status == PshaComplaintStatus.resolved).length}',
                      label: 'Resolved',
                      icon: Icons.task_alt_rounded,
                      onTap: () => setState(() {
                        _view = _OperationsView.complaints;
                        _complaintStatus = PshaComplaintStatus.resolved;
                      }),
                    ),
                    PortalSummaryItem(
                      value: '${store.announcements.length}',
                      label: 'Updates',
                      icon: Icons.campaign_rounded,
                      onTap: () => setState(
                        () => _view = _OperationsView.announcements,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ViewSwitcher(
                  selected: _view,
                  onChanged: (value) => setState(() => _view = value),
                ),
                const SizedBox(height: 12),
                PortalSearchBar(
                  controller: _searchController,
                  hint: _view == _OperationsView.complaints
                      ? 'Search students, complaints or residences'
                      : 'Search announcements or audiences',
                  accent: PshaColors.primary,
                  onChanged: (value) => setState(() => _query = value),
                ),
                if (_view == _OperationsView.complaints) ...[
                  const SizedBox(height: 12),
                  _ComplaintFilterRail(
                    selected: _complaintStatus,
                    onChanged: (value) =>
                        setState(() => _complaintStatus = value),
                  ),
                  const SizedBox(height: 18),
                  PortalSectionTitle(
                    'Student complaints',
                    trailing: '${complaints.length} shown',
                  ),
                  const SizedBox(height: 10),
                  if (complaints.isEmpty)
                    const _OperationsEmptyState(
                      icon: Icons.support_agent_outlined,
                      message: 'No complaints match these filters.',
                    )
                  else
                    for (final complaint in complaints)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _ComplaintCard(
                          complaint: complaint,
                          onStatusChanged: (status) =>
                              store.updateComplaintStatus(
                            complaint.id,
                            status,
                          ),
                        ),
                      ),
                ] else ...[
                  const SizedBox(height: 18),
                  PortalSectionTitle(
                    'Announcements',
                    trailing: '${announcements.length} shown',
                  ),
                  const SizedBox(height: 10),
                  if (announcements.isEmpty)
                    const _OperationsEmptyState(
                      icon: Icons.campaign_outlined,
                      message: 'No announcements match your search.',
                    )
                  else
                    for (final announcement in announcements)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _AnnouncementCard(
                          announcement: announcement,
                          onTogglePinned: () =>
                              store.toggleAnnouncementPinned(announcement.id),
                        ),
                      ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<PshaComplaint> _visibleComplaints() {
    final query = _query.trim().toLowerCase();
    final result = store.complaints.where((item) {
      final matchesStatus =
          _complaintStatus == null || item.status == _complaintStatus;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.detail.toLowerCase().contains(query) ||
          item.studentName.toLowerCase().contains(query) ||
          item.providerName.toLowerCase().contains(query) ||
          item.buildingName.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
    result.sort((a, b) {
      final priority = b.priority.index.compareTo(a.priority.index);
      return priority != 0
          ? priority
          : a.status.index.compareTo(b.status.index);
    });
    return result;
  }

  List<PshaAnnouncement> _visibleAnnouncements() {
    final query = _query.trim().toLowerCase();
    final result = store.announcements.where((item) {
      return query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query) ||
          item.audience.toLowerCase().contains(query);
    }).toList();
    result.sort((a, b) => a.pinned == b.pinned ? 0 : (a.pinned ? -1 : 1));
    return result;
  }

  Future<void> _openAnnouncementComposer() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _AnnouncementComposer(store: store),
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  final _OperationsView selected;
  final ValueChanged<_OperationsView> onChanged;

  const _ViewSwitcher({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ViewButton(
          label: 'Complaints',
          icon: Icons.support_agent_rounded,
          selected: selected == _OperationsView.complaints,
          onTap: () => onChanged(_OperationsView.complaints),
        ),
        const SizedBox(width: 9),
        _ViewButton(
          label: 'Announcements',
          icon: Icons.campaign_rounded,
          selected: selected == _OperationsView.announcements,
          onTap: () => onChanged(_OperationsView.announcements),
        ),
      ],
    );
  }
}

class _ViewButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          foregroundColor: selected ? Colors.white : PshaColors.muted,
          backgroundColor: selected ? PshaColors.primary : Colors.white,
          minimumSize: const Size.fromHeight(46),
          side: const BorderSide(color: PshaColors.line),
          elevation: 0,
        ),
      ),
    );
  }
}

class _ComplaintFilterRail extends StatelessWidget {
  final PshaComplaintStatus? selected;
  final ValueChanged<PshaComplaintStatus?> onChanged;

  const _ComplaintFilterRail({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = <(String, PshaComplaintStatus?)>[
      ('All', null),
      ('Open', PshaComplaintStatus.open),
      ('In progress', PshaComplaintStatus.inProgress),
      ('Resolved', PshaComplaintStatus.resolved),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            ChoiceChip(
              label: Text(filter.$1),
              selected: selected == filter.$2,
              onSelected: (_) => onChanged(filter.$2),
              selectedColor: PshaColors.primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: PshaColors.line),
              labelStyle: TextStyle(
                color: selected == filter.$2 ? Colors.white : PshaColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final PshaComplaint complaint;
  final ValueChanged<PshaComplaintStatus> onStatusChanged;

  const _ComplaintCard({
    required this.complaint,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (complaint.priority) {
      PshaComplaintPriority.high => const Color(0xFFD14343),
      PshaComplaintPriority.medium => PshaColors.amber,
      PshaComplaintPriority.low => PshaColors.blue,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PshaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.support_agent_rounded, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.title,
                      style: const TextStyle(
                        color: PshaColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${complaint.studentName}  |  ${complaint.buildingName}',
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
              _ComplaintStatusPill(status: complaint.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            complaint.detail,
            style: const TextStyle(
              color: PshaColors.muted,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${complaint.providerName}  |  ${complaint.age}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PshaColors.muted,
                    fontSize: 9,
                  ),
                ),
              ),
              PopupMenuButton<PshaComplaintStatus>(
                tooltip: 'Update complaint status',
                onSelected: onStatusChanged,
                itemBuilder: (_) => PshaComplaintStatus.values
                    .map(
                      (status) => PopupMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note_rounded,
                        color: PshaColors.primary, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Update',
                      style: TextStyle(
                        color: PshaColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComplaintStatusPill extends StatelessWidget {
  final PshaComplaintStatus status;

  const _ComplaintStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PshaComplaintStatus.open => const Color(0xFFD14343),
      PshaComplaintStatus.inProgress => PshaColors.amber,
      PshaComplaintStatus.resolved => PshaColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final PshaAnnouncement announcement;
  final VoidCallback onTogglePinned;

  const _AnnouncementCard({
    required this.announcement,
    required this.onTogglePinned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PshaColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PshaColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.campaign_rounded, color: PshaColors.teal),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          color: PshaColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (announcement.pinned)
                      const Icon(
                        Icons.push_pin_rounded,
                        color: PshaColors.primary,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  announcement.message,
                  style: const TextStyle(
                    color: PshaColors.muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${announcement.audience}  |  ${announcement.published}',
                  style: const TextStyle(
                    color: PshaColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: announcement.pinned ? 'Unpin' : 'Pin announcement',
            onPressed: onTogglePinned,
            icon: Icon(
              announcement.pinned
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              color: PshaColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementComposer extends StatefulWidget {
  final PshaPortalStore store;

  const _AnnouncementComposer({required this.store});

  @override
  State<_AnnouncementComposer> createState() => _AnnouncementComposerState();
}

class _AnnouncementComposerState extends State<_AnnouncementComposer> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  String _audience = 'All member providers';

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
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
                'Create announcement',
                style: TextStyle(
                  color: PshaColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _title,
                decoration: _input('Title', Icons.title_rounded),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _message,
                minLines: 3,
                maxLines: 5,
                decoration: _input('Message', Icons.notes_rounded),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _audience,
                decoration: _input('Audience', Icons.groups_2_outlined),
                items: const [
                  DropdownMenuItem(
                    value: 'All member providers',
                    child: Text('All member providers'),
                  ),
                  DropdownMenuItem(
                    value: 'Residence administrators',
                    child: Text('Residence administrators'),
                  ),
                  DropdownMenuItem(
                    value: 'All residences',
                    child: Text('All residences'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _audience = value);
                },
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Publish announcement'),
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

  void _publish() {
    if (_title.text.trim().isEmpty || _message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and message first.')),
      );
      return;
    }
    widget.store.publishAnnouncement(
      title: _title.text.trim(),
      message: _message.text.trim(),
      audience: _audience,
    );
    Navigator.pop(context);
  }
}

class _OperationsEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _OperationsEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PshaColors.line),
      ),
      child: Column(
        children: [
          Icon(icon, color: PshaColors.muted),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
