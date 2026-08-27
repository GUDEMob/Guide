// lib/features/rewards/presentation/rewards_page.dart
// Rewards — "Gude Vitality" — PDF section 2.8
// Points Balance · Level (Bronze/Silver/Gold) · Rewards · Challenges

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

// ── Additional colours for rewards (not in core theme) ──
class _RewardColors {
  static const green  = Color(0xFF10B981);
  static const amber  = Color(0xFFF59E0B);
  static const blue   = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
  static const gold   = Color(0xFFD4AF37);
  static const silver = Color(0xFFB0B7C3);
  static const bronze = Color(0xFFCD7F32);
}

// ── Level data ───────────────────────────────────────────────
class _Level {
  final String name, emoji;
  final Color color, colorDark;
  final int minPts, maxPts;
  const _Level(this.name, this.emoji, this.color, this.colorDark,
      this.minPts, this.maxPts);
}

const _levels = [
  _Level('Bronze',   '🥉', _RewardColors.bronze, Color(0xFF8B4513),  0,    499),
  _Level('Silver',   '🥈', _RewardColors.silver, Color(0xFF6B7280),  500,  1499),
  _Level('Gold',     '🥇', _RewardColors.gold,   Color(0xFFB8860B),  1500, 2999),
  _Level('Platinum', '💎', Color(0xFF38BDF8),    Color(0xFF0284C7),  3000, 99999),
];

_Level _levelFor(int pts) =>
    _levels.lastWhere((l) => pts >= l.minPts, orElse: () => _levels.first);

// ── Reward items ─────────────────────────────────────────────
class _Reward {
  final String title, description, emoji;
  final int cost;
  final Color color;
  bool claimed;
  _Reward({
    required this.title,
    required this.description,
    required this.emoji,
    required this.cost,
    required this.color,
    this.claimed = false,
  });
}

// ── Challenge data ───────────────────────────────────────────
class _Challenge {
  final String title, description, emoji;
  final int points;
  final Color color;
  bool completed;
  _Challenge({
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    required this.color,
    this.completed = false,
  });
}

// ════════════════════════════════════════════════════════════
//  RewardsPage
// ════════════════════════════════════════════════════════════
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});
  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  int _points = 1200;
  late TabController _tabCtrl;

  final List<_Reward> _rewards = [
    _Reward(
      title: 'R10 Airtime',
      description: 'Any network',
      emoji: '📱',
      cost: 200,
      color: _RewardColors.blue,
    ),
    _Reward(
      title: 'R25 Airtime',
      description: 'Any network',
      emoji: '📶',
      cost: 500,
      color: _RewardColors.purple,
    ),
    _Reward(
      title: 'R50 Grocery Voucher',
      description: 'Checkers or Pick n Pay',
      emoji: '🛒',
      cost: 800,
      color: _RewardColors.green,
    ),
    _Reward(
      title: 'R100 Grocery Voucher',
      description: 'Woolworths Food',
      emoji: '🛍️',
      cost: 1200,
      color: _RewardColors.amber,
    ),
    _Reward(
      title: 'Free Data Bundle',
      description: '1GB any network',
      emoji: '🌐',
      cost: 600,
      color: AppColors.primary,
    ),
    _Reward(
      title: 'Campus Coffee',
      description: 'Partner coffee shops',
      emoji: '☕',
      cost: 350,
      color: const Color(0xFF92400E),
    ),
  ];

  final List<_Challenge> _challenges = [
    _Challenge(
      title: 'No Takeout Week',
      description: 'Cook at home for 7 days straight',
      emoji: '🍳',
      points: 100,
      color: _RewardColors.green,
      completed: false,
    ),
    _Challenge(
      title: 'Log Expense 5 Days',
      description: 'Track every expense for 5 consecutive days',
      emoji: '📊',
      points: 50,
      color: _RewardColors.blue,
      completed: true,
    ),
    _Challenge(
      title: 'Stay in Budget',
      description: 'Don\'t exceed your monthly budget',
      emoji: '✅',
      points: 50,
      color: _RewardColors.amber,
      completed: false,
    ),
    _Challenge(
      title: 'Survive till Month-End',
      description: 'Keep a positive balance on the last day',
      emoji: '💰',
      points: 100,
      color: AppColors.primary,
      completed: false,
    ),
    _Challenge(
      title: 'R0 to R500 Savings',
      description: 'Reach R500 in your savings pocket',
      emoji: '🚀',
      points: 100,
      color: _RewardColors.purple,
      completed: false,
    ),
    _Challenge(
      title: 'NSFAS Delay Survivor',
      description: 'Activate and complete the NSFAS survival plan',
      emoji: '⏳',
      points: 150,
      color: _RewardColors.amber,
      completed: false,
    ),
    _Challenge(
      title: 'Complete Coach Onboarding',
      description: 'Finish setting up your financial profile',
      emoji: '🎓',
      points: 50,
      color: _RewardColors.green,
      completed: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  _Level get _level => _levelFor(_points);
  _Level get _nextLevel {
    final idx = _levels.indexOf(_level);
    return idx < _levels.length - 1 ? _levels[idx + 1] : _levels.last;
  }

  double get _levelProgress {
    final l = _level;
    if (l == _levels.last) return 1.0;
    return ((_points - l.minPts) / (l.maxPts - l.minPts + 1)).clamp(0.0, 1.0);
  }

  void _claimReward(_Reward r) {
    if (_points < r.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need ${r.cost - _points} more points to claim!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() {
      _points -= r.cost;
      r.claimed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 ${r.title} claimed successfully!'),
        backgroundColor: _RewardColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _completeChallenge(_Challenge c) {
    if (c.completed) return;
    setState(() {
      c.completed = true;
      _points += c.points;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🏆 Challenge complete! +${c.points} points earned!'),
        backgroundColor: _RewardColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Gude Vitality',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(children: [
              const Text('⭐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '$_points pts',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Points + level hero ──────────────────────────
          _PointsHero(
            points: _points,
            level: _level,
            nextLevel: _nextLevel,
            progress: _levelProgress,
          ),

          // ── Tab bar ──────────────────────────────────────
          Container(
            color: AppColors.background,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: AppColors.textDark,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: '🎁  Rewards'),
                Tab(text: '🏆  Challenges'),
              ],
            ),
          ),

          // ── Tab content ──────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Rewards tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _HowToEarnCard(),
                    const SizedBox(height: 16),
                    const Text(
                      'Redeem Rewards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _rewards
                          .map((r) => _RewardCard(
                                reward: r,
                                userPoints: _points,
                                onClaim: () => _claimReward(r),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

                // Challenges tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Active Challenges',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._challenges
                        .map((c) => _ChallengeCard(
                              challenge: c,
                              onComplete: () => _completeChallenge(c),
                            ))
                        .toList(),
                    const SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Points Hero card
// ─────────────────────────────────────────────
class _PointsHero extends StatelessWidget {
  final int points;
  final _Level level, nextLevel;
  final double progress;

  const _PointsHero({
    required this.points,
    required this.level,
    required this.nextLevel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final ptsToNext = (nextLevel.minPts - points).clamp(0, 99999);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [level.color, level.colorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(level.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your Level',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
            Text(level.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Text('$points',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              const Text('points',
                  style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(level.name,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(
            level == _levels.last
                ? 'Max Level 🏆'
                : '$ptsToNext pts to ${nextLevel.name} ${nextLevel.emoji}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// How to earn card
// ─────────────────────────────────────────────
class _HowToEarnCard extends StatelessWidget {
  const _HowToEarnCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('+10 pts', 'Log an expense',           '📝'),
      ('+50 pts', 'Stay in budget',           '✅'),
      ('+100 pts','Complete a challenge',     '🏆'),
      ('+10 pts', 'Daily check-in streak',    '🔥'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'How to Earn Points',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) {
            final (pts, label, emoji) = item;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(pts,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  Text(label,
                      style: const TextStyle(fontSize: 9, color: AppColors.textGrey),
                      textAlign: TextAlign.center,
                      maxLines: 2),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Reward Card
// ─────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final _Reward reward;
  final int userPoints;
  final VoidCallback onClaim;

  const _RewardCard({
    required this.reward,
    required this.userPoints,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = userPoints >= reward.cost;
    final claimed   = reward.claimed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: claimed
              ? _RewardColors.green.withOpacity(0.4)
              : canAfford
                  ? reward.color.withOpacity(0.3)
                  : AppColors.inputBorder,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: reward.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: Text(reward.emoji,
                        style: const TextStyle(fontSize: 22))),
              ),
              if (claimed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _RewardColors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Claimed',
                      style: TextStyle(
                          fontSize: 9,
                          color: _RewardColors.green,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(reward.title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(reward.description,
              style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: claimed ? null : onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: claimed
                    ? _RewardColors.green
                    : canAfford
                        ? reward.color
                        : AppColors.surface,
                foregroundColor: canAfford || claimed ? Colors.white : AppColors.textGrey,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                claimed
                    ? '✓ Claimed'
                    : '⭐ ${reward.cost} pts',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Challenge Card
// ─────────────────────────────────────────────
class _ChallengeCard extends StatelessWidget {
  final _Challenge challenge;
  final VoidCallback onComplete;

  const _ChallengeCard(
      {required this.challenge, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final done = challenge.completed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? _RewardColors.green.withOpacity(0.35)
              : challenge.color.withOpacity(0.25),
          width: done ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: done
                ? _RewardColors.green.withOpacity(0.1)
                : challenge.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text(challenge.emoji,
                  style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: done ? AppColors.textGrey : AppColors.textDark,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : null)),
                const SizedBox(height: 2),
                Text(challenge.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: done
                  ? _RewardColors.green.withOpacity(0.1)
                  : challenge.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              done ? '✓ Done' : '+${challenge.points}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: done ? _RewardColors.green : challenge.color),
            ),
          ),
          const SizedBox(height: 6),
          if (!done)
            GestureDetector(
              onTap: onComplete,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: challenge.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Claim',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ]),
    );
  }
}