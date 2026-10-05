import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';

class AccommodationOverviewPage extends StatefulWidget {
  const AccommodationOverviewPage({super.key});

  @override
  State<AccommodationOverviewPage> createState() =>
      _AccommodationOverviewPageState();
}

class _AccommodationOverviewPageState extends State<AccommodationOverviewPage> {
  final store = AccommodationPortalStore.instance;

  @override
  void initState() {
    super.initState();
    store.hydrateProviderName();
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
            final openRequests =
                store.requests.where((request) => !request.resolved).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                PortalPageHeader(
                  eyebrow: 'Residence experience',
                  title: store.providerName,
                  subtitle:
                      '${store.residences.length} residences connected to Gude',
                  action: IconButton.filledTonal(
                    tooltip: 'Notifications',
                    onPressed: () => _showMessage(
                      '${store.openRequestCount} resident requests need attention.',
                    ),
                    icon: Badge(
                      label: Text('${store.openRequestCount}'),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    PortalMetricTile(
                      value: '${store.residentCount}',
                      label: 'Residents reached',
                      icon: Icons.groups_2_outlined,
                      color: AccommodationColors.blue,
                    ),
                    PortalMetricTile(
                      value: '${store.engagementRate}%',
                      label: 'Monthly engagement',
                      icon: Icons.insights_outlined,
                      color: AccommodationColors.green,
                    ),
                    PortalMetricTile(
                      value: '${store.openOpportunityCount}',
                      label: 'Open opportunities',
                      icon: Icons.work_outline_rounded,
                      color: AccommodationColors.orange,
                    ),
                    PortalMetricTile(
                      value: '${store.openRequestCount}',
                      label: 'Open requests',
                      icon: Icons.support_agent_outlined,
                      color: AccommodationColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const PortalSectionTitle('Quick actions'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.campaign_outlined,
                        label: 'Publish update',
                        color: AccommodationColors.primary,
                        onTap: () => context.go('/accommodation/community'),
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
                const SizedBox(height: 12),
                const PortalSectionTitle('Latest community activity'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        borderRadius: BorderRadius.circular(10),
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
