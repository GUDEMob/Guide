import 'package:flutter/material.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';

enum _ServiceView { complaints, announcements }

enum _ComplaintFilter { all, open, resolved }

class AccommodationServicePage extends StatefulWidget {
  final String initialTab;

  const AccommodationServicePage({
    super.key,
    this.initialTab = 'complaints',
  });

  @override
  State<AccommodationServicePage> createState() =>
      _AccommodationServicePageState();
}

class _AccommodationServicePageState extends State<AccommodationServicePage> {
  final store = AccommodationPortalStore.instance;
  final _searchController = TextEditingController();
  late _ServiceView _view;
  _ComplaintFilter _filter = _ComplaintFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _view = widget.initialTab == 'announcements'
        ? _ServiceView.announcements
        : _ServiceView.complaints;
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
      floatingActionButton: _view == _ServiceView.announcements
          ? FloatingActionButton.extended(
              onPressed: _composeAnnouncement,
              backgroundColor: AccommodationColors.green,
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
            final posts = _visiblePosts();
            final resolved =
                store.requests.where((request) => request.resolved).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
              children: [
                const PortalPageHeader(
                  eyebrow: 'Resident care',
                  title: 'Service desk',
                  subtitle:
                      'Resolve resident complaints and keep every residence informed.',
                  icon: Icons.support_agent_rounded,
                  accent: AccommodationColors.green,
                  secondary: AccommodationColors.blue,
                  backRoute: '/accommodation/overview',
                ),
                const SizedBox(height: 14),
                PortalSummaryBand(
                  colors: const [
                    AccommodationColors.green,
                    AccommodationColors.blue,
                  ],
                  items: [
                    PortalSummaryItem(
                      value: '${store.openRequestCount}',
                      label: 'Open cases',
                      icon: Icons.support_agent_rounded,
                      onTap: () => setState(() {
                        _view = _ServiceView.complaints;
                        _filter = _ComplaintFilter.open;
                      }),
                    ),
                    PortalSummaryItem(
                      value: '$resolved',
                      label: 'Resolved',
                      icon: Icons.task_alt_rounded,
                      onTap: () => setState(() {
                        _view = _ServiceView.complaints;
                        _filter = _ComplaintFilter.resolved;
                      }),
                    ),
                    PortalSummaryItem(
                      value: '${store.communityPosts.length}',
                      label: 'Updates',
                      icon: Icons.campaign_rounded,
                      onTap: () => setState(
                        () => _view = _ServiceView.announcements,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SegmentedButton<_ServiceView>(
                  segments: const [
                    ButtonSegment(
                      value: _ServiceView.complaints,
                      icon: Icon(Icons.support_agent_outlined),
                      label: Text('Complaints'),
                    ),
                    ButtonSegment(
                      value: _ServiceView.announcements,
                      icon: Icon(Icons.campaign_outlined),
                      label: Text('Announcements'),
                    ),
                  ],
                  selected: {_view},
                  onSelectionChanged: (value) => setState(() {
                    _view = value.first;
                    _searchController.clear();
                    _query = '';
                  }),
                  style: ButtonStyle(
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
                ),
                const SizedBox(height: 12),
                PortalSearchBar(
                  controller: _searchController,
                  hint: _view == _ServiceView.complaints
                      ? 'Search complaints, residents or residences'
                      : 'Search announcements or audiences',
                  accent: AccommodationColors.green,
                  onChanged: (value) => setState(() => _query = value),
                ),
                if (_view == _ServiceView.complaints) ...[
                  const SizedBox(height: 12),
                  _ComplaintFilterBar(
                    value: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 20),
                  PortalSectionTitle(
                    'Resident complaints',
                    trailing: '${complaints.length} shown',
                  ),
                  const SizedBox(height: 10),
                  if (complaints.isEmpty)
                    const _EmptyServiceState(
                      icon: Icons.support_agent_outlined,
                      text: 'No complaints match these filters.',
                    )
                  else
                    for (final complaint in complaints)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _ComplaintCard(
                          request: complaint,
                          onToggleResolved: () => complaint.resolved
                              ? store.reopenRequest(complaint.id)
                              : store.resolveRequest(complaint.id),
                        ),
                      ),
                ] else ...[
                  const SizedBox(height: 20),
                  PortalSectionTitle(
                    'Residence announcements',
                    trailing: '${posts.length} shown',
                  ),
                  const SizedBox(height: 10),
                  if (posts.isEmpty)
                    const _EmptyServiceState(
                      icon: Icons.campaign_outlined,
                      text: 'No announcements match this search.',
                    )
                  else
                    for (final post in posts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _AnnouncementCard(
                          post: post,
                          onTogglePinned: () =>
                              store.toggleCommunityPostPinned(post.id),
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

  List<ResidentRequest> _visibleComplaints() {
    final query = _query.trim().toLowerCase();
    final values = store.requests.where((request) {
      final statusMatches = switch (_filter) {
        _ComplaintFilter.all => true,
        _ComplaintFilter.open => !request.resolved,
        _ComplaintFilter.resolved => request.resolved,
      };
      final queryMatches = query.isEmpty ||
          request.title.toLowerCase().contains(query) ||
          request.category.toLowerCase().contains(query) ||
          request.residence.toLowerCase().contains(query) ||
          request.student.toLowerCase().contains(query);
      return statusMatches && queryMatches;
    }).toList();
    values.sort((a, b) {
      if (a.resolved != b.resolved) return a.resolved ? 1 : -1;
      return b.priority.index.compareTo(a.priority.index);
    });
    return values;
  }

  List<CommunityPost> _visiblePosts() {
    final query = _query.trim().toLowerCase();
    final values = store.communityPosts.where((post) {
      return query.isEmpty ||
          post.title.toLowerCase().contains(query) ||
          post.detail.toLowerCase().contains(query) ||
          post.audience.toLowerCase().contains(query);
    }).toList();
    values.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return 0;
    });
    return values;
  }

  Future<void> _composeAnnouncement() async {
    final title = TextEditingController();
    final message = TextEditingController();
    var audience = 'All residents';
    final published = await showModalBottomSheet<bool>(
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
                const Text(
                  'New announcement',
                  style: TextStyle(
                    color: AccommodationColors.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: portalInputDecoration(
                    'Title',
                    icon: Icons.title_rounded,
                    accent: AccommodationColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: message,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: portalInputDecoration(
                    'Message',
                    icon: Icons.notes_rounded,
                    accent: AccommodationColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: audience,
                  isExpanded: true,
                  decoration: portalInputDecoration(
                    'Audience',
                    icon: Icons.groups_2_outlined,
                    accent: AccommodationColors.green,
                  ),
                  items: ['All residents', ...store.residences]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => audience = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    if (title.text.trim().isEmpty ||
                        message.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add a title and message.'),
                        ),
                      );
                      return;
                    }
                    store.publishCommunityPost(
                      title: title.text.trim(),
                      detail: message.text.trim(),
                      audience: audience,
                      type: CommunityPostType.announcement,
                    );
                    Navigator.pop(sheetContext, true);
                  },
                  icon: const Icon(Icons.campaign_rounded),
                  label: const Text('Publish announcement'),
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
    title.dispose();
    message.dispose();
    if (published == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published.')),
      );
    }
  }
}

class _ComplaintFilterBar extends StatelessWidget {
  final _ComplaintFilter value;
  final ValueChanged<_ComplaintFilter> onChanged;

  const _ComplaintFilterBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ComplaintFilter>(
      segments: const [
        ButtonSegment(value: _ComplaintFilter.all, label: Text('All')),
        ButtonSegment(value: _ComplaintFilter.open, label: Text('Open')),
        ButtonSegment(
          value: _ComplaintFilter.resolved,
          label: Text('Resolved'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (values) => onChanged(values.first),
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ResidentRequest request;
  final VoidCallback onToggleResolved;

  const _ComplaintCard({
    required this.request,
    required this.onToggleResolved,
  });

  Color get priorityColor => switch (request.priority) {
        RequestPriority.high => AccommodationColors.primary,
        RequestPriority.medium => AccommodationColors.orange,
        RequestPriority.low => AccommodationColors.blue,
      };

  String get priorityLabel => switch (request.priority) {
        RequestPriority.high => 'High priority',
        RequestPriority.medium => 'Medium priority',
        RequestPriority.low => 'Low priority',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
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
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.support_agent_rounded, color: priorityColor),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.student} | ${request.residence}',
                      style: const TextStyle(
                        color: AccommodationColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Manage complaint',
                onSelected: (_) => onToggleResolved(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(
                      request.resolved ? 'Reopen complaint' : 'Mark resolved',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _CaseTag(
                label: priorityLabel,
                icon: Icons.flag_outlined,
                color: priorityColor,
              ),
              _CaseTag(
                label: request.category,
                icon: Icons.category_outlined,
                color: AccommodationColors.blue,
              ),
              _CaseTag(
                label: request.age,
                icon: Icons.schedule_rounded,
                color: AccommodationColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onToggleResolved,
              icon: Icon(
                request.resolved
                    ? Icons.refresh_rounded
                    : Icons.task_alt_rounded,
              ),
              label: Text(
                request.resolved ? 'Reopen complaint' : 'Resolve complaint',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: request.resolved
                    ? AccommodationColors.orange
                    : AccommodationColors.green,
                side: BorderSide(
                  color: request.resolved
                      ? AccommodationColors.orange
                      : AccommodationColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _CaseTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTogglePinned;

  const _AnnouncementCard({
    required this.post,
    required this.onTogglePinned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: post.isPinned
              ? AccommodationColors.green.withValues(alpha: 0.55)
              : AccommodationColors.line,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F4EE),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              post.isPinned ? Icons.push_pin_rounded : Icons.campaign_rounded,
              color: AccommodationColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    color: AccommodationColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  post.detail,
                  style: const TextStyle(
                    color: AccommodationColors.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${post.audience} | ${post.published} | ${post.engagement} views',
                  style: const TextStyle(
                    color: AccommodationColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: post.isPinned ? 'Unpin announcement' : 'Pin announcement',
            onPressed: onTogglePinned,
            icon: Icon(
              post.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: post.isPinned
                  ? AccommodationColors.green
                  : AccommodationColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyServiceState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyServiceState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        children: [
          Icon(icon, color: AccommodationColors.muted, size: 34),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
