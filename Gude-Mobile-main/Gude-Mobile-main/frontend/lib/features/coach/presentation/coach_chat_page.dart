// lib/features/coach/presentation/coach_chat_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gude_app/services/user_role_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Colours ─────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
}

// ── Message model ────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isAi;
  final DateTime time;
  const _Msg({required this.text, required this.isAi, required this.time});
}

// ── Suggested prompts ────────────────────────────────────────
const _suggestions = [
  ('How does Gude work?', 'G'),
  ('Help me sell a product', '📦'),
  ('Help me list a service', '🛠️'),
  ('What can I buy on Market?', '🛍️'),
  ('How do I price my skills?', '💼'),
  ('Help me save R500', '💰'),
  ('Build my student budget', '📊'),
  ('Survive till month-end', '📅'),
  ('Explain my Gude Wallet', '👛'),
  ('Find support for me', '❤️'),
  ('I need affordable food', '🥗'),
  ('I feel financially stressed', '🌱'),
  ('NSFAS delay survival plan', '⏳'),
  ('Give me a side-hustle idea', '🚀'),
  ('Set a savings goal', '🎯'),
  ('How can Gude keep me safe?', '🛡️'),
];

// ════════════════════════════════════════════════════════════
//  CoachChatPage
// ════════════════════════════════════════════════════════════
class CoachChatPage extends StatefulWidget {
  const CoachChatPage({super.key});
  @override
  State<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends State<CoachChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _promptScrollCtrl = ScrollController();
  bool _isTyping = false;

  final List<Map<String, String>> _history = [];

  final List<_Msg> _messages = [
    _Msg(
      text: 'Hi! I\'m Ask Gude — your guide to everything in the app.\n\n'
          'I can help you buy or sell on Market, create listings, use your Wallet, build a budget, save money, find support, and navigate student life. Choose a prompt below or ask me anything!',
      isAi: true,
      time: DateTime.now(),
    ),
  ];

  // ── Lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _promptScrollCtrl.dispose();
    super.dispose();
  }

  void _showNextPrompts() {
    if (!_promptScrollCtrl.hasClients) return;
    final next = (_promptScrollCtrl.offset + 230).clamp(
        0.0, _promptScrollCtrl.position.maxScrollExtent).toDouble();
    _promptScrollCtrl.animateTo(next,
        duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  // ── Load saved chat history ──────────────────────────────
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('chat_history');
    if (saved != null) {
      final list = jsonDecode(saved) as List;
      setState(() {
        _history.addAll(list.cast<Map<String, String>>());
      });
    }
  }

  // ── Save chat history ────────────────────────────────────
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = _history.length > 40
        ? _history.sublist(_history.length - 40)
        : _history;
    await prefs.setString('chat_history', jsonEncode(trimmed));
  }

  // ── System prompt ────────────────────────────────────────
  String _buildSystemPrompt() {
    final svc = UserRoleService();
    return '''
You are AI Buddy, a warm, knowledgeable, and deeply practical financial coach built into the Gude app for South African university students. You are fluent in South African student culture, slang, and the real financial challenges students face.

STUDENT PROFILE:
- Name: ${svc.userName.isNotEmpty ? svc.userName : 'Student'}
- Monthly income: R${svc.monthlyIncome.toStringAsFixed(0)}
- Funding source: ${svc.fundingType.isNotEmpty ? svc.fundingType : 'Unknown'}
- Living situation: ${svc.livingType.isNotEmpty ? svc.livingType : 'Unknown'}
- Financial pain points: ${svc.painPoints.isNotEmpty ? svc.painPoints.join(', ') : 'General budgeting'}

YOUR EXPERTISE COVERS:
1. BUDGETING & MONEY MANAGEMENT
   - Creating student budgets with Rand amounts
   - 50/30/20 rule adapted for low SA student incomes
   - Zero-based budgeting for NSFAS students
   - Tracking daily spend on food, transport, data

2. SAVING STRATEGIES
   - Emergency funds for students (start with R200–R500)
   - Savings challenges (52-week, R1/day, round-up saving)
   - Best SA savings accounts: Capitec, TymeBank, FNB Easy Account
   - Stokvel basics and group savings

3. SOUTH AFRICAN FUNDING & GRANTS
   - NSFAS: allowances, delays, appeal process, what's covered
   - DHET bursaries and how to apply
   - Ikusasa Student Financial Aid Programme (ISFAP)
   - Funza Lushaka for education students
   - Private bursaries: Anglo American, Sasol, Allan Gray Orbis

4. EARNING EXTRA INCOME (SIDE HUSTLES)
   - Tutoring fellow students (R80–R200/hr)
   - Selling food/snacks on campus
   - Freelancing: graphic design, writing, coding on Fiverr/Upwork
   - Campus ambassador programmes
   - Online surveys and micro-tasks
   - Part-time jobs that work around lectures

5. DEBT & CREDIT
   - Understanding student debt and interest
   - How to avoid credit card traps
   - AfriCash, Wonga, and loan shark dangers
   - Building a credit score from scratch
   - NSFAS loan vs bursary components explained

6. FOOD & SURVIVAL ON A BUDGET
   - Cheapest nutritious meals under R20
   - Grocery shopping tips: Checkers, Shoprite, PnP specials
   - Meal prepping for the week
   - Surviving without a kitchen (res life)
   - Campus food banks and soup kitchens

7. TRANSPORT
   - Minibus taxi, MyCiTi, Gautrain costs compared
   - Student discounts on Intercape/Greyhound
   - Carpooling and lift clubs on campus
   - Walking routes vs Uber cost analysis

8. STUDENT LIFE & WELLNESS
   - Dealing with financial stress and anxiety
   - Avoiding peer pressure spending (parties, drinking, clothes)
   - Mental health resources for financially stressed students
   - Free campus resources: clinics, counselling, food parcels

9. DIGITAL & DATA
   - Cheapest data deals: Telkom, MTN, Vodacom, Cell C
   - Campus WiFi spots and free internet access
   - Zero-rated educational sites (NSFAS portal, etc.)

10. FUTURE FINANCIAL PLANNING
    - Opening your first bank account (best free options)
    - Understanding tax (SARS eFiling basics for students)
    - Starting to invest: Easy Equities, unit trusts for beginners
    - Graduate financial planning: first salary budgeting

11. GUDE APP & MARKETPLACE GUIDE
    - Explain the Home, Market, Wallet, and Support Hub tabs
    - Help students switch between Buy and Sell mode in Market
    - Guide product listings: photos, condition, fair pricing, location, and safety
    - Guide service listings: skills, packages, turnaround time, portfolio, and rates
    - Help buyers search, compare, save favourites, message sellers, and checkout
    - Explain Gude Wallet pockets, budgets, savings goals, and transactions
    - Direct students to Quick Income, Budget Help, Food Support, Peer Tutoring,
      counselling, mentorship, and the weekly wellbeing check-in
    - Promote safe trading: use in-app messages, confirm details, meet publicly,
      protect personal information, and report suspicious behaviour

When explaining navigation, use the exact tab and button names shown in Gude.

RESPONSE RULES:
- Always use South African Rand (R) for all amounts
- Be conversational, warm, and encouraging — like a smart older sibling
- Use simple language, avoid heavy financial jargon
- Give specific, actionable advice with real Rand amounts
- Reference real SA brands, apps, and services students know
- Keep responses under 220 words unless the student asks for detail
- Use bullet points or numbered steps when listing options
- If the student seems stressed, acknowledge their feelings first
- Never judge spending choices — guide gently instead
- If you don't know something specific (e.g., a student's exact campus costs), make reasonable SA estimates and say so
- End responses with an encouraging note or a follow-up question to keep them engaged
''';
  }

  // ── Scroll helper ────────────────────────────────────────
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Call Claude via proxy ────────────────────────────────
  Future<String> _callClaude(String latestText) async {
    // 🔧 Change this URL depending on your platform:
    //   Android emulator  → http://10.0.2.2:3000/chat
    //   iOS simulator     → http://localhost:3000/chat
    //   Physical device   → http://<YOUR_LAN_IP>:3000/chat
    const proxyUrl =
        'https://gude-proxy-6rpug1e3g-unathi-qamzas-projects.vercel.app/chat';

    final messages = _history
        .where((m) => m['role'] != null && m['content'] != null)
        .toList();

    try {
      final res = await http
          .post(
            Uri.parse(proxyUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'claude-haiku-4-5-20251001',
              'max_tokens': 600,
              'system': _buildSystemPrompt(),
              'messages': messages,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Anthropic response shape: { content: [ { type: 'text', text: '...' } ] }
        final content = data['content'] as List?;
        if (content != null && content.isNotEmpty) {
          return content
              .where((b) => b['type'] == 'text')
              .map((b) => b['text'] as String)
              .join('\n')
              .trim();
        }
        return _offlineAnswer(latestText);
      } else {
        debugPrint('Proxy error ${res.statusCode}: ${res.body}');
        return _offlineAnswer(latestText);
      }
    } catch (e) {
      debugPrint('_callClaude error: $e');
      return _offlineAnswer(latestText);
    }
  }

  // ── Send message ─────────────────────────────────────────
  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();

    setState(() {
      _messages.add(_Msg(text: text.trim(), isAi: false, time: DateTime.now()));
      _history.add({'role': 'user', 'content': text.trim()});
      _isTyping = true;
    });
    _scrollToBottom();

    final reply = await _callClaude(text.trim());

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_Msg(text: reply, isAi: true, time: DateTime.now()));
      _history.add({'role': 'assistant', 'content': reply});
    });
    _scrollToBottom();

    await _saveHistory();
  }

  String _offlineAnswer(String prompt) {
    final q = prompt.toLowerCase();
    if (q.contains('service')) {
      return 'To list a service, open Market, switch to Sell, then tap the blue tools icon. Add a clear title, what is included, turnaround time, price, availability, and examples of your work. A useful student starting range is often R80–R250 depending on the skill.';
    }
    if (q.contains('product') || q.contains('sell')) {
      return 'Open Market, switch to Sell, and tap the red product-box icon. Add bright photos, the real condition, a fair price, your location, and whether the price is negotiable. Keep messages in Gude and meet in a busy public place.';
    }
    if (q.contains('market') || q.contains('buy')) {
      return 'Use Market in Buy mode to browse products and student services. Search by name, swipe through categories, save favourites with the heart, compare prices, and open a listing before messaging the seller or adding it to your cart.';
    }
    if (q.contains('support') || q.contains('food') || q.contains('stress')) {
      return 'Open Support Hub for Quick Income, Budget Help, Food Support, Peer Tutoring, counselling, mentorship, and your weekly wellbeing check-in. If money stress feels overwhelming, start with Talk to Someone — asking for support is a strong move.';
    }
    if (q.contains('wallet')) {
      return 'Your Gude Wallet shows your balance, transactions, budgets, savings goals, and spending categories. Use Budget to set limits, Goals to save for something specific, and Transact when you need to move money.';
    }
    if (q.contains('save')) {
      return 'Let’s make saving realistic: choose a target, divide it by the days left, and move that amount first. For R500 in 30 days, save about R17 daily or R125 weekly. Create a Wallet goal and fund it after each allowance or sale.';
    }
    if (q.contains('budget') || q.contains('month')) {
      return 'Start with food, transport, data, and study costs. Subtract those from your monthly income, keep a small emergency buffer, then divide the remainder into a daily limit. Open Wallet → Budget to create category limits you can actually follow.';
    }
    return 'I can guide you through Gude Market, buying and selling, product or service listings, Wallet, budgeting, saving, Quick Income, food support, tutoring, counselling, mentorship, and student money decisions. Tell me your goal and I’ll turn it into simple next steps.';
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ask Gude',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _C.dark)),
              Text('Market, money and student support',
                  style: TextStyle(fontSize: 10, color: _C.grey)),
            ],
          ),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: _C.green, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              const Text('Online',
                  style: TextStyle(
                      fontSize: 11,
                      color: _C.green,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_messages.length == 1) _AskGudeIntro(onPrompt: _send),

          // ── Chat messages ────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return const _TypingBubble();
                }
                return _ChatBubble(msg: _messages[i]);
              },
            ),
          ),

          // ── Suggested prompts ────────────────────────────
          Container(
            height: 58,
            color: Colors.white,
            child: Stack(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(left: 14, top: 2),
                  child: Text('Swipe for more ideas',
                      style: TextStyle(fontSize: 9, color: _C.grey)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _promptScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 54, 6),
                    itemCount: _suggestions.length,
                    itemBuilder: (_, i) {
                      final (label, emoji) = _suggestions[i];
                      return GestureDetector(
                        onTap: () => _send(label),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _C.lightGrey,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _C.border),
                          ),
                          child: Row(children: [
                            Text(emoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(label,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _C.dark)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
              Positioned(
                right: 7,
                bottom: 7,
                child: Material(
                  color: _C.primary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _showNextPrompts,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          // ── Input bar ────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom +
                  8,
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _C.lightGrey,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _C.border),
                  ),
                  child: TextField(
                    controller: _inputCtrl,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    style: const TextStyle(fontSize: 14, color: _C.dark),
                    decoration: const InputDecoration(
                      hintText: 'Ask Gude anything...',
                      hintStyle: TextStyle(color: _C.grey, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_inputCtrl.text),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _C.dark,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
} // ← _CoachChatPageState closes HERE

// ════════════════════════════════════════════════════════════
//  Chat Bubble
// ════════════════════════════════════════════════════════════
class _AskGudeIntro extends StatelessWidget {
  final ValueChanged<String> onPrompt;
  const _AskGudeIntro({required this.onPrompt});

  @override
  Widget build(BuildContext context) {
    const capabilities = [
      ('Buy & sell', Icons.storefront_outlined, Color(0xFFE30613),
          'Show me how to buy and sell on Gude'),
      ('Money help', Icons.savings_outlined, Color(0xFF10B981),
          'Help me make a money plan'),
      ('Find support', Icons.favorite_outline_rounded, Color(0xFFEC4899),
          'Which Support Hub resource is right for me?'),
      ('Use Gude', Icons.explore_outlined, Color(0xFF7C4DFF),
          'Give me a tour of the Gude app'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F2), Color(0xFFF4EEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.primary.withOpacity(0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.waving_hand_rounded, color: _C.amber, size: 19),
          SizedBox(width: 8),
          Expanded(
            child: Text('What can Ask Gude do?',
                style: TextStyle(
                    color: _C.dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 4),
        const Text('Tap a topic for friendly, step-by-step help.',
            style: TextStyle(color: _C.grey, fontSize: 11)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: capabilities.map((item) {
            final (label, icon, color, prompt) = item;
            return InkWell(
              onTap: () => onPrompt(prompt),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.18)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isAi = msg.isAi;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAi) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 15))),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  decoration: BoxDecoration(
                    color: isAi ? Colors.white : _C.dark,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAi ? 4 : 16),
                      bottomRight: Radius.circular(isAi ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                        fontSize: 13,
                        color: isAi ? _C.dark : Colors.white,
                        height: 1.5),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(msg.time),
                  style: const TextStyle(fontSize: 10, color: _C.grey),
                ),
              ],
            ),
          ),
          if (!isAi) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('😊', style: TextStyle(fontSize: 15))),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Typing Bubble
// ════════════════════════════════════════════════════════════
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 15))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
              ],
            ),
            child: Row(children: [
              _Dot(anim: _anim, delay: 0),
              const SizedBox(width: 4),
              _Dot(anim: _anim, delay: 0.2),
              const SizedBox(width: 4),
              _Dot(anim: _anim, delay: 0.4),
            ]),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Dot (typing animation)
// ════════════════════════════════════════════════════════════
class _Dot extends StatelessWidget {
  final Animation<double> anim;
  final double delay;
  const _Dot({required this.anim, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final v = (anim.value - delay).clamp(0.0, 1.0);
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: Color.lerp(const Color(0xFFCCCCCC), _C.grey, v),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
