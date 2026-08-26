// lib/features/challenges/presentation/challenges_page.dart
// Challenges — PDF last page
// "Survive till month-end" · "NSFAS delay survival plan" · "R0 to R500 savings challenge"

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Colours ─────────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE30613);
  static const dark      = Color(0xFF1A1A1A);
  static const grey      = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border    = Color(0xFFEEEEEE);
  static const green     = Color(0xFF10B981);
  static const amber     = Color(0xFFF59E0B);
  static const blue      = Color(0xFF3B82F6);
}

// ── Challenge step model ──────────────────────────────────────
class _Step {
  final String label;
  bool done;
  _Step(this.label, {this.done = false});
}

// ── Full challenge model ──────────────────────────────────────
class _Challenge {
  final String id, title, subtitle, emoji, description;
  final Color color, colorDark;
  final int totalDays, rewardPts;
  final List<_Step> steps;
  bool active;
  int daysCompleted;

  _Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.description,
    required this.color,
    required this.colorDark,
    required this.totalDays,
    required this.rewardPts,
    required this.steps,
    this.active = false,
    this.daysCompleted = 0,
  });

  double get progress =>
      totalDays > 0 ? (daysCompleted / totalDays).clamp(0.0, 1.0) : 0;
}

// ── Data ─────────────────────────────────────────────────────
List<_Challenge> _buildChallenges() => [
      _Challenge(
        id: 'survive',
        title: 'Survive till Month-End',
        subtitle: 'Budget discipline mode',
        emoji: '💰',
        description:
            'You have R1,250 for 12 days — that\'s R104/day. '
            'Stay in budget every single day and prove you can make it to month-end.',
        color: _C.primary,
        colorDark: const Color(0xFF8B0000),
        totalDays: 12,
        rewardPts: 100,
        daysCompleted: 3,
        active: true,
        steps: [
          _Step('Set a daily spend limit of R104',    done: true),
          _Step('Cut all non-essential purchases',    done: true),
          _Step('Cook at home at least 5 times',      done: true),
          _Step('Log every expense for 12 days',      done: false),
          _Step('Don\'t overdraft or go negative',    done: false),
          _Step('Reach month-end with R0 or more',    done: false),
        ],
      ),
      _Challenge(
        id: 'nsfas',
        title: 'NSFAS Delay Survival Plan',
        subtitle: 'Emergency budget mode',
        emoji: '⏳',
        description:
            'NSFAS payment is delayed — activate survival mode. '
            'Cut costs to the bone, use your emergency fund wisely, and get to the other side.',
        color: _C.amber,
        colorDark: const Color(0xFF92400E),
        totalDays: 14,
        rewardPts: 150,
        daysCompleted: 0,
        active: false,
        steps: [
          _Step('Reduce food budget to R30/day'),
          _Step('Pause all entertainment spend'),
          _Step('Alert your res about delayed payment'),
          _Step('Use campus facilities (no paid gym)'),
          _Step('Contact financial aid office'),
          _Step('Activate R500 emergency fund'),
          _Step('Survive 14 days without extra debt'),
        ],
      ),
      _Challenge(
        id: 'savings500',
        title: 'R0 to R500 Savings',
        subtitle: '4-week savings sprint',
        emoji: '🚀',
        description:
            'Build R500 from nothing in 4 weeks. '
            'Each week has a specific action that stacks up to R500+ saved.',
        color: const Color(0xFF8B5CF6),
        colorDark: const Color(0xFF5B21B6),
        totalDays: 28,
        rewardPts: 100,
        daysCompleted: 12,
        active: true,
        steps: [
          _Step('Week 1: Skip 1 takeout (+R80)',        done: true),
          _Step('Week 1: Walk instead of Uber 2x (+R90)', done: true),
          _Step('Week 2: Cancel 1 subscription (+R60)', done: false),
          _Step('Week 2: Sell something on marketplace (+R150)', done: false),
          _Step('Week 3: Cook all meals at home (+R120)', done: false),
          _Step('Week 4: Transfer R500 to savings pocket', done: false),
        ],
      ),
    ];

// ════════════════════════════════════════════════════════════
//  ChallengesPage
// ════════════════════════════════════════════════════════════
class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});
  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final List<_Challenge> _challenges = _buildChallenges();

  void _toggleActivate(_Challenge c) {
    setState(() => c.active = !c.active);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(c.active
            ? '${c.emoji} "${c.title}" activated!'
            : '"${c.title}" deactivated'),
        backgroundColor: c.active ? c.color : _C.grey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openDetail(_Challenge c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChallengeDetailPage(
          challenge: c,
          onStepToggle: (i) => setState(() {
            c.steps[i].done = !c.steps[i].done;
            c.daysCompleted = c.steps.where((s) => s.done).length;
          }),
          onActivate: () => _toggleActivate(c),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active   = _challenges.where((c) => c.active).toList();
    final inactive = _challenges.where((c) => !c.active).toList();

    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Challenges',
            style: TextStyle(
                color: _C.dark,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: _C.amber),
            onPressed: () => context.push('/rewards'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero banner
          _HeroBanner(),
          const SizedBox(height: 20),

          if (active.isNotEmpty) ...[
            _SectionLabel(
                label: '🔥 Active Challenges', count: active.length),
            const SizedBox(height: 10),
            ...active.map((c) => _ChallengeSummaryCard(
                  challenge: c,
                  onTap: () => _openDetail(c),
                  onDeactivate: () => _toggleActivate(c),
                )),
            const SizedBox(height: 20),
          ],

          if (inactive.isNotEmpty) ...[
            _SectionLabel(
                label: '💡 Available Challenges',
                count: inactive.length),
            const SizedBox(height: 10),
            ...inactive.map((c) => _ChallengeSummaryCard(
                  challenge: c,
                  onTap: () => _openDetail(c),
                  onActivate: () => _toggleActivate(c),
                )),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI predicts → nudges\n→ rewards → change',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete challenges to earn Gude Points and change your financial habits.',
                  style: TextStyle(
                      color: Colors.white60, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('View Rewards →',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('🏆', style: TextStyle(fontSize: 52)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: _C.dark)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _C.lightGrey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.border),
        ),
        child: Text('$count',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.grey)),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// Challenge summary card
// ─────────────────────────────────────────────
class _ChallengeSummaryCard extends StatelessWidget {
  final _Challenge challenge;
  final VoidCallback onTap;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;

  const _ChallengeSummaryCard({
    required this.challenge,
    required this.onTap,
    this.onActivate,
    this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final c    = challenge;
    final done = c.steps.where((s) => s.done).length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: c.active
                ? c.color.withOpacity(0.35)
                : _C.border,
            width: c.active ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.color, c.colorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(c.emoji,
                      style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _C.dark)),
                    Text(c.subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: _C.grey)),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('+${c.rewardPts} pts',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.amber)),
              ),
              const SizedBox(height: 4),
              Text('${c.totalDays} days',
                  style: const TextStyle(
                      fontSize: 10, color: _C.grey)),
            ]),
          ]),

          const SizedBox(height: 12),

          // Progress bar
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: c.progress,
                        minHeight: 6,
                        backgroundColor: c.color.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation(c.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$done/${c.steps.length} steps · ${(c.progress * 100).toInt()}% complete',
                      style: const TextStyle(
                          fontSize: 10, color: _C.grey),
                    ),
                  ]),
            ),
          ]),

          const SizedBox(height: 12),

          // Action row
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.color,
                  side: BorderSide(color: c.color.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Details',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    c.active ? onDeactivate : onActivate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.active ? _C.grey : c.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  c.active ? 'Deactivate' : 'Activate',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Challenge Detail Page
// ════════════════════════════════════════════════════════════
class _ChallengeDetailPage extends StatelessWidget {
  final _Challenge challenge;
  final void Function(int) onStepToggle;
  final VoidCallback onActivate;

  const _ChallengeDetailPage({
    required this.challenge,
    required this.onStepToggle,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final c    = challenge;
    final done = c.steps.where((s) => s.done).length;

    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(c.title,
            style: const TextStyle(
                color: _C.dark,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.color, c.colorDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: c.color.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.emoji,
                          style: const TextStyle(fontSize: 44)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('+${c.rewardPts} pts',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(c.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(c.subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$done/${c.steps.length} steps done',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      Text('${c.totalDays} days',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ]),
          ),

          const SizedBox(height: 20),

          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About this challenge',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _C.dark)),
                  const SizedBox(height: 8),
                  Text(c.description,
                      style: const TextStyle(
                          fontSize: 13,
                          color: _C.grey,
                          height: 1.55)),
                ]),
          ),

          const SizedBox(height: 20),

          // Steps checklist
          const Text('Steps to Complete',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.dark)),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: c.steps.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, indent: 56, color: Color(0xFFF0F0F0)),
              itemBuilder: (_, i) {
                final step = c.steps[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  leading: GestureDetector(
                    onTap: () => onStepToggle(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: step.done
                            ? c.color
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: step.done ? c.color : _C.border,
                          width: 1.5,
                        ),
                      ),
                      child: step.done
                          ? const Icon(Icons.check,
                              size: 15, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: step.done ? _C.grey : _C.dark,
                      decoration: step.done
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onActivate,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.active ? _C.grey : c.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                c.active
                    ? 'Deactivate Challenge'
                    : 'Activate Challenge 🚀',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}