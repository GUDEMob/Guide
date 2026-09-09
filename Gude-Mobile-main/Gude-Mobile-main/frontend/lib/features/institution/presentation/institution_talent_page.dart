import 'package:flutter/material.dart';

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

class StudentTalent {
  final String name;
  final String field;
  final String location;
  final String availability;
  final String match;
  final String rate;
  final double rating;
  final List<String> skills;
  final Color color;
  final bool saved;

  const StudentTalent({
    required this.name,
    required this.field,
    required this.location,
    required this.availability,
    required this.match,
    required this.rate,
    required this.rating,
    required this.skills,
    required this.color,
    this.saved = false,
  });
}

class ActiveOpportunity {
  final String title;
  final String type;
  final String pay;
  final String location;

  const ActiveOpportunity({
    required this.title,
    required this.type,
    required this.pay,
    required this.location,
  });
}

const _filters = [
  'All',
  'Saved',
  'Research',
  'Tech',
  'Design',
  'Tutoring',
  'Admin',
];

const _talent = [
  StudentTalent(
    name: 'Amina K.',
    field: 'Statistics honours student',
    location: 'Online',
    availability: 'Available this week',
    match: '92% match',
    rate: 'R160/hr',
    rating: 5.0,
    skills: ['Statistics', 'Research', 'Excel'],
    color: _C.success,
    saved: true,
  ),
  StudentTalent(
    name: 'Keanu N.',
    field: 'Computer science student',
    location: 'Johannesburg',
    availability: 'Part-time',
    match: '88% match',
    rate: 'R150/hr',
    rating: 4.8,
    skills: ['Python', 'Dashboards', 'Tech'],
    color: _C.blue,
  ),
  StudentTalent(
    name: 'Yusuf A.',
    field: 'Brand and social designer',
    location: 'Cape Town',
    availability: 'Project based',
    match: '86% match',
    rate: 'From R200',
    rating: 4.9,
    skills: ['Design', 'Canva', 'Marketing'],
    color: _C.orange,
    saved: true,
  ),
  StudentTalent(
    name: 'Naledi M.',
    field: 'Library and admin assistant',
    location: 'Pretoria',
    availability: 'Weekdays',
    match: '81% match',
    rate: 'R80/hr',
    rating: 4.7,
    skills: ['Admin', 'Research', 'Support'],
    color: _C.amber,
  ),
  StudentTalent(
    name: 'Priya S.',
    field: 'Writing and CV support',
    location: 'Remote',
    availability: 'Flexible',
    match: '79% match',
    rate: 'From R180',
    rating: 4.9,
    skills: ['Writing', 'Tutoring', 'Editing'],
    color: _C.primary,
  ),
];

const _activeOpportunities = [
  ActiveOpportunity(
    title: 'Campus Event Assistant',
    type: 'Part-time',
    pay: 'R300/event',
    location: 'Campus',
  ),
  ActiveOpportunity(
    title: 'Research Assistant',
    type: 'Part-time',
    pay: 'R50/hour',
    location: 'Hybrid',
  ),
  ActiveOpportunity(
    title: 'Library Desk Assistant',
    type: 'Part-time',
    pay: 'R45/hour',
    location: 'Campus',
  ),
];

class InstitutionTalentPage extends StatefulWidget {
  const InstitutionTalentPage({super.key});

  @override
  State<InstitutionTalentPage> createState() => _InstitutionTalentPageState();
}

class _InstitutionTalentPageState extends State<InstitutionTalentPage> {
  final _searchCtrl = TextEditingController();
  final Set<String> _saved = {
    for (final person in _talent)
      if (person.saved) person.name,
  };

  String _filter = 'All';
  String _query = '';

  List<StudentTalent> get _visibleTalent {
    final q = _query.trim().toLowerCase();
    return _talent.where((person) {
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Saved' && _saved.contains(person.name)) ||
          person.skills.contains(_filter);
      final matchesSearch = q.isEmpty ||
          person.name.toLowerCase().contains(q) ||
          person.field.toLowerCase().contains(q) ||
          person.location.toLowerCase().contains(q) ||
          person.skills.any((skill) => skill.toLowerCase().contains(q));
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTalent;

    return Scaffold(
      backgroundColor: _C.canvas,
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
                      savedCount: _saved.length,
                      onSavedTap: () => setState(() => _filter = 'Saved'),
                    ),
                    const SizedBox(height: 14),
                    _SearchBox(
                      controller: _searchCtrl,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 14),
                    _SummaryBand(
                      talentCount: _talent.length,
                      savedCount: _saved.length,
                    ),
                    const SizedBox(height: 16),
                    _FilterRail(
                      selected: _filter,
                      onSelect: (value) => setState(() => _filter = value),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Recommended talent',
                            style: TextStyle(
                              color: _C.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${visible.length} found',
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: visible.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyTalentState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final person = visible[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == visible.length - 1 ? 0 : 12,
                          ),
                          child: _TalentCard(
                            person: person,
                            saved: _saved.contains(person.name),
                            onSave: () => _toggleSaved(person.name),
                            onInvite: () => _showInviteSheet(person),
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

  void _toggleSaved(String name) {
    setState(() {
      if (_saved.contains(name)) {
        _saved.remove(name);
      } else {
        _saved.add(name);
      }
    });
  }

  void _showInviteSheet(StudentTalent person) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _InviteSheet(
        person: person,
        onExistingPost: () {
          Navigator.pop(context);
          _showExistingPostPicker(person);
        },
        onCreateOpportunity: () {
          Navigator.pop(context);
          _showTailoredOpportunitySheet(person);
        },
        onMessageFirst: () {
          Navigator.pop(context);
          _showMessageSheet(person);
        },
      ),
    );
  }

  void _showExistingPostPicker(StudentTalent person) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ExistingPostSheet(
        person: person,
        onSend: (opportunity) {
          Navigator.pop(context);
          _showSuccess(
            'Invite sent to ${person.name} for ${opportunity.title}.',
          );
        },
      ),
    );
  }

  void _showTailoredOpportunitySheet(StudentTalent person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TailoredOpportunitySheet(
        person: person,
        onSend: (title) {
          Navigator.pop(context);
          _showSuccess('Tailored opportunity "$title" sent to ${person.name}.');
        },
      ),
    );
  }

  void _showMessageSheet(StudentTalent person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MessageFirstSheet(
        person: person,
        onSend: () {
          Navigator.pop(context);
          _showSuccess('Message sent to ${person.name}.');
        },
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _C.success,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int savedCount;
  final VoidCallback onSavedTap;

  const _Header({
    required this.savedCount,
    required this.onSavedTap,
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
          child: const Icon(Icons.school_rounded, color: _C.orange),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Talent directory',
                style: TextStyle(
                  color: _C.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Find student candidates',
                style: TextStyle(
                  color: _C.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Badge(
          label: Text('$savedCount'),
          backgroundColor: _C.orange,
          child: IconButton.filledTonal(
            tooltip: 'Saved talent',
            onPressed: onSavedTap,
            icon: const Icon(Icons.bookmark_border_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _C.orange,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({
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
          hintText: 'Search skills, students or locations',
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
  final int talentCount;
  final int savedCount;

  const _SummaryBand({
    required this.talentCount,
    required this.savedCount,
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
          _Metric(label: 'Candidates', value: '$talentCount'),
          const SizedBox(width: 10),
          _Metric(label: 'Saved', value: '$savedCount'),
          const SizedBox(width: 10),
          const _Metric(label: 'Avg match', value: '85%'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
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
    );
  }
}

class _FilterRail extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterRail({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = _filters[index];
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

class _EmptyTalentState extends StatelessWidget {
  const _EmptyTalentState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.line),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: _C.orange, size: 34),
          SizedBox(height: 10),
          Text(
            'No matching talent',
            style: TextStyle(
              color: _C.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different skill, location or filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _C.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  final StudentTalent person;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onInvite;

  const _TalentCard({
    required this.person,
    required this.saved,
    required this.onSave,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
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
              CircleAvatar(
                radius: 26,
                backgroundColor: person.color.withValues(alpha: 0.1),
                child: Text(
                  _initials(person.name),
                  style: TextStyle(
                    color: person.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        color: _C.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      person.field,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: saved ? 'Remove saved talent' : 'Save talent',
                visualDensity: VisualDensity.compact,
                onPressed: onSave,
                icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: saved ? _C.primary : _C.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                person.skills.map((skill) => _SkillPill(label: skill)).toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _TinyInfo(
                  icon: Icons.location_on_outlined, label: person.location),
              _TinyInfo(
                  icon: Icons.schedule_rounded, label: person.availability),
              _TinyInfo(
                  icon: Icons.star_rounded,
                  label: person.rating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MatchPill(text: person.match, color: person.color),
              const SizedBox(width: 8),
              Text(
                person.rate,
                style: const TextStyle(
                  color: _C.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onInvite,
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Invite'),
                style: FilledButton.styleFrom(
                  backgroundColor: _C.orange,
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

  String _initials(String value) {
    final parts = value.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1);
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }
}

class _SkillPill extends StatelessWidget {
  final String label;

  const _SkillPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _C.canvas,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _C.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TinyInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TinyInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _C.muted, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: _C.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MatchPill extends StatelessWidget {
  final String text;
  final Color color;

  const _MatchPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InviteSheet extends StatelessWidget {
  final StudentTalent person;
  final VoidCallback onExistingPost;
  final VoidCallback onCreateOpportunity;
  final VoidCallback onMessageFirst;

  const _InviteSheet({
    required this.person,
    required this.onExistingPost,
    required this.onCreateOpportunity,
    required this.onMessageFirst,
  });

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
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _C.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Invite ${person.name}',
              style: const TextStyle(
                color: _C.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${person.field} - ${person.match}',
              style: const TextStyle(color: _C.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _InviteOption(
              icon: Icons.work_outline_rounded,
              title: 'Invite to an existing job post',
              subtitle: 'Send this student one of your active opportunities.',
              onTap: onExistingPost,
            ),
            _InviteOption(
              icon: Icons.add_task_outlined,
              title: 'Create a tailored opportunity',
              subtitle: 'Start a new role based on this student profile.',
              onTap: onCreateOpportunity,
            ),
            _InviteOption(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Message first',
              subtitle: 'Ask about availability before sending an invite.',
              onTap: onMessageFirst,
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InviteOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _C.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded, color: _C.muted),
      onTap: onTap,
    );
  }
}

class _ExistingPostSheet extends StatelessWidget {
  final StudentTalent person;
  final ValueChanged<ActiveOpportunity> onSend;

  const _ExistingPostSheet({
    required this.person,
    required this.onSend,
  });

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
            Text(
              'Choose a job for ${person.name}',
              style: const TextStyle(
                color: _C.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ..._activeOpportunities.map(
              (opportunity) => _OpportunityChoice(
                opportunity: opportunity,
                onTap: () => onSend(opportunity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityChoice extends StatelessWidget {
  final ActiveOpportunity opportunity;
  final VoidCallback onTap;

  const _OpportunityChoice({
    required this.opportunity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _C.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.work_outline_rounded, color: _C.orange),
        ),
        title: Text(
          opportunity.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${opportunity.type} - ${opportunity.pay} - ${opportunity.location}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.send_rounded, color: _C.primary),
      ),
    );
  }
}

class _TailoredOpportunitySheet extends StatefulWidget {
  final StudentTalent person;
  final ValueChanged<String> onSend;

  const _TailoredOpportunitySheet({
    required this.person,
    required this.onSend,
  });

  @override
  State<_TailoredOpportunitySheet> createState() =>
      _TailoredOpportunitySheetState();
}

class _TailoredOpportunitySheetState extends State<_TailoredOpportunitySheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _payCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: _suggestedTitle);
    _payCtrl = TextEditingController(text: widget.person.rate);
    _noteCtrl = TextEditingController(
      text:
          'Hi ${widget.person.name}, your ${widget.person.skills.take(2).join(' and ')} skills look like a strong fit for this opportunity.',
    );
  }

  String get _suggestedTitle {
    if (widget.person.skills.contains('Design')) return 'Student Design Lead';
    if (widget.person.skills.contains('Tech')) return 'Junior Tech Assistant';
    if (widget.person.skills.contains('Research')) return 'Research Assistant';
    if (widget.person.skills.contains('Tutoring')) return 'Peer Tutor';
    return 'Student Support Assistant';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _payCtrl.dispose();
    _noteCtrl.dispose();
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
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Text(
                'Tailor an opportunity',
                style: const TextStyle(
                  color: _C.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create a quick invite for ${widget.person.name}.',
                style: const TextStyle(color: _C.muted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              _SheetField(
                controller: _titleCtrl,
                label: 'Opportunity title',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 10),
              _SheetField(
                controller: _payCtrl,
                label: 'Pay or stipend',
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 10),
              _SheetField(
                controller: _noteCtrl,
                label: 'Invite note',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  final title = _titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  widget.onSend(title);
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send tailored invite'),
                style: FilledButton.styleFrom(
                  backgroundColor: _C.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
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
}

class _MessageFirstSheet extends StatefulWidget {
  final StudentTalent person;
  final VoidCallback onSend;

  const _MessageFirstSheet({
    required this.person,
    required this.onSend,
  });

  @override
  State<_MessageFirstSheet> createState() => _MessageFirstSheetState();
}

class _MessageFirstSheetState extends State<_MessageFirstSheet> {
  late final TextEditingController _messageCtrl;

  @override
  void initState() {
    super.initState();
    _messageCtrl = TextEditingController(
      text:
          'Hi ${widget.person.name}, I saw your profile on Gude and would like to ask about your availability for a student opportunity.',
    );
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
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
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Text(
                'Message ${widget.person.name}',
                style: const TextStyle(
                  color: _C.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _messageCtrl,
                label: 'Message',
                icon: Icons.chat_bubble_outline_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  if (_messageCtrl.text.trim().isEmpty) return;
                  widget.onSend();
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send message'),
                style: FilledButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
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
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _C.primary),
        filled: true,
        fillColor: _C.canvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.orange, width: 1.4),
        ),
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
