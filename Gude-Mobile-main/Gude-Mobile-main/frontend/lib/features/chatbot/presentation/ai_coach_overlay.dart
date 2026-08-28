// lib/features/chatbot/presentation/ai_coach_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gude_app/features/chatbot/services/ai_coach_service.dart';

const _red = Color(0xFFE30613);
const _redDark = Color(0xFFC0000F);
const _dark = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);
const _offWhite = Color(0xFFF8F8F8);
const _success = Color(0xFF10B981);

// IMPORTANT: paste your key as defaultValue for local testing.
// For production use a backend proxy — never ship a real key in an app.
const _kAnthropicKey = String.fromEnvironment(
  'ANTHROPIC_API_KEY',
  defaultValue: '', // e.g. 'sk-ant-api03-xxxxx'
);

// ── AiCoachFab ───────────────────────────────────────────────────────────────
class AiCoachFab extends StatefulWidget {
  final CoachContext context;
  const AiCoachFab({super.key, required this.context});
  @override
  State<AiCoachFab> createState() => _AiCoachFabState();
}

class _AiCoachFabState extends State<AiCoachFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _openCoach() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _CoachSheet(coachContext: widget.context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nudge = AiCoachService.getContextualNudge(widget.context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) =>
              Opacity(opacity: 0.85 + _pulse.value * 0.15, child: child),
          child: GestureDetector(
            onTap: _openCoach,
            child: Container(
              margin: const EdgeInsets.only(right: 4, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _dark,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Text(nudge,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        GestureDetector(
          onTap: _openCoach,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) => Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 64 + _pulse.value * 6,
                  height: 64 + _pulse.value * 6,
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.15 * _pulse.value),
                    shape: BoxShape.circle,
                  ),
                ),
                child!,
              ],
            ),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_red, _redDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _red.withOpacity(0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Center(
                  child: Text('🎓', style: TextStyle(fontSize: 26))),
            ),
          ),
        ),
      ],
    );
  }
}

// ── _CoachSheet ───────────────────────────────────────────────────────────────
class _CoachSheet extends StatefulWidget {
  final CoachContext coachContext;
  const _CoachSheet({required this.coachContext});
  @override
  State<_CoachSheet> createState() => _CoachSheetState();
}

class _CoachSheetState extends State<_CoachSheet> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _focusNode = FocusNode();
  bool _isTyping = false;
  bool _inputActive = false;
  late List<CoachMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = AiCoachService.getWelcomeMessages(widget.coachContext);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _input.clear();
    _focusNode.unfocus();
    HapticFeedback.lightImpact();

    final prev = _messages
        .map((m) => CoachMessage(
              text: m.text,
              isUser: m.isUser,
              timestamp: m.timestamp,
              quickReplies: const [],
            ))
        .toList();

    setState(() {
      _messages = [...prev, CoachMessage(text: text, isUser: true)];
      _isTyping = true;
    });
    _scrollToBottom();

    final reply = await _callApi(text);
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages = [
        ..._messages,
        CoachMessage(
            text: reply, isUser: false, quickReplies: _followUps(text)),
      ];
    });
    _scrollToBottom();
  }

  Future<String> _callApi(String userMessage) async {
    if (_kAnthropicKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _fallback(userMessage);
    }
    try {
      final history = <Map<String, String>>[];
      for (final m in _messages) {
        if (m.text.isNotEmpty) {
          history.add(
              {'role': m.isUser ? 'user' : 'assistant', 'content': m.text});
        }
      }
      history.add({'role': 'user', 'content': userMessage});

      final res = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _kAnthropicKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': 'claude-sonnet-4-20250514',
              'max_tokens': 350,
              'system': AiCoachService.buildSystemPrompt(widget.coachContext),
              'messages': history,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>;
        return (content.first as Map<String, dynamic>)['text'] as String;
      }
      debugPrint('Coach API error ${res.statusCode}: ${res.body}');
      return _fallback(userMessage);
    } catch (e) {
      debugPrint('Coach exception: $e');
      return _fallback(userMessage);
    }
  }

  String _fallback(String msg) {
    final lower = msg.toLowerCase();
    final ctx = widget.coachContext;
    final pct = ((ctx.totalSpent / ctx.monthlyBudget) * 100).round();
    final rem = (ctx.monthlyBudget - ctx.totalSpent).toStringAsFixed(0);
    final bal = ctx.walletBalance.toStringAsFixed(0);

    if (lower.contains('overspend') ||
        (lower.contains('where') && lower.contains('spend'))) {
      return "Looking at your wallet, you've used $pct% of your R${ctx.monthlyBudget.toStringAsFixed(0)} budget. Entertainment (R380 vs R150 budget) and Transport (R420 vs R300) are the biggest over-budget categories. Open the Budget Planner to adjust your limits 💡";
    }
    if (lower.contains('budget tip') ||
        lower.contains('save money') ||
        lower.contains('cut')) {
      return "Quick budget wins 🎯\n\n1. Cut Entertainment from R380 → R200\n2. Pack lunch 3× a week (saves ~R150/month)\n3. Gautrain instead of Uber saves ~R40/trip\n\nThat's potentially R330/month back in your pocket. You currently have R$rem left this month.";
    }
    if (lower.contains('budget')) {
      return "You've used $pct% of your R${ctx.monthlyBudget.toStringAsFixed(0)} budget with R$rem remaining. ${pct > 80 ? "That's cutting it close — I'd avoid any big non-essential purchases right now." : "You're managing okay, but tightening up on Entertainment and Transport would help."} Tap Budget Planner in your Wallet for the full breakdown 📊";
    }
    if (lower.contains('earn') ||
        lower.contains('gig') ||
        lower.contains('income') ||
        lower.contains('make money')) {
      return "You've earned R${ctx.income.toStringAsFixed(0)} from ${ctx.marketplaceActivity} gigs this month 🚀\n\nTop earners on Gude right now:\n• Tutoring — R150–R300/hr\n• Graphic design — R200–R500/project\n• Coding help — R180–R400/session\n\nList a new service in Marketplace to boost your income this week.";
    }
    if (lower.contains('sav') || lower.contains('goal')) {
      return "The 50/30/20 rule works well for students:\n\n• 50% Needs → R${(ctx.monthlyBudget * 0.5).toStringAsFixed(0)}\n• 30% Wants → R${(ctx.monthlyBudget * 0.3).toStringAsFixed(0)}\n• 20% Savings → R${(ctx.monthlyBudget * 0.2).toStringAsFixed(0)}/month\n\nSet up a Savings Goal in your Wallet tab. Even R50/week compounds into real money by year end 💰";
    }
    if (lower.contains('stability') || lower.contains('score')) {
      return "Your ${ctx.stabilityScore}/100 stability score breakdown:\n\n• Financial Health (35%) — spending vs budget\n• Marketplace Activity (30%) — ${ctx.marketplaceActivity} gigs ✅\n• App Engagement (20%) — keep checking in\n• Wellbeing Check-ins (15%) — ${ctx.missedCheckins} missed ⚠️\n\nCompleting your missed check-in${ctx.missedCheckins != 1 ? 's' : ''} could add ~${ctx.missedCheckins * 3} points 📈";
    }
    if (lower.contains('transport') ||
        lower.contains('uber') ||
        lower.contains('gautrain')) {
      return "Transport is eating R420 vs your R300 budget — R120 over 🚌\n\nFixes:\n• Gautrain instead of Uber saves ~R40/trip\n• Carpool with classmates on regular routes\n• Check if your campus has a free shuttle\n\nCutting 3 Uber trips/week could save you R300+ monthly.";
    }
    if (lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('lunch')) {
      return "Food is at R650 vs a R500 budget 🍔\n\nHacks:\n• Campus cafeteria is 30–50% cheaper than restaurants\n• Batch cook on Sundays — rice, eggs, veg feeds you for R80/3 days\n• Check Support Hub for campus food bank locations\n\nSaving R150/month on food brings you back under budget.";
    }
    if (lower.contains('stress') ||
        lower.contains('struggling') ||
        lower.contains('difficult')) {
      return "It's okay to feel the pressure — student life is genuinely tough 💙\n\nWhat I'd suggest right now:\n• Check the Support Hub in the app for campus resources\n• Financial aid offices can help with emergency funds\n• Free counselling is available on most campuses\n\nYou don't have to figure this out alone. What's weighing on you most?";
    }
    if (lower.contains('balance') || lower.contains('wallet')) {
      return "Your current wallet balance is R$bal. You've spent R${ctx.totalSpent.toStringAsFixed(0)} of your R${ctx.monthlyBudget.toStringAsFixed(0)} budget ($pct%). ${pct > 80 ? "I'd be cautious about big purchases right now." : "You're in decent shape — keep tracking your spending."} Head to your Wallet tab for the full breakdown 💳";
    }
    return "Based on your profile — R$bal balance, $pct% budget used, ${ctx.stabilityScore}/100 stability — ${pct > 80 ? "I'd focus on cutting discretionary spending first. You're close to your limit." : "you're doing reasonably well! Focus on growing your marketplace income to build a buffer."}\n\nWhat specific area would you like help with?";
  }

  List<String> _followUps(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('budget') || lower.contains('spend')) {
      return ['Top categories', 'Set new limits', 'How to save more'];
    }
    if (lower.contains('earn') || lower.contains('gig')) {
      return ['Top-paying gigs', 'How to get clients', 'Track income'];
    }
    if (lower.contains('sav') || lower.contains('goal')) {
      return ['Create savings goal', '50/30/20 rule', 'Best savings tips'];
    }
    if (lower.contains('stab') || lower.contains('score')) {
      return ['Improve my score', 'Do my check-in', 'Marketplace tips'];
    }
    return ['Budget tips', 'How to earn more', 'Improve stability'];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _CoachHeader(ctx: widget.coachContext),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length)
                  return const _TypingIndicator();
                return _MessageBubble(
                    message: _messages[i], onQuickReply: _send);
              },
            ),
          ),
          _InputBar(
            controller: _input,
            focusNode: _focusNode,
            onSend: _send,
            isActive: _inputActive,
            onActiveChange: (v) => setState(() => _inputActive = v),
          ),
        ]),
      ),
    );
  }
}

// ── _CoachHeader ──────────────────────────────────────────────────────────────
class _CoachHeader extends StatelessWidget {
  final CoachContext ctx;
  const _CoachHeader({required this.ctx});

  Color get _scoreColor {
    if (ctx.stabilityScore >= 75) return _success;
    if (ctx.stabilityScore >= 55) return const Color(0xFFF59E0B);
    return _red;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_red, _redDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: _red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child:
              const Center(child: Text('🎓', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AI Buddy',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _dark)),
          Row(children: [
            Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: _success, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Your AI financial coach',
                style: TextStyle(fontSize: 11, color: _grey)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _scoreColor.withOpacity(0.3), width: 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${ctx.stabilityScore}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _scoreColor,
                    height: 1)),
            Text('Stability',
                style: TextStyle(
                    fontSize: 9,
                    color: _scoreColor.withOpacity(0.8),
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

// ── _MessageBubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final CoachMessage message;
  final void Function(String) onQuickReply;
  const _MessageBubble({required this.message, required this.onQuickReply});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_red, _redDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Text('🎓', style: TextStyle(fontSize: 13))),
                ),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? _red : _offWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(message.text,
                      style: TextStyle(
                          fontSize: 13.5,
                          color: isUser ? Colors.white : _dark,
                          height: 1.5)),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 4, left: isUser ? 0 : 36, right: isUser ? 2 : 0),
            child: Text(_fmt(message.timestamp),
                style: const TextStyle(fontSize: 9.5, color: _grey)),
          ),
          if (message.quickReplies.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 36),
                itemCount: message.quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => onQuickReply(message.quickReplies[i]),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border:
                          Border.all(color: _red.withOpacity(0.4), width: 1),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4)
                      ],
                    ),
                    child: Text(message.quickReplies[i],
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: _red,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── _TypingIndicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 500)));
    _anims = List.generate(3, (i) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
      return Tween<double>(begin: 0, end: -6)
          .animate(CurvedAnimation(parent: _ctrls[i], curve: Curves.easeInOut));
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [_red, _redDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            shape: BoxShape.circle,
          ),
          child:
              const Center(child: Text('🎓', style: TextStyle(fontSize: 13))),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: _offWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
                3,
                (i) => AnimatedBuilder(
                      animation: _anims[i],
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _anims[i].value),
                        child: Container(
                          width: 7,
                          height: 7,
                          margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                          decoration: BoxDecoration(
                              color: _red.withOpacity(0.6),
                              shape: BoxShape.circle),
                        ),
                      ),
                    )),
          ),
        ),
      ]),
    );
  }
}

// ── _InputBar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSend;
  final bool isActive;
  final void Function(bool) onActiveChange;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isActive,
    required this.onActiveChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _offWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    isActive ? _red.withOpacity(0.4) : const Color(0xFFE8E8E8),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: () => onActiveChange(true),
              onSubmitted: onSend,
              textInputAction: TextInputAction.send,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(fontSize: 14, color: _dark),
              decoration: const InputDecoration(
                hintText: 'Ask AI Buddy anything...',
                hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFFAAAAAA)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => onSend(controller.text),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_red, _redDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _red.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child:
                const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}
