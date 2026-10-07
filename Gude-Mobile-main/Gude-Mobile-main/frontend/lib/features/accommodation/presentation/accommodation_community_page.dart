import 'package:flutter/material.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';

class AccommodationCommunityPage extends StatefulWidget {
  const AccommodationCommunityPage({super.key});

  @override
  State<AccommodationCommunityPage> createState() =>
      _AccommodationCommunityPageState();
}

class _AccommodationCommunityPageState
    extends State<AccommodationCommunityPage> {
  final store = AccommodationPortalStore.instance;
  final _searchController = TextEditingController();
  CommunityPostType? selectedType;
  String _query = '';

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
        onPressed: _openComposer,
        backgroundColor: AccommodationColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create'),
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final query = _query.trim().toLowerCase();
            final visible = store.communityPosts.where((post) {
              final matchesType =
                  selectedType == null || post.type == selectedType;
              final matchesQuery = query.isEmpty ||
                  post.title.toLowerCase().contains(query) ||
                  post.detail.toLowerCase().contains(query) ||
                  post.audience.toLowerCase().contains(query);
              return matchesType && matchesQuery;
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
                          eyebrow: 'Residence hub',
                          title: 'Community',
                          subtitle:
                              'Keep residents informed, involved and heard.',
                          icon: Icons.campaign_rounded,
                          accent: AccommodationColors.green,
                          secondary: AccommodationColors.blue,
                          backRoute: '/accommodation/overview',
                        ),
                        const SizedBox(height: 14),
                        PortalSearchBar(
                          controller: _searchController,
                          hint: 'Search notices, events or surveys',
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
                              value: '${store.communityPosts.length}',
                              label: 'Updates',
                              icon: Icons.campaign_rounded,
                              onTap: () => setState(() => selectedType = null),
                            ),
                            PortalSummaryItem(
                              value: '${store.residentCount}',
                              label: 'Residents',
                              icon: Icons.groups_2_rounded,
                              onTap: () => _showMetric(
                                '${store.residentCount} residents are connected to this community.',
                              ),
                            ),
                            PortalSummaryItem(
                              value: '${store.engagementRate}%',
                              label: 'Engagement',
                              icon: Icons.insights_rounded,
                              onTap: () => _showMetric(
                                'Monthly resident engagement is ${store.engagementRate}%.',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: selectedType == null,
                                onTap: () =>
                                    setState(() => selectedType = null),
                              ),
                              const SizedBox(width: 8),
                              for (final type in CommunityPostType.values) ...[
                                _FilterChip(
                                  label: _typeLabel(type),
                                  selected: selectedType == type,
                                  onTap: () =>
                                      setState(() => selectedType = type),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        PortalSectionTitle(
                          'Notice board',
                          trailing: '${visible.length} items',
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                if (visible.isEmpty)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverToBoxAdapter(child: _EmptyCommunityState()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CommunityCard(post: visible[index]),
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

  Future<void> _openComposer() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _CreateCommunitySheet(store: store),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community update published.')),
      );
    }
  }

  void _showMetric(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _EmptyCommunityState extends StatelessWidget {
  const _EmptyCommunityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: AccommodationColors.muted),
          SizedBox(height: 7),
          Text(
            'No published content matches these filters.',
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AccommodationColors.primary,
      backgroundColor: Colors.white,
      side: const BorderSide(color: AccommodationColors.line),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AccommodationColors.muted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityPost post;

  const _CommunityCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(post.type);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_typeIcon(post.type), color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(post.type),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: AccommodationColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Post actions',
                onSelected: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value: ${post.title}')),
                  );
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'View', child: Text('View details')),
                  PopupMenuItem(value: 'Duplicate', child: Text('Duplicate')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.detail,
            style: const TextStyle(
              color: AccommodationColors.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.groups_outlined,
                  size: 15, color: AccommodationColors.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  post.audience,
                  style: const TextStyle(
                    color: AccommodationColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.visibility_outlined,
                  size: 15, color: AccommodationColors.muted),
              const SizedBox(width: 4),
              Text(
                '${post.engagement}',
                style: const TextStyle(
                  color: AccommodationColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                post.published,
                style: const TextStyle(
                  color: AccommodationColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateCommunitySheet extends StatefulWidget {
  final AccommodationPortalStore store;

  const _CreateCommunitySheet({required this.store});

  @override
  State<_CreateCommunitySheet> createState() => _CreateCommunitySheetState();
}

class _CreateCommunitySheetState extends State<_CreateCommunitySheet> {
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  CommunityPostType type = CommunityPostType.announcement;
  String audience = 'All residents';

  @override
  void dispose() {
    titleController.dispose();
    detailController.dispose();
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
                'Create community update',
                style: TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              SegmentedButton<CommunityPostType>(
                segments: const [
                  ButtonSegment(
                    value: CommunityPostType.announcement,
                    icon: Icon(Icons.campaign_outlined),
                    label: Text('Notice'),
                  ),
                  ButtonSegment(
                    value: CommunityPostType.event,
                    icon: Icon(Icons.event_outlined),
                    label: Text('Event'),
                  ),
                  ButtonSegment(
                    value: CommunityPostType.survey,
                    icon: Icon(Icons.poll_outlined),
                    label: Text('Survey'),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (value) =>
                    setState(() => type = value.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                decoration: portalInputDecoration('Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailController,
                minLines: 3,
                maxLines: 5,
                decoration: portalInputDecoration('Details'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: audience,
                decoration: portalInputDecoration('Audience'),
                items: [
                  'All residents',
                  ...widget.store.residences,
                ]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => audience = value ?? audience),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Publish update'),
                style: FilledButton.styleFrom(
                  backgroundColor: AccommodationColors.primary,
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
      ),
    );
  }

  void _publish() {
    final title = titleController.text.trim();
    final detail = detailController.text.trim();
    if (title.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and details first.')),
      );
      return;
    }
    widget.store.publishCommunityPost(
      title: title,
      detail: detail,
      audience: audience,
      type: type,
    );
    Navigator.pop(context, true);
  }
}

String _typeLabel(CommunityPostType type) {
  return switch (type) {
    CommunityPostType.announcement => 'Announcements',
    CommunityPostType.event => 'Events',
    CommunityPostType.survey => 'Surveys',
  };
}

IconData _typeIcon(CommunityPostType type) {
  return switch (type) {
    CommunityPostType.announcement => Icons.campaign_outlined,
    CommunityPostType.event => Icons.event_outlined,
    CommunityPostType.survey => Icons.poll_outlined,
  };
}

Color _typeColor(CommunityPostType type) {
  return switch (type) {
    CommunityPostType.announcement => AccommodationColors.primary,
    CommunityPostType.event => AccommodationColors.blue,
    CommunityPostType.survey => AccommodationColors.green,
  };
}
