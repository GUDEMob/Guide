import 'package:flutter/material.dart';
import 'package:gude_app/services/user_role_service.dart';

class _C {
  static const primary = Color(0xFFE50914);
  static const orange = Color(0xFFFF6B00);
  static const amber = Color(0xFFFFB000);
  static const ink = Color(0xFF211815);
  static const muted = Color(0xFF80665C);
  static const line = Color(0xFFF0D8CE);
  static const canvas = Color(0xFFFFF8F3);
  static const success = Color(0xFF16875D);
  static const blue = Color(0xFF3F63D9);
}

class OpportunityPost {
  final String title;
  final String type;
  final String pay;
  final String location;
  final String closes;
  final List<String> tags;
  final int applicants;
  final int likes;
  final int reposts;
  final int shares;
  final int views;

  const OpportunityPost({
    required this.title,
    required this.type,
    required this.pay,
    required this.location,
    required this.closes,
    required this.tags,
    required this.applicants,
    this.likes = 0,
    this.reposts = 0,
    this.shares = 0,
    this.views = 0,
  });

  int get reactions => likes + reposts + shares + applicants;
}

class OpportunitySource {
  final String id;
  final String name;
  final String type;
  final String location;
  final String summary;
  final IconData icon;
  final Color color;
  final String alert;
  final List<OpportunityPost> posts;

  const OpportunitySource({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.summary,
    required this.icon,
    required this.color,
    required this.alert,
    required this.posts,
  });

  OpportunitySource copyWith({List<OpportunityPost>? posts}) {
    return OpportunitySource(
      id: id,
      name: name,
      type: type,
      location: location,
      summary: summary,
      icon: icon,
      color: color,
      alert: alert,
      posts: posts ?? this.posts,
    );
  }
}

class InstituteAlert {
  final String source;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;

  const InstituteAlert({
    required this.source,
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
  });
}

class InstitutionMarketplacePage extends StatefulWidget {
  const InstitutionMarketplacePage({super.key});

  @override
  State<InstitutionMarketplacePage> createState() =>
      _InstitutionMarketplacePageState();
}

class _InstitutionMarketplacePageState
    extends State<InstitutionMarketplacePage> {
  final _searchCtrl = TextEditingController();
  final Set<String> _followed = {'uct', 'standard-bank'};

  late final List<OpportunitySource> _sources;
  String _filter = 'All';
  String _query = '';

  static const _filters = [
    'All',
    'Universities',
    'Banks',
    'Companies',
    'NGOs',
    'Public Sector',
  ];

  List<OpportunitySource> get _visibleSources {
    final q = _query.trim().toLowerCase();
    return _sources.where((source) {
      final matchesFilter = _filter == 'All' || source.type == _filter;
      final matchesSearch = q.isEmpty ||
          source.name.toLowerCase().contains(q) ||
          source.type.toLowerCase().contains(q) ||
          source.location.toLowerCase().contains(q) ||
          source.posts.any((post) =>
              post.title.toLowerCase().contains(q) ||
              post.type.toLowerCase().contains(q) ||
              post.tags.any((tag) => tag.toLowerCase().contains(q)));
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get _postCount =>
      _sources.fold(0, (total, source) => total + source.posts.length);

  List<OpportunityPost> get _myPosts =>
      _sources.firstWhere((source) => source.id == 'mine').posts;

  int get _myLikes => _myPosts.fold(0, (total, post) => total + post.likes);

  int get _myReposts => _myPosts.fold(0, (total, post) => total + post.reposts);

  int get _myShares => _myPosts.fold(0, (total, post) => total + post.shares);

  int get _myApplicants =>
      _myPosts.fold(0, (total, post) => total + post.applicants);

  @override
  void initState() {
    super.initState();
    final institution = UserRoleService().institutionName.trim();
    _sources = _mockSources(
      institution.isEmpty ? 'Your Institution' : institution,
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleSources;
    final alerts = _mockAlerts;

    return Scaffold(
      backgroundColor: _C.canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        backgroundColor: _C.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post job'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      alerts: alerts.length,
                      onAlerts: () => _showAlerts(alerts),
                    ),
                    const SizedBox(height: 14),
                    _SearchBar(
                      controller: _searchCtrl,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 14),
                    _SummaryBand(
                      sources: _sources.length,
                      posts: _postCount,
                      alerts: alerts.length,
                      onPartnersTap: () => _showAllPartners(),
                      onPostsTap: () => _showAllPosts(),
                      onAlertsTap: () => _showAlerts(alerts),
                    ),
                    const SizedBox(height: 16),
                    _AlertStrip(alerts: alerts, onTap: _showAlertDetail),
                    const SizedBox(height: 16),
                    _StudentReactionsPanel(
                      posts: _myPosts.length,
                      likes: _myLikes,
                      reposts: _myReposts,
                      shares: _myShares,
                      applicants: _myApplicants,
                    ),
                    const SizedBox(height: 16),
                    _FilterRail(
                      filters: _filters,
                      selected: _filter,
                      onSelect: (value) => setState(() => _filter = value),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Institutions and partners',
                            style: TextStyle(
                              color: _C.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${visible.length} shown',
                          style: const TextStyle(
                            color: _C.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          if (visible.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final source = visible[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == visible.length - 1 ? 0 : 12,
                      ),
                      child: _SourceCard(
                        source: source,
                        followed: _followed.contains(source.id),
                        onFollow: () => _toggleFollow(source),
                        onViewPosts: () => _showPosts(source),
                      ),
                    );
                  },
                  childCount: visible.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleFollow(OpportunitySource source) {
    setState(() {
      if (_followed.contains(source.id)) {
        _followed.remove(source.id);
      } else {
        _followed.add(source.id);
      }
    });
  }

  void _showAlerts(List<InstituteAlert> alerts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AlertsSheet(alerts: alerts),
    );
  }

  void _showAlertDetail(InstituteAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${alert.source}: ${alert.title}')),
    );
  }

  void _showAllPartners() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PartnersSheet(
        sources: _sources,
        onOpenPosts: (source) {
          Navigator.pop(context);
          _showPosts(source);
        },
      ),
    );
  }

  void _showAllPosts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AllPostsSheet(sources: _sources),
    );
  }

  void _showPosts(OpportunitySource source) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PostsSheet(source: source),
    );
  }

  void _createPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _CreatePostSheet(
        onPost: (post) {
          final index = _sources.indexWhere((source) => source.id == 'mine');
          setState(() {
            final mine = _sources[index];
            _sources[index] = mine.copyWith(posts: [post, ...mine.posts]);
          });
          Navigator.pop(sheetContext);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Job post added to your institution.')),
          );
        },
      ),
    );
  }
}

List<OpportunitySource> _mockSources(String institutionName) {
  return [
    OpportunitySource(
      id: 'mine',
      name: institutionName,
      type: 'Universities',
      location: 'Your campus',
      summary: 'Manage your own posts and publish opportunities for students.',
      icon: Icons.account_balance_rounded,
      color: _C.primary,
      alert: 'New applicants will appear here.',
      posts: const [
        OpportunityPost(
          title: 'Campus Event Assistant',
          type: 'Part-time',
          pay: 'R300/event',
          location: 'Campus',
          closes: 'Closes in 12 days',
          tags: ['Events', 'Student affairs'],
          applicants: 18,
          likes: 86,
          reposts: 12,
          shares: 24,
          views: 920,
        ),
        OpportunityPost(
          title: 'Student Brand Ambassador',
          type: 'Campaign',
          pay: 'R1 200/project',
          location: 'Hybrid',
          closes: 'Closes in 9 days',
          tags: ['Marketing', 'Campus', 'Social media'],
          applicants: 27,
          likes: 134,
          reposts: 21,
          shares: 38,
          views: 1480,
        ),
      ],
    ),
    OpportunitySource(
      id: 'uct',
      name: 'University of Cape Town',
      type: 'Universities',
      location: 'Cape Town',
      summary: 'Campus research, library, tutor and student support roles.',
      icon: Icons.school_rounded,
      color: _C.orange,
      alert: 'Research assistant intake closes this week.',
      posts: const [
        OpportunityPost(
          title: 'Psychology Research Assistant',
          type: 'Part-time',
          pay: 'R50/hour',
          location: 'Hybrid',
          closes: 'Closes in 6 days',
          tags: ['Research', 'Psychology', 'Excel'],
          applicants: 8,
        ),
        OpportunityPost(
          title: 'Library Desk Assistant',
          type: 'Part-time',
          pay: 'R45/hour',
          location: 'Campus',
          closes: 'Closes in 4 days',
          tags: ['Library', 'Admin'],
          applicants: 5,
        ),
      ],
    ),
    OpportunitySource(
      id: 'standard-bank',
      name: 'Standard Bank',
      type: 'Banks',
      location: 'Johannesburg',
      summary:
          'Banking internships, student ambassador roles and finance events.',
      icon: Icons.account_balance_wallet_rounded,
      color: _C.amber,
      alert: 'Winter internship applications are open.',
      posts: const [
        OpportunityPost(
          title: 'Student Banking Ambassador',
          type: 'Part-time',
          pay: 'R4 500/month',
          location: 'Campus-based',
          closes: 'Closes in 10 days',
          tags: ['Sales', 'Finance', 'Marketing'],
          applicants: 31,
        ),
        OpportunityPost(
          title: 'Data Analyst Internship',
          type: 'Internship',
          pay: 'Paid',
          location: 'Johannesburg',
          closes: 'Closes in 18 days',
          tags: ['Data', 'Excel', 'SQL'],
          applicants: 56,
        ),
      ],
    ),
    OpportunitySource(
      id: 'takealot',
      name: 'Takealot Group',
      type: 'Companies',
      location: 'Cape Town',
      summary: 'Operations, support, logistics and junior digital roles.',
      icon: Icons.business_center_rounded,
      color: _C.amber,
      alert: 'New weekend shift roles added.',
      posts: const [
        OpportunityPost(
          title: 'Customer Support Intern',
          type: 'Internship',
          pay: 'Paid',
          location: 'Remote',
          closes: 'Closes in 14 days',
          tags: ['Support', 'E-commerce'],
          applicants: 22,
        ),
        OpportunityPost(
          title: 'Warehouse Weekend Assistant',
          type: 'Part-time',
          pay: 'R60/hour',
          location: 'Cape Town',
          closes: 'Closes in 8 days',
          tags: ['Logistics', 'Weekend'],
          applicants: 17,
        ),
      ],
    ),
    OpportunitySource(
      id: 'youth-start',
      name: 'Youth Start Foundation',
      type: 'NGOs',
      location: 'Durban',
      summary: 'Community projects, tutoring support and youth outreach work.',
      icon: Icons.volunteer_activism_rounded,
      color: _C.success,
      alert: 'Volunteer mentor applications close soon.',
      posts: const [
        OpportunityPost(
          title: 'Community Tutor',
          type: 'Part-time',
          pay: 'R120/session',
          location: 'Durban',
          closes: 'Closes in 5 days',
          tags: ['Tutoring', 'Community'],
          applicants: 14,
        ),
        OpportunityPost(
          title: 'Youth Outreach Assistant',
          type: 'Volunteer',
          pay: 'Transport stipend',
          location: 'Durban',
          closes: 'Closes in 15 days',
          tags: ['Outreach', 'Events'],
          applicants: 9,
        ),
      ],
    ),
    OpportunitySource(
      id: 'city-cape-town',
      name: 'City of Cape Town',
      type: 'Public Sector',
      location: 'Cape Town',
      summary:
          'Municipal internships, admin support and civic engagement posts.',
      icon: Icons.location_city_rounded,
      color: _C.blue,
      alert: 'Graduate programme deadline updated.',
      posts: const [
        OpportunityPost(
          title: 'Admin Support Intern',
          type: 'Internship',
          pay: 'Stipend',
          location: 'Cape Town',
          closes: 'Closes in 21 days',
          tags: ['Admin', 'Public sector'],
          applicants: 44,
        ),
      ],
    ),
  ];
}

const _mockAlerts = [
  InstituteAlert(
    source: 'Standard Bank',
    title: 'Internship applications opened',
    detail: 'Finance and data roles are accepting applications this month.',
    icon: Icons.campaign_rounded,
    color: _C.primary,
  ),
  InstituteAlert(
    source: 'University of Cape Town',
    title: 'Research assistant posts closing',
    detail: 'Psychology and library roles close in less than one week.',
    icon: Icons.timer_rounded,
    color: _C.blue,
  ),
  InstituteAlert(
    source: 'Takealot Group',
    title: 'Weekend roles added',
    detail: 'New part-time logistics shifts are available for students.',
    icon: Icons.work_history_rounded,
    color: _C.amber,
  ),
];

class _Header extends StatelessWidget {
  final int alerts;
  final VoidCallback onAlerts;

  const _Header({
    required this.alerts,
    required this.onAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _C.primary.withValues(alpha: 0.14),
                _C.orange.withValues(alpha: 0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.account_balance_rounded, color: _C.orange),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opportunity network',
                style: TextStyle(
                  color: _C.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Institutions, banks and companies',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _C.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton.filledTonal(
              tooltip: 'Alerts',
              onPressed: onAlerts,
              icon: const Icon(Icons.notifications_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _C.orange,
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _C.orange,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$alerts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search companies, banks or job posts',
          hintStyle: const TextStyle(color: _C.muted, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _C.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _C.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _C.orange, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _SummaryBand extends StatelessWidget {
  final int sources;
  final int posts;
  final int alerts;
  final VoidCallback onPartnersTap;
  final VoidCallback onPostsTap;
  final VoidCallback onAlertsTap;

  const _SummaryBand({
    required this.sources,
    required this.posts,
    required this.alerts,
    required this.onPartnersTap,
    required this.onPostsTap,
    required this.onAlertsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.primary, _C.orange, _C.amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.orange.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _Metric(
            label: 'Partners',
            value: '$sources',
            icon: Icons.business_rounded,
            onTap: onPartnersTap,
          ),
          const SizedBox(width: 10),
          _Metric(
            label: 'Job posts',
            value: '$posts',
            icon: Icons.work_rounded,
            onTap: onPostsTap,
          ),
          const SizedBox(width: 10),
          _Metric(
            label: 'Alerts',
            value: '$alerts',
            icon: Icons.notifications_active_rounded,
            onTap: onAlertsTap,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(icon, color: Colors.white, size: 15),
                  ],
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartnersSheet extends StatelessWidget {
  final List<OpportunitySource> sources;
  final ValueChanged<OpportunitySource> onOpenPosts;

  const _PartnersSheet({
    required this.sources,
    required this.onOpenPosts,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              const Text(
                'Partners',
                style: TextStyle(
                  color: _C.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${sources.length} institutions, banks, companies and organisations',
                style: const TextStyle(color: _C.muted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              for (final source in sources) ...[
                _PartnerRow(
                  source: source,
                  onOpenPosts: () => onOpenPosts(source),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PartnerRow extends StatelessWidget {
  final OpportunitySource source;
  final VoidCallback onOpenPosts;

  const _PartnerRow({
    required this.source,
    required this.onOpenPosts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: source.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(source.icon, color: source.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${source.type} - ${source.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniPill(
                      label: '${source.posts.length} posts',
                      color: source.color,
                    ),
                    _MiniPill(label: source.type, color: _C.muted),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Open posts',
            onPressed: onOpenPosts,
            icon: const Icon(Icons.chevron_right_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _C.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllPostsSheet extends StatelessWidget {
  final List<OpportunitySource> sources;

  const _AllPostsSheet({required this.sources});

  @override
  Widget build(BuildContext context) {
    final allPosts = [
      for (final source in sources)
        for (final post in source.posts) (source: source, post: post),
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.76,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              const Text(
                'All job posts',
                style: TextStyle(
                  color: _C.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${allPosts.length} opportunities across partners',
                style: const TextStyle(color: _C.muted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              for (final item in allPosts) ...[
                Text(
                  item.source.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                _PostDetail(post: item.post),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StudentReactionsPanel extends StatelessWidget {
  final int posts;
  final int likes;
  final int reposts;
  final int shares;
  final int applicants;

  const _StudentReactionsPanel({
    required this.posts,
    required this.likes,
    required this.reposts,
    required this.shares,
    required this.applicants,
  });

  @override
  Widget build(BuildContext context) {
    final totalReactions = likes + reposts + shares + applicants;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    colors: [_C.primary, _C.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.query_stats_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student reactions',
                      style: TextStyle(
                        color: _C.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$totalReactions reactions across $posts active posts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _TrendPill(value: '+18%'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ReactionTile(
                icon: Icons.favorite_rounded,
                label: 'Likes',
                value: likes,
                color: _C.primary,
              ),
              const SizedBox(width: 8),
              _ReactionTile(
                icon: Icons.repeat_rounded,
                label: 'Reposts',
                value: reposts,
                color: _C.blue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ReactionTile(
                icon: Icons.send_rounded,
                label: 'Shares',
                value: shares,
                color: _C.orange,
              ),
              const SizedBox(width: 8),
              _ReactionTile(
                icon: Icons.assignment_turned_in_rounded,
                label: 'Applied',
                value: applicants,
                color: _C.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _ReactionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
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
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final String value;

  const _TrendPill({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: _C.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up_rounded, color: _C.success, size: 14),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              color: _C.success,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertStrip extends StatelessWidget {
  final List<InstituteAlert> alerts;
  final ValueChanged<InstituteAlert> onTap;

  const _AlertStrip({
    required this.alerts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final alert = alerts[index];
          return _AlertCard(alert: alert, onTap: () => onTap(alert));
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final InstituteAlert alert;
  final VoidCallback onTap;

  const _AlertCard({
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 245,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: _C.line),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: alert.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(alert.icon, color: alert.color, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        alert.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        alert.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.ink,
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterRail extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterRail({
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = filters[index];
          final active = label == selected;
          return ChoiceChip(
            selected: active,
            onSelected: (_) => onSelect(label),
            showCheckmark: false,
            label: Text(label),
            selectedColor: _C.orange,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: active ? Colors.white : _C.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(color: active ? _C.orange : _C.line),
            ),
          );
        },
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final OpportunitySource source;
  final bool followed;
  final VoidCallback onFollow;
  final VoidCallback onViewPosts;

  const _SourceCard({
    required this.source,
    required this.followed,
    required this.onFollow,
    required this.onViewPosts,
  });

  @override
  Widget build(BuildContext context) {
    final previewPosts = source.posts.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: source.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(source.icon, color: source.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${source.type} - ${source.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: followed ? 'Unfollow alerts' : 'Follow alerts',
                visualDensity: VisualDensity.compact,
                onPressed: onFollow,
                icon: Icon(
                  followed
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: followed ? _C.primary : _C.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            source.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _C.muted, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          _InlineAlert(text: source.alert, color: source.color),
          const SizedBox(height: 12),
          for (final post in previewPosts) ...[
            _PostPreview(post: post),
            if (post != previewPosts.last) const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewPosts,
                  icon: const Icon(Icons.work_outline_rounded, size: 16),
                  label: Text('View ${source.posts.length} posts'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.primary,
                    side: const BorderSide(color: _C.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onFollow,
                icon: Icon(
                  followed ? Icons.check_rounded : Icons.add_alert_outlined,
                  size: 16,
                ),
                label: Text(followed ? 'Following' : 'Follow'),
                style: FilledButton.styleFrom(
                  backgroundColor: followed ? _C.success : _C.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineAlert extends StatelessWidget {
  final String text;
  final Color color;

  const _InlineAlert({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign_outlined, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
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

class _PostPreview extends StatelessWidget {
  final OpportunityPost post;

  const _PostPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _C.canvas,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _MiniPill(label: post.type, color: _C.primary),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _TinyInfo(icon: Icons.payments_outlined, label: post.pay),
              _TinyInfo(icon: Icons.location_on_outlined, label: post.location),
              _TinyInfo(icon: Icons.timer_outlined, label: post.closes),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _PostReactionChip(
                icon: Icons.favorite_rounded,
                label: '${post.likes}',
                color: _C.primary,
              ),
              _PostReactionChip(
                icon: Icons.repeat_rounded,
                label: '${post.reposts}',
                color: _C.blue,
              ),
              _PostReactionChip(
                icon: Icons.assignment_turned_in_rounded,
                label: '${post.applicants}',
                color: _C.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TinyInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TinyInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _C.muted),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: _C.muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PostReactionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PostReactionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsSheet extends StatelessWidget {
  final List<InstituteAlert> alerts;

  const _AlertsSheet({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            const Text(
              'Notifications and alerts',
              style: TextStyle(
                color: _C.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final alert in alerts)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: alert.color.withValues(alpha: 0.1),
                  child: Icon(alert.icon, color: alert.color),
                ),
                title: Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text('${alert.source} - ${alert.detail}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PostsSheet extends StatelessWidget {
  final OpportunitySource source;

  const _PostsSheet({required this.source});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Text(
                source.name,
                style: const TextStyle(
                  color: _C.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${source.posts.length} available posts',
                style: const TextStyle(color: _C.muted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              for (final post in source.posts) ...[
                _PostDetail(post: post),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PostDetail extends StatelessWidget {
  final OpportunityPost post;

  const _PostDetail({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: const TextStyle(
                    color: _C.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _MiniPill(label: post.type, color: _C.primary),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinyInfo(icon: Icons.payments_outlined, label: post.pay),
              _TinyInfo(icon: Icons.location_on_outlined, label: post.location),
              _TinyInfo(icon: Icons.timer_outlined, label: post.closes),
              _TinyInfo(
                icon: Icons.people_outline_rounded,
                label: '${post.applicants} applicants',
              ),
              _TinyInfo(
                icon: Icons.visibility_outlined,
                label: '${post.views} views',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _PostReactionChip(
                icon: Icons.favorite_rounded,
                label: '${post.likes} likes',
                color: _C.primary,
              ),
              _PostReactionChip(
                icon: Icons.repeat_rounded,
                label: '${post.reposts} reposts',
                color: _C.blue,
              ),
              _PostReactionChip(
                icon: Icons.send_rounded,
                label: '${post.shares} shares',
                color: _C.orange,
              ),
              _PostReactionChip(
                icon: Icons.assignment_turned_in_rounded,
                label: '${post.applicants} applied',
                color: _C.success,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: post.tags
                .map((tag) => _MiniPill(label: tag, color: _C.muted))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: _C.line,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.search_off_rounded, color: _C.primary),
            ),
            const SizedBox(height: 14),
            const Text(
              'No partners found',
              style: TextStyle(
                color: _C.ink,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another category or search for a different opportunity.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _C.muted, fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  final ValueChanged<OpportunityPost> onPost;

  const _CreatePostSheet({required this.onPost});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _titleCtrl = TextEditingController();
  final _typeCtrl = TextEditingController(text: 'Part-time');
  final _payCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final List<String> _tags = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _typeCtrl.dispose();
    _payCtrl.dispose();
    _locationCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              const Text(
                'Post an opportunity',
                style: TextStyle(
                  color: _C.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _SheetField(controller: _titleCtrl, hint: 'Job title'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SheetField(
                      controller: _typeCtrl,
                      hint: 'Type',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SheetField(controller: _payCtrl, hint: 'Pay'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SheetField(controller: _locationCtrl, hint: 'Location'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SheetField(
                      controller: _tagCtrl,
                      hint: 'Add tag',
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: _C.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    onDeleted: () => setState(() => _tags.removeAt(entry.key)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Publish post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag() {
    final value = _tagCtrl.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _tags.add(value);
      _tagCtrl.clear();
    });
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a job title first.')),
      );
      return;
    }

    widget.onPost(
      OpportunityPost(
        title: _titleCtrl.text.trim(),
        type:
            _typeCtrl.text.trim().isEmpty ? 'Part-time' : _typeCtrl.text.trim(),
        pay: _payCtrl.text.trim().isEmpty
            ? 'To be confirmed'
            : _payCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty
            ? 'Campus'
            : _locationCtrl.text.trim(),
        closes: 'Closes in 14 days',
        tags: _tags.isEmpty ? const ['Student opportunity'] : _tags,
        applicants: 0,
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  const _SheetField({
    required this.controller,
    required this.hint,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _C.canvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primary, width: 1.4),
        ),
      ),
    );
  }
}
