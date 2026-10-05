import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';

class PshaOverviewPage extends StatelessWidget {
  const PshaOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PshaPortalStore.instance;
    final number = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              PortalPageHeader(
                eyebrow: 'PSHA network command centre',
                title: 'National overview',
                subtitle:
                    '${store.activeProviderCount} active member providers reporting through Gude',
                action: IconButton.filledTonal(
                  tooltip: 'Network notifications',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('There are 2 member updates to review.'),
                    ),
                  ),
                  icon: const Badge(
                    label: Text('2'),
                    child: Icon(Icons.notifications_none_rounded),
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
                    value: '${store.buildingCount}',
                    label: 'Buildings',
                    icon: Icons.apartment_rounded,
                    color: AccommodationColors.primary,
                  ),
                  PortalMetricTile(
                    value: number.format(store.studentCount),
                    label: 'Students housed',
                    icon: Icons.groups_2_outlined,
                    color: AccommodationColors.blue,
                  ),
                  PortalMetricTile(
                    value: '${store.providerCount}',
                    label: 'Member providers',
                    icon: Icons.business_outlined,
                    color: AccommodationColors.orange,
                  ),
                  PortalMetricTile(
                    value: '${store.averageOccupancy}%',
                    label: 'Average occupancy',
                    icon: Icons.hotel_outlined,
                    color: AccommodationColors.green,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ImpactBand(store: store),
              const SizedBox(height: 22),
              PortalSectionTitle(
                'Member performance',
                trailing: 'Top ${store.providers.length}',
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AccommodationColors.line),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < store.providers.length; i++)
                      _ProviderRow(
                        provider: store.providers[i],
                        showDivider: i < store.providers.length - 1,
                        onTap: () => context.go('/psha/members'),
                      ),
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
                      color: AccommodationColors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SnapshotTile(
                      icon: Icons.insights_rounded,
                      value: '${store.averageEngagement}%',
                      label: 'Student engagement',
                      color: AccommodationColors.green,
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

class _ImpactBand extends StatelessWidget {
  final PshaPortalStore store;

  const _ImpactBand({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AccommodationColors.ink,
        borderRadius: BorderRadius.circular(10),
      ),
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
                color: AccommodationColors.green,
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

class _SnapshotTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SnapshotTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
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
          Icon(icon, color: color, size: 21),
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
    );
  }
}
