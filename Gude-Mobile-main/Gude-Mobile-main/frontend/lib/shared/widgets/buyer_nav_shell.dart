// lib/shared/widgets/buyer_nav_shell.dart
// Buyer-specific bottom navigation shell — distinct from student BottomNavShell
// Navy color scheme, no wallet/stability/chats tabs
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerNavShell extends StatelessWidget {
  final Widget child;
  const BuyerNavShell({super.key, required this.child});

  static const _tabs = [
    _Tab(path: '/buyer/marketplace', icon: Icons.storefront_outlined,     activeIcon: Icons.storefront_rounded,       label: 'Marketplace'),
    _Tab(path: '/buyer/messages',    icon: Icons.chat_bubble_outline,      activeIcon: Icons.chat_bubble_rounded,      label: 'Messages'),
    _Tab(path: '/buyer/profile',     icon: Icons.person_outline_rounded,   activeIcon: Icons.person_rounded,           label: 'Profile'),
  ];

  static const _navBlue = Color(0xFF1A3A8F);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIdx = _tabs.indexWhere((t) => location.startsWith(t.path));
    final activeIdx = currentIdx < 0 ? 0 : currentIdx;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = i == activeIdx;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(tab.path),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(active ? tab.activeIcon : tab.icon, color: active ? _navBlue : const Color(0xFF9E9E9E), size: 22),
                      const SizedBox(height: 3),
                      Text(tab.label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? _navBlue : const Color(0xFF9E9E9E))),
                      if (active) ...[
                        const SizedBox(height: 2),
                        Container(width: 16, height: 2, decoration: BoxDecoration(color: _navBlue, borderRadius: BorderRadius.circular(1))),
                      ],
                    ]),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String path, label;
  final IconData icon, activeIcon;
  const _Tab({required this.path, required this.icon, required this.activeIcon, required this.label});
}


// ─────────────────────────────────────────────────────────────────────
// BUYER MESSAGES PAGE
// Connects buyers with sellers/students. Buyer can ask questions,
// request services, and follow up on orders.
// ─────────────────────────────────────────────────────────────────────

class _BuyerMsg {
  final String senderId, text;
  final DateTime time;
  final bool isRead;
  const _BuyerMsg({required this.senderId, required this.text, required this.time, this.isRead = true});
}

class _BuyerConv {
  final String id, name, initials, context, role; // role: 'seller' or 'student'
  final bool isOnline;
  List<_BuyerMsg> messages;
  _BuyerConv({required this.id, required this.name, required this.initials, required this.context, required this.role, this.isOnline = false, required this.messages});
  String get lastMsg => messages.isEmpty ? '' : messages.last.text;
  DateTime? get lastTime => messages.isEmpty ? null : messages.last.time;
  bool get hasUnread => messages.any((m) => m.senderId != 'buyer_me' && !m.isRead);
}

List<_BuyerConv> _buildBuyerConvs() {
  final now = DateTime.now();
  return [
    _BuyerConv(id: 's1', name: 'Priya S.', initials: 'PS', context: 'CV Writing', role: 'seller', isOnline: true, messages: [
      _BuyerMsg(senderId: 's1', text: 'Hi! I can help with your CV. When do you need it by?', time: now.subtract(const Duration(minutes: 3)), isRead: false),
    ]),
    _BuyerConv(id: 's2', name: 'Yusuf A.', initials: 'YA', context: 'Graphic Design', role: 'seller', messages: [
      _BuyerMsg(senderId: 'buyer_me', text: 'Can you send me sample work?', time: now.subtract(const Duration(hours: 2))),
      _BuyerMsg(senderId: 's2', text: 'Sure! Check my portfolio in my profile.', time: now.subtract(const Duration(hours: 1)), isRead: false),
    ]),
    _BuyerConv(id: 's3', name: 'Nandi M.', initials: 'NM', context: 'Photography Session', role: 'seller', isOnline: true, messages: [
      _BuyerMsg(senderId: 'buyer_me', text: 'Do you have availability next Saturday?', time: now.subtract(const Duration(days: 1))),
    ]),
    _BuyerConv(id: 's4', name: 'Keanu N.', initials: 'KN', context: 'Python Help', role: 'student', messages: [
      _BuyerMsg(senderId: 's4', text: 'I completed the task. Please check your email.', time: now.subtract(const Duration(days: 2))),
    ]),
  ];
}

class BuyerMessagesPage extends StatefulWidget {
  const BuyerMessagesPage({super.key});
  @override
  State<BuyerMessagesPage> createState() => _BuyerMessagesPageState();
}

class _BuyerMessagesPageState extends State<BuyerMessagesPage> {
  final List<_BuyerConv> _convs = _buildBuyerConvs();
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const _navBlue = Color(0xFF1A3A8F);

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  int get _unread => _convs.where((c) => c.hasUnread).length;

  String _fmt(DateTime? t) {
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${t.day}/${t.month}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _convs.where((c) => _query.isEmpty || c.name.toLowerCase().contains(_query.toLowerCase()) || c.context.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const Text('Messages', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w800, fontSize: 18)),
          if (_unread > 0) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _navBlue, borderRadius: BorderRadius.circular(12)), child: Text('$_unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
          ],
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A1A1A), size: 22), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Container(
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE))),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Search messages…', hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Color(0xFF888888), size: 18), contentPadding: EdgeInsets.symmetric(vertical: 11)),
            ),
          ),
        ),
        // Info banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: _navBlue.withOpacity(0.06), borderRadius: BorderRadius.circular(8), border: Border.all(color: _navBlue.withOpacity(0.15))),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: _navBlue, size: 14),
            const SizedBox(width: 8),
            const Expanded(child: Text('Send questions or service requests directly to any student seller', style: TextStyle(fontSize: 11, color: Color(0xFF1A3A8F), height: 1.4))),
          ]),
        ),
        // Conv list
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.message_outlined, size: 48, color: Color(0xFFEEEEEE)), SizedBox(height: 12), Text('No messages yet', style: TextStyle(color: Color(0xFF888888), fontSize: 14))]))
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, color: Color(0xFFEEEEEE)),
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final roleColor = c.role == 'seller' ? _navBlue : const Color(0xFF10B981);
                    return InkWell(
                      onTap: () => _openChat(c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Stack(children: [
                            CircleAvatar(radius: 22, backgroundColor: roleColor.withOpacity(0.12), child: Text(c.initials, style: TextStyle(color: roleColor, fontWeight: FontWeight.w800, fontSize: 13))),
                            if (c.isOnline) Positioned(bottom: 1, right: 1, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
                          ]),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(c.name, style: TextStyle(fontWeight: c.hasUnread ? FontWeight.w800 : FontWeight.w600, fontSize: 14, color: const Color(0xFF1A1A1A)))),
                              Text(_fmt(c.lastTime), style: TextStyle(fontSize: 11, color: c.hasUnread ? _navBlue : const Color(0xFF888888))),
                            ]),
                            const SizedBox(height: 2),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: roleColor.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                                child: Text('${c.role == 'seller' ? '🛒' : '🎓'} ${c.context}', style: TextStyle(fontSize: 9, color: roleColor, fontWeight: FontWeight.w700)),
                              ),
                            ]),
                            const SizedBox(height: 3),
                            Text(c.lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.hasUnread ? const Color(0xFF1A1A1A) : const Color(0xFF888888), fontWeight: c.hasUnread ? FontWeight.w600 : FontWeight.normal)),
                          ])),
                          if (c.hasUnread) ...[const SizedBox(width: 6), Container(width: 9, height: 9, decoration: BoxDecoration(color: _navBlue, shape: BoxShape.circle))],
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  void _openChat(_BuyerConv conv) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => _BuyerChatPage(conv: conv)));
    setState(() {});
  }
}

class _BuyerChatPage extends StatefulWidget {
  final _BuyerConv conv;
  const _BuyerChatPage({required this.conv});
  @override
  State<_BuyerChatPage> createState() => _BuyerChatPageState();
}

class _BuyerChatPageState extends State<_BuyerChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  late _BuyerConv _conv;
  static const _navBlue = Color(0xFF1A3A8F);

  @override
  void initState() { super.initState(); _conv = widget.conv; WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom()); }

  void _scrollBottom() { if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() { _conv.messages.add(_BuyerMsg(senderId: 'buyer_me', text: text, time: DateTime.now())); _ctrl.clear(); });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom());
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  String _fmt(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)), onPressed: () => Navigator.pop(context, _conv)),
        title: Row(children: [
          CircleAvatar(radius: 18, backgroundColor: _navBlue.withOpacity(0.12), child: Text(_conv.initials, style: TextStyle(color: _navBlue, fontWeight: FontWeight.w800, fontSize: 12))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_conv.name, style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 14)),
            Text(_conv.isOnline ? 'Online' : 'Offline', style: TextStyle(color: _conv.isOnline ? const Color(0xFF10B981) : const Color(0xFF888888), fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, color: Color(0xFF1A3A8F), size: 20), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: _navBlue.withOpacity(0.06), child: Row(children: [const Icon(Icons.info_outline_rounded, color: Color(0xFF1A3A8F), size: 14), const SizedBox(width: 6), Text('Re: ${_conv.context}', style: const TextStyle(color: Color(0xFF1A3A8F), fontSize: 12, fontWeight: FontWeight.w600))])),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: _conv.messages.length,
            itemBuilder: (_, i) {
              final msg = _conv.messages[i];
              final isMe = msg.senderId == 'buyer_me';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (!isMe) ...[CircleAvatar(radius: 13, backgroundColor: _navBlue.withOpacity(0.12), child: Text(_conv.initials, style: TextStyle(color: _navBlue, fontWeight: FontWeight.w700, fontSize: 9))), const SizedBox(width: 6)],
                  Flexible(child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? _navBlue : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(msg.text, style: TextStyle(fontSize: 13, color: isMe ? Colors.white : const Color(0xFF1A1A1A), height: 1.4)),
                      const SizedBox(height: 3),
                      Text(_fmt(msg.time), style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : const Color(0xFF888888))),
                    ]),
                  )),
                ]),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
          child: Row(children: [
            Expanded(child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFEEEEEE))),
              child: TextField(controller: _ctrl, onSubmitted: (_) => _send(), style: const TextStyle(fontSize: 13), decoration: const InputDecoration(hintText: 'Ask a question or make a request…', hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
            )),
            const SizedBox(width: 6),
            GestureDetector(onTap: _send, child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF1A3A8F), shape: BoxShape.circle), child: const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
          ]),
        ),
      ]),
    );
  }
}