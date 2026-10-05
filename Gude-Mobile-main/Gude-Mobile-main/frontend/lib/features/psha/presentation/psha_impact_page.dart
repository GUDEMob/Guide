import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_ui.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';

class PshaImpactPage extends StatelessWidget {
  const PshaImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PshaPortalStore.instance;
    final number = NumberFormat.decimalPattern();
    return Scaffold(
      backgroundColor: AccommodationColors.canvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            PortalPageHeader(
              eyebrow: 'Sector intelligence',
              title: 'Student success impact',
              subtitle:
                  'Aggregated, privacy-conscious outcomes across PSHA members.',
              action: IconButton.filledTonal(
                tooltip: 'Export impact report',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Impact report prepared for export.'),
                  ),
                ),
                icon: const Icon(Icons.download_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AccommodationColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2026 network reach',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${number.format(store.studentCount)} students',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    '68% of annual network participation target',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const PortalSectionTitle('Outcome indicators'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _OutcomeTile(
                  value: number.format(store.opportunityCount),
                  label: 'Work opportunities',
                  change: '+18% this quarter',
                  icon: Icons.work_outline_rounded,
                  color: AccommodationColors.orange,
                ),
                const _OutcomeTile(
                  value: '1,284',
                  label: 'Verified experiences',
                  change: '+236 this quarter',
                  icon: Icons.verified_outlined,
                  color: AccommodationColors.blue,
                ),
                const _OutcomeTile(
                  value: '4,960',
                  label: 'Survey responses',
                  change: '42% response rate',
                  icon: Icons.poll_outlined,
                  color: AccommodationColors.green,
                ),
                _OutcomeTile(
                  value: '${store.averageEngagement}%',
                  label: 'Active engagement',
                  change: '+6 points',
                  icon: Icons.insights_rounded,
                  color: AccommodationColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 22),
            const PortalSectionTitle('Regional student reach'),
            const SizedBox(height: 10),
            const _RegionRow('Gauteng', 7240, 0.72),
            const SizedBox(height: 9),
            const _RegionRow('Western Cape', 3867, 0.48),
            const SizedBox(height: 9),
            const _RegionRow('KwaZulu-Natal', 710, 0.22),
            const SizedBox(height: 9),
            const _RegionRow('Eastern Cape', 760, 0.24),
            const SizedBox(height: 9),
            const _RegionRow('Other provinces', 810, 0.26),
            const SizedBox(height: 22),
            const PortalSectionTitle('Reporting readiness'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AccommodationColors.line),
              ),
              child: const Column(
                children: [
                  _ReadinessRow(
                    'Member data reporting',
                    '5 of 5 providers current',
                    true,
                  ),
                  Divider(height: 1),
                  _ReadinessRow(
                    'Student consent coverage',
                    '96% confirmed',
                    true,
                  ),
                  Divider(height: 1),
                  _ReadinessRow(
                    'Annual impact report',
                    'Draft due 30 November',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeTile extends StatelessWidget {
  final String value;
  final String label;
  final String change;
  final IconData icon;
  final Color color;

  const _OutcomeTile({
    required this.value,
    required this.label,
    required this.change,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AccommodationColors.ink,
              fontSize: 19,
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
          const SizedBox(height: 3),
          Text(change, style: TextStyle(color: color, fontSize: 9)),
        ],
      ),
    );
  }
}

class _RegionRow extends StatelessWidget {
  final String region;
  final int students;
  final double progress;

  const _RegionRow(this.region, this.students, this.progress);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  region,
                  style: const TextStyle(
                    color: AccommodationColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                NumberFormat.decimalPattern().format(students),
                style: const TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
            color: AccommodationColors.blue,
            backgroundColor: AccommodationColors.blue.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  final String title;
  final String detail;
  final bool ready;

  const _ReadinessRow(this.title, this.detail, this.ready);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        ready ? Icons.check_circle_rounded : Icons.schedule_rounded,
        color: ready ? AccommodationColors.green : AccommodationColors.orange,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(detail),
    );
  }
}
