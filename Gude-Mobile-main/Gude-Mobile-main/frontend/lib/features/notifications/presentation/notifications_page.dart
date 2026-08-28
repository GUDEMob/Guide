// lib/features/notifications/presentation/notifications_page.dart
// Notifications / Nudges — PDF section 2.9
// Smart nudges from AI: overspending alerts, saving reminders, streak updates

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

// ── Nudge type ────────────────────────────────────────────────
enum _NudgeType { warning, tip, reward, info, challenge }

extension _NudgeExt on _NudgeType {
  Color get color => {
        _NudgeType.warning:   _C.primary,
        _NudgeType.tip:       _C.blue,
        _NudgeType.reward:    _C.amber,
        _NudgeType.info:      _C.grey,
        _NudgeType.challenge: _C.green,
      }[this]!;

  IconData get icon => {
        _NudgeType.warning:   Icons.warning_amber_rounded,
        _NudgeType.tip:       Icons.lightbulb_outline,
        _NudgeType.reward:    Icons.emoji_events_outlined,
        _NudgeType.info:      Icons.info_outline,
        _NudgeType.challenge: Icons.flag_outlined,
      }[this]!;
}

// ── Notification model ────────────────────────────────────────
class _Nudge {
  final String title, body, timeAgo;
  final _NudgeType type;
  final String? actionLabel, actionRoute;
  bool read;

  _Nudge({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.type,
    this.actionLabel,
    this.actionRoute,
    this.read = false,
  });
}

// ════════════════════════════════════════════════════════════
//  NotificationsPage
// ════════════════════════════════════════════════════════════
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_Nudge> _nudges = [
    // PDF examples + extras matching app data
    _Nudge(
      title: 'Overspending Alert 🔴',
      body: 'You\'re overspending on food. You\'ve used R650 of your R800 budget — '
          'only R150 left for the month.',
      timeAgo: 'Just now',
      type: _NudgeType.warning,
      actionLabel: 'View Budget',
      actionRoute: '/wallet/budget',
    ),
    _Nudge(
      title: 'Save R50 today 💡',
      body: 'Save R50 today to stay on track with your monthly savings goal. '
          'Your Laptop Fund needs R2,000 more.',
      timeAgo: '10 min ago',
      type: _NudgeType.tip,
      actionLabel: 'Save Now',
      actionRoute: '/wallet/savings',
    ),
    _Nudge(
      title: 'Transport budget exceeded ⚠️',
      body: 'Your transport spending (R420) has exceeded your R300 budget. '
          'Consider Gautrain for long-distance trips.',
      timeAgo: '1 hr ago',
      type: _NudgeType.warning,
      actionLabel: 'Adjust Budget',
      actionRoute: '/wallet/budget',
    ),
    _Nudge(
      title: '🔥 5-day streak! Keep it up!',
      body: 'You\'ve logged expenses for 5 days in a row. '
          'You\'ve earned 50 Gude Points! Keep the streak alive.',
      timeAgo: '2 hrs ago',
      type: _NudgeType.reward,
      actionLabel: 'View Rewards',
      actionRoute: '/rewards',
    ),
    _Nudge(
      title: 'Mid-month balance check 📊',
      body: 'You have R1,250 left with 12 days to go — that\'s R104/day. '
          'You\'re on track if you reduce entertainment spend.',
      timeAgo: '3 hrs ago',
      type: _NudgeType.info,
    ),
    _Nudge(
      title: 'New Challenge Available 🏆',
      body: '"No Takeout Week" challenge is now active. '
          'Complete it to earn 100 Gude Points and level up to Gold.',
      timeAgo: 'Yesterday',
      type: _NudgeType.challenge,
      actionLabel: 'Start Challenge',
      actionRoute: '/rewards',
    ),
    _Nudge(
      title: 'NSFAS Payment Incoming 🏛️',
      body: 'Based on typical NSFAS cycles, a payment may be due soon. '
          'Plan your month-end budget now to avoid stress.',
      timeAgo: 'Yesterday',
      type: _NudgeType.tip,
      actionLabel: 'View Plan',
      actionRoute: '/coach/chat',
    ),
    _Nudge(
      title: 'Savings goal milestone 🎯',
      body: 'Your Laptop Savings goal is 61% complete — R3,200 of R5,200 saved! '
          'You\'re 8 months away at your current rate.',
      timeAgo: '2 days ago',
      type: _NudgeType.reward,
      actionLabel: 'View Goals',
      actionRoute: '/wallet/savings',
      read: true,
    ),
    _Nudge(
      title: 'Entertainment overspend 🎮',
      body: 'Entertainment spend is R380 vs a R150 budget — 153% over! '
          'Your AI Coach recommends cutting 1 subscription.',
      timeAgo: '2 days ago',
      type: _NudgeType.warning,
      actionLabel: 'Ask Coach',
      actionRoute: '/coach/chat',
      read: true,
    ),
    _Nudge(
      title: 'R0 to R500 Challenge update 🚀',
      body: 'You\'re 38% through the R0 to R500 savings challenge — R190 saved. '
          'Great progress! Keep going.',
      timeAgo: '3 days ago',
      type: _NudgeType.challenge,
      actionLabel: 'View Savings',
      actionRoute: '/wallet/savings',
      read: true,
    ),
  ];

  int get _unreadCount => _nudges.where((n) => !n.read).length;

  void _markAllRead() => setState(() {
        for (final n in _nudges) {
          n.read = true;
        }
      });

  void _dismissNudge(int index) {
    setState(() => _nudges.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification dismissed'),
        backgroundColor: _C.dark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _nudges.where((n) => !n.read).toList();
    final read   = _nudges.where((n) => n.read).toList();

    return Scaffold(
      backgroundColor: _C.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(children: [
          const Text('Notifications',
              style: TextStyle(
                  color: _C.dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$_unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(
                      color: _C.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _nudges.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Unread section ──────────────────────────
                if (unread.isNotEmpty) ...[
                  _SectionHeader(
                      label: 'New',
                      count: unread.length,
                      color: _C.primary),
                  const SizedBox(height: 10),
                  ...unread.asMap().entries.map((e) {
                    final index = _nudges.indexOf(e.value);
                    return _NudgeTile(
                      nudge: e.value,
                      onTap: () {
                        setState(() => e.value.read = true);
                        if (e.value.actionRoute != null) {
                          context.push(e.value.actionRoute!);
                        }
                      },
                      onDismiss: () => _dismissNudge(index),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // ── Read section ────────────────────────────
                if (read.isNotEmpty) ...[
                  _SectionHeader(
                      label: 'Earlier',
                      count: read.length,
                      color: _C.grey),
                  const SizedBox(height: 10),
                  ...read.asMap().entries.map((e) {
                    final index = _nudges.indexOf(e.value);
                    return _NudgeTile(
                      nudge: e.value,
                      onTap: () {
                        if (e.value.actionRoute != null) {
                          context.push(e.value.actionRoute!);
                        }
                      },
                      onDismiss: () => _dismissNudge(index),
                    );
                  }),
                ],
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionHeader(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _C.dark)),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('$count',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color)),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// Nudge tile (swipe to dismiss)
// ─────────────────────────────────────────────
class _NudgeTile extends StatelessWidget {
  final _Nudge nudge;
  final VoidCallback onTap, onDismiss;

  const _NudgeTile(
      {required this.nudge,
      required this.onTap,
      required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(nudge.title + nudge.timeAgo),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _C.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: nudge.read ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: nudge.read
                  ? _C.border
                  : nudge.type.color.withOpacity(0.3),
              width: nudge.read ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(
                      nudge.read ? 0.03 : 0.06),
                  blurRadius: nudge.read ? 4 : 10,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: nudge.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(nudge.type.icon,
                    color: nudge.type.color, size: 20),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(nudge.title,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: nudge.read
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                  color: nudge.read
                                      ? _C.grey
                                      : _C.dark)),
                        ),
                        if (!nudge.read)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: nudge.type.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ]),
                      const SizedBox(height: 4),
                      Text(nudge.body,
                          style: TextStyle(
                              fontSize: 12,
                              color: nudge.read
                                  ? const Color(0xFFAAAAAA)
                                  : _C.grey,
                              height: 1.45),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(nudge.timeAgo,
                              style: const TextStyle(
                                  fontSize: 10, color: _C.grey)),
                          if (nudge.actionLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: nudge.type.color
                                    .withOpacity(0.08),
                                borderRadius:
                                    BorderRadius.circular(8),
                                border: Border.all(
                                    color: nudge.type.color
                                        .withOpacity(0.25)),
                              ),
                              child: Text(nudge.actionLabel!,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: nudge.type.color)),
                            ),
                        ],
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _C.lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
                child: Text('🔔',
                    style: TextStyle(fontSize: 38))),
          ),
          const SizedBox(height: 16),
          const Text('All caught up!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _C.dark)),
          const SizedBox(height: 8),
          const Text('No new notifications right now.',
              style: TextStyle(fontSize: 13, color: _C.grey)),
        ],
      ),
    );
  }
}