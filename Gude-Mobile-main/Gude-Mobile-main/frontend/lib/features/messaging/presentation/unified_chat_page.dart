// lib/features/messaging/presentation/unified_chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Colours ───────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF3B82F6);
}

// ════════════════════════════════════════════════════════════
// MESSAGING MODELS
// ════════════════════════════════════════════════════════════
class _Message {
  final String senderId, text;
  final DateTime time;
  final bool isRead;
  const _Message({
    required this.senderId,
    required this.text,
    required this.time,
    this.isRead = true,
  });
}

class _Conversation {
  final String id, name, avatarLetter, context;
  final bool isOnline, isBuyer, isFavourite;
  List<_Message> messages;

  _Conversation({
    required this.id,
    required this.name,
    required this.avatarLetter,
    required this.context,
    required this.messages,
    this.isOnline = false,
    this.isBuyer = true,
    this.isFavourite = false,
  });

  String get lastMessageText => messages.isEmpty ? '' : messages.last.text;
  DateTime? get lastMessageTime => messages.isEmpty ? null : messages.last.time;
  bool get hasUnread => messages.any((m) => m.senderId != 'me' && !m.isRead);
}

// ════════════════════════════════════════════════════════════
// COMMUNITY MODELS
// ════════════════════════════════════════════════════════════
class _BlockedUsers {
  static final Set<String> _blocked = {};
  static void block(String id) => _blocked.add(id);
  static void unblock(String id) => _blocked.remove(id);
  static bool isBlocked(String id) => _blocked.contains(id);
}

class _ReportedUsers {
  static final Set<String> _reported = {};
  static void report(String id) => _reported.add(id);
}

class _Participant {
  final String id, name, university, area, avatarLetter;
  final Color avatarColor;
  final bool isOnline;
  const _Participant({
    required this.id,
    required this.name,
    required this.university,
    required this.area,
    required this.avatarLetter,
    required this.avatarColor,
    this.isOnline = false,
  });
}

class _GroupMessage {
  final String id, senderId, senderName, senderAvatar, text;
  final DateTime time;
  final bool isMe;
  _GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.time,
    required this.isMe,
  });
}

class _PrivateMessage {
  final String text, senderId;
  final DateTime time;
  _PrivateMessage(this.senderId, this.text, this.time);
}

// ════════════════════════════════════════════════════════════
// SEED DATA
// ════════════════════════════════════════════════════════════
List<_Conversation> _buildConversations() {
  final now = DateTime.now();
  return [
    _Conversation(
      id: 'b1',
      name: 'Vanessa Top',
      avatarLetter: 'VT',
      context: 'HP Laptop',
      isOnline: true,
      isBuyer: true,
      isFavourite: true,
      messages: [
        _Message(
            senderId: 'b1',
            text: 'Good morning! Are we still on for today?',
            time: now.subtract(const Duration(minutes: 5)),
            isRead: false),
        _Message(
            senderId: 'me',
            text: 'Yes, I\'ll meet you at 2pm.',
            time: now.subtract(const Duration(minutes: 3))),
        _Message(
            senderId: 'b1',
            text: 'Perfect, see you then 😊',
            time: now.subtract(const Duration(minutes: 1)),
            isRead: false),
      ],
    ),
    _Conversation(
      id: 'b2',
      name: 'Paul Gabler',
      avatarLetter: 'PG',
      context: 'Maths Tutoring',
      isOnline: false,
      isBuyer: true,
      messages: [
        _Message(
            senderId: 'b2',
            text: 'Thank you so much for the session!',
            time: now.subtract(const Duration(hours: 2))),
      ],
    ),
    _Conversation(
      id: 'b3',
      name: 'Mia Scott',
      avatarLetter: 'MS',
      context: 'Graphic Design',
      isOnline: true,
      isBuyer: true,
      messages: [
        _Message(
            senderId: 'b3',
            text: 'Can you send me the final files?',
            time: now.subtract(const Duration(hours: 4)),
            isRead: false),
      ],
    ),
    _Conversation(
      id: 'b4',
      name: 'David Pred',
      avatarLetter: 'DP',
      context: 'Study Table',
      isBuyer: false,
      messages: [
        _Message(
            senderId: 'me',
            text: 'Are you writing tomorrow?',
            time: now.subtract(const Duration(days: 1))),
        _Message(
            senderId: 'b4',
            text: 'Yes, let\'s study together.',
            time: now.subtract(const Duration(hours: 20)),
            isRead: false),
      ],
    ),
    _Conversation(
      id: 'b5',
      name: 'Mason Margelis',
      avatarLetter: 'MM',
      context: 'Photography',
      messages: [
        _Message(
            senderId: 'b5',
            text: 'Let\'s meet at the plaza at 2pm',
            time: now.subtract(const Duration(days: 2))),
      ],
    ),
    _Conversation(
      id: 'b6',
      name: 'Stacey Clerk',
      avatarLetter: 'SC',
      context: 'iPhone 12',
      isOnline: true,
      isBuyer: true,
      messages: [
        _Message(
            senderId: 'me',
            text: 'I can deliver tomorrow.',
            time: now.subtract(const Duration(days: 3))),
      ],
    ),
  ];
}

const _participants = [
  _Participant(
      id: 'me',
      name: 'You',
      university: 'UJ',
      area: 'Johannesburg',
      avatarLetter: 'Y',
      avatarColor: _C.primary,
      isOnline: true),
  _Participant(
      id: 'p1',
      name: 'Thabo Nkosi',
      university: 'Wits',
      area: 'Johannesburg',
      avatarLetter: 'TN',
      avatarColor: Color(0xFF3B82F6),
      isOnline: true),
  _Participant(
      id: 'p2',
      name: 'Lerato Dlamini',
      university: 'UJ',
      area: 'Johannesburg',
      avatarLetter: 'LD',
      avatarColor: Color(0xFF10B981),
      isOnline: false),
  _Participant(
      id: 'p3',
      name: 'Sipho Mahlangu',
      university: 'TUT',
      area: 'Johannesburg',
      avatarLetter: 'SM',
      avatarColor: Color(0xFFF59E0B),
      isOnline: true),
  _Participant(
      id: 'p4',
      name: 'Aisha Patel',
      university: 'Wits',
      area: 'Johannesburg',
      avatarLetter: 'AP',
      avatarColor: Color(0xFF8B5CF6),
      isOnline: false),
  _Participant(
      id: 'p5',
      name: 'Keanu Naidoo',
      university: 'UJ',
      area: 'Johannesburg',
      avatarLetter: 'KN',
      avatarColor: Color(0xFFEC4899),
      isOnline: true),
  _Participant(
      id: 'p6',
      name: 'Nomsa Zulu',
      university: 'TUT',
      area: 'Johannesburg',
      avatarLetter: 'NZ',
      avatarColor: Color(0xFF059669),
      isOnline: false),
  _Participant(
      id: 'p7',
      name: 'David Mokoena',
      university: 'Wits',
      area: 'Johannesburg',
      avatarLetter: 'DM',
      avatarColor: Color(0xFFDC2626),
      isOnline: true),
  _Participant(
      id: 'p8',
      name: 'Fatima Hassan',
      university: 'UJ',
      area: 'Johannesburg',
      avatarLetter: 'FH',
      avatarColor: Color(0xFF7C3AED),
      isOnline: false),
  _Participant(
      id: 'p9',
      name: 'Luca Ferreira',
      university: 'TUT',
      area: 'Johannesburg',
      avatarLetter: 'LF',
      avatarColor: Color(0xFF0891B2),
      isOnline: true),
  _Participant(
      id: 'p10',
      name: 'Zanele Khumalo',
      university: 'Wits',
      area: 'Johannesburg',
      avatarLetter: 'ZK',
      avatarColor: Color(0xFF65A30D),
      isOnline: false),
  _Participant(
      id: 'p11',
      name: 'Reza Moosagie',
      university: 'UJ',
      area: 'Johannesburg',
      avatarLetter: 'RM',
      avatarColor: Color(0xFFB45309),
      isOnline: true),
];

List<_GroupMessage> _buildGroupMessages() {
  final now = DateTime.now();
  return [
    _GroupMessage(
        id: 'm1',
        senderId: 'p1',
        senderName: 'Thabo N.',
        senderAvatar: 'TN',
        text:
            'Hey everyone! Anyone need help with Maths? I\'m offering tutoring this weekend 📚',
        time: now.subtract(const Duration(hours: 3)),
        isMe: false),
    _GroupMessage(
        id: 'm2',
        senderId: 'p3',
        senderName: 'Sipho M.',
        senderAvatar: 'SM',
        text:
            'I\'m looking for a graphic designer for a small project. Budget R200. DM me 🎨',
        time: now.subtract(const Duration(hours: 2, minutes: 30)),
        isMe: false),
    _GroupMessage(
        id: 'm3',
        senderId: 'me',
        senderName: 'You',
        senderAvatar: 'Y',
        text: 'Hey Sipho, I do design work! I\'ll message you.',
        time: now.subtract(const Duration(hours: 2, minutes: 15)),
        isMe: true),
    _GroupMessage(
        id: 'm4',
        senderId: 'p2',
        senderName: 'Lerato D.',
        senderAvatar: 'LD',
        text: 'Anyone selling a second-hand laptop? Preferably under R3000 💻',
        time: now.subtract(const Duration(hours: 1, minutes: 45)),
        isMe: false),
    _GroupMessage(
        id: 'm5',
        senderId: 'p5',
        senderName: 'Keanu N.',
        senderAvatar: 'KN',
        text: 'Study group for CS201 this Thursday at the library? 5pm? 🎓',
        time: now.subtract(const Duration(hours: 1)),
        isMe: false),
    _GroupMessage(
        id: 'm6',
        senderId: 'p7',
        senderName: 'David M.',
        senderAvatar: 'DM',
        text: 'I\'m in for Thursday!',
        time: now.subtract(const Duration(minutes: 45)),
        isMe: false),
    _GroupMessage(
        id: 'm7',
        senderId: 'me',
        senderName: 'You',
        senderAvatar: 'Y',
        text: 'Thursday works for me too 👍',
        time: now.subtract(const Duration(minutes: 30)),
        isMe: true),
    _GroupMessage(
        id: 'm8',
        senderId: 'p9',
        senderName: 'Luca F.',
        senderAvatar: 'LF',
        text: 'Anyone know a good spot to get cheap groceries near UJ?',
        time: now.subtract(const Duration(minutes: 10)),
        isMe: false),
  ];
}

// ════════════════════════════════════════════════════════════
// UNIFIED CHAT PAGE  (WhatsApp style)
// ════════════════════════════════════════════════════════════
class UnifiedChatPage extends StatefulWidget {
  const UnifiedChatPage({super.key});
  @override
  State<UnifiedChatPage> createState() => _UnifiedChatPageState();
}

class _UnifiedChatPageState extends State<UnifiedChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // ── Chats tab state ──────────────────────────────────────
  final List<_Conversation> _conversations = _buildConversations();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── Community tab state ──────────────────────────────────
  final List<_GroupMessage> _groupMessages = _buildGroupMessages();
  final _groupMsgCtrl = TextEditingController();
  final _groupScrollCtrl = ScrollController();
  final Map<String, List<_PrivateMessage>> _privateChats = {};
  final Set<String> _deletedIds = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _seedPrivateChats();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _groupMsgCtrl.dispose();
    _groupScrollCtrl.dispose();
    super.dispose();
  }

  void _seedPrivateChats() {
    final now = DateTime.now();
    _privateChats['p1'] = [
      _PrivateMessage('p1', 'Hey! Still available for that design project?',
          now.subtract(const Duration(hours: 2))),
      _PrivateMessage('me', 'Yes still available! What do you need?',
          now.subtract(const Duration(hours: 1, minutes: 50))),
      _PrivateMessage('p1', 'A logo for my tutoring brand. Budget R200',
          now.subtract(const Duration(hours: 1, minutes: 40))),
    ];
    _privateChats['p3'] = [
      _PrivateMessage('p3', 'Still interested in the graphic design gig?',
          now.subtract(const Duration(hours: 3))),
      _PrivateMessage('me', 'Yes! Send me the brief when ready',
          now.subtract(const Duration(hours: 2, minutes: 55))),
    ];
  }

  // ── Helpers ──────────────────────────────────────────────
  int get _unreadCount => _conversations.where((c) => c.hasUnread).length;

  List<_Conversation> get _filtered => _conversations.where((c) {
        if (_searchQuery.isEmpty) return true;
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.context.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${t.day}/${t.month}';
  }

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _fmtDate(DateTime t) {
    final now = DateTime.now();
    if (t.day == now.day) return 'Today';
    if (t.day == now.day - 1) return 'Yesterday';
    return '${t.day} ${[
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][t.month]}';
  }

  int get _onlineCount => _participants
      .where((p) => p.isOnline && !_BlockedUsers.isBlocked(p.id))
      .length;

  List<_GroupMessage> get _visibleMessages => _groupMessages
      .where((m) =>
          !_deletedIds.contains(m.id) && !_BlockedUsers.isBlocked(m.senderId))
      .toList();

  void _scrollGroupToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_groupScrollCtrl.hasClients) {
        _groupScrollCtrl.animateTo(
          _groupScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Actions ──────────────────────────────────────────────
  void _openDirectChat(_Conversation conv) async {
    final updated = await Navigator.push<_Conversation>(
      context,
      MaterialPageRoute(builder: (_) => _DirectChatPage(conversation: conv)),
    );
    if (updated != null) {
      setState(() {
        final idx = _conversations.indexWhere((c) => c.id == updated.id);
        if (idx >= 0) _conversations[idx] = updated;
      });
    }
  }

  void _sendGroupMessage() {
    final text = _groupMsgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _groupMessages.add(_GroupMessage(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        senderName: 'You',
        senderAvatar: 'Y',
        text: text,
        time: DateTime.now(),
        isMe: true,
      ));
      _groupMsgCtrl.clear();
    });
    _scrollGroupToBottom();
  }

  void _openCommunityPrivateChat(
      String participantId, String name, String avatar) {
    _privateChats.putIfAbsent(participantId, () => []);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CommunityPrivateChatPage(
          participantId: participantId,
          participantName: name,
          participantAvatar: avatar,
          messages: _privateChats[participantId]!,
          onSend: (text) {
            setState(() {
              _privateChats[participantId]!
                  .add(_PrivateMessage('me', text, DateTime.now()));
            });
          },
        ),
      ),
    );
  }

  void _showGroupMessageOptions(_GroupMessage msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '"${msg.text.length > 60 ? '${msg.text.substring(0, 60)}…' : msg.text}"',
              style: const TextStyle(
                  fontSize: 13, color: _C.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          if (!msg.isMe)
            _OptionTile(
              icon: Icons.reply_rounded,
              label: 'Message ${msg.senderName} privately',
              color: _C.blue,
              onTap: () {
                Navigator.pop(context);
                _openCommunityPrivateChat(
                    msg.senderId, msg.senderName, msg.senderAvatar);
              },
            ),
          _OptionTile(
            icon: Icons.copy_rounded,
            label: 'Copy message',
            color: _C.dark,
            onTap: () {
              Clipboard.setData(ClipboardData(text: msg.text));
              Navigator.pop(context);
              _showSnack('Message copied');
            },
          ),
          if (msg.isMe)
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete message',
              color: _C.primary,
              onTap: () {
                setState(() => _deletedIds.add(msg.id));
                Navigator.pop(context);
                _showSnack('Message deleted');
              },
            ),
          if (!msg.isMe) ...[
            _OptionTile(
              icon: Icons.flag_outlined,
              label: 'Report ${msg.senderName}',
              color: const Color(0xFFF59E0B),
              onTap: () {
                _ReportedUsers.report(msg.senderId);
                Navigator.pop(context);
                _showSnack('${msg.senderName} reported');
              },
            ),
            _OptionTile(
              icon: _BlockedUsers.isBlocked(msg.senderId)
                  ? Icons.do_not_disturb_off_rounded
                  : Icons.block_rounded,
              label: _BlockedUsers.isBlocked(msg.senderId)
                  ? 'Unblock ${msg.senderName}'
                  : 'Block ${msg.senderName}',
              color: _C.primary,
              onTap: () {
                setState(() {
                  if (_BlockedUsers.isBlocked(msg.senderId)) {
                    _BlockedUsers.unblock(msg.senderId);
                    _showSnack('${msg.senderName} unblocked');
                  } else {
                    _BlockedUsers.block(msg.senderId);
                    _showSnack('${msg.senderName} blocked');
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final visibleParticipants =
        _participants.where((p) => !_BlockedUsers.isBlocked(p.id)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const Text('Messages',
              style: TextStyle(
                  color: _C.dark, fontWeight: FontWeight.w800, fontSize: 18)),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _C.primary, borderRadius: BorderRadius.circular(12)),
              child: Text('$_unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: _C.dark, size: 22),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _C.primary,
          unselectedLabelColor: _C.grey,
          indicatorColor: _C.primary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            // ── Tab 1: Chats ──
            Tab(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Chats'),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: _C.primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('$_unreadCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
            ),
            // ── Tab 2: Community ──
            Tab(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Community'),
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                      color: _C.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('$_onlineCount',
                      style: const TextStyle(
                          color: _C.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ════════════════════════════════════════════════
          // TAB 1 — CHATS (Private 1-to-1)
          // ════════════════════════════════════════════════
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: _SearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.message_outlined,
                                  size: 48, color: _C.grey),
                              SizedBox(height: 12),
                              Text('No messages yet',
                                  style:
                                      TextStyle(color: _C.grey, fontSize: 14)),
                            ]),
                      )
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, indent: 72, color: _C.border),
                        itemBuilder: (_, i) {
                          final c = _filtered[i];
                          return InkWell(
                            onTap: () => _openDirectChat(c),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 11),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          _C.primary.withOpacity(0.12),
                                      child: Text(c.avatarLetter,
                                          style: const TextStyle(
                                              color: _C.primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13)),
                                    ),
                                    if (c.isOnline)
                                      Positioned(
                                        bottom: 1,
                                        right: 1,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: _C.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5)),
                                        ),
                                      ),
                                  ]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(c.name,
                                                style: TextStyle(
                                                    fontWeight: c.hasUnread
                                                        ? FontWeight.w800
                                                        : FontWeight.w600,
                                                    fontSize: 14,
                                                    color: _C.dark)),
                                          ),
                                          Text(_formatTime(c.lastMessageTime),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: c.hasUnread
                                                      ? _C.primary
                                                      : _C.grey)),
                                        ]),
                                        const SizedBox(height: 2),
                                        Row(children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: c.isBuyer
                                                  ? _C.primary.withOpacity(0.08)
                                                  : _C.blue.withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              c.isBuyer
                                                  ? '🛒 ${c.context}'
                                                  : '🎓 ${c.context}',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: c.isBuyer
                                                      ? _C.primary
                                                      : _C.blue,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ]),
                                        const SizedBox(height: 3),
                                        Row(children: [
                                          if (c.messages.isNotEmpty &&
                                              c.messages.last.senderId == 'me')
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 4),
                                              child: Icon(
                                                  Icons.done_all_rounded,
                                                  size: 13,
                                                  color: _C.primary),
                                            ),
                                          Expanded(
                                            child: Text(c.lastMessageText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: c.hasUnread
                                                        ? _C.dark
                                                        : _C.grey,
                                                    fontWeight: c.hasUnread
                                                        ? FontWeight.w600
                                                        : FontWeight.normal)),
                                          ),
                                          if (c.hasUnread)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 6),
                                              width: 9,
                                              height: 9,
                                              decoration: const BoxDecoration(
                                                  color: _C.primary,
                                                  shape: BoxShape.circle),
                                            ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // ════════════════════════════════════════════════
          // TAB 2 — COMMUNITY (Group + community private)
          // ════════════════════════════════════════════════
          Column(
            children: [
              // Members banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: _C.primary.withOpacity(0.06),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        color: _C.primary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${visibleParticipants.length} students · $_onlineCount online · Johannesburg',
                      style: const TextStyle(
                          color: _C.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showParticipantsSheet(visibleParticipants),
                      child: const Text('See all',
                          style: TextStyle(
                              color: _C.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

              // Group messages
              Expanded(
                child: ListView.builder(
                  controller: _groupScrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: _visibleMessages.length,
                  itemBuilder: (_, i) {
                    final msg = _visibleMessages[i];
                    final showDate = i == 0 ||
                        _visibleMessages[i - 1].time.day != msg.time.day;
                    return Column(children: [
                      if (showDate)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(_fmtDate(msg.time),
                              style: const TextStyle(
                                  color: _C.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                      GestureDetector(
                        onLongPress: () => _showGroupMessageOptions(msg),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: msg.isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!msg.isMe) ...[
                                GestureDetector(
                                  onTap: () => _openCommunityPrivateChat(
                                      msg.senderId,
                                      msg.senderName,
                                      msg.senderAvatar),
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        _C.primary.withOpacity(0.12),
                                    child: Text(msg.senderAvatar,
                                        style: const TextStyle(
                                            color: _C.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 9)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.70),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: msg.isMe ? _C.primary : _C.lightGrey,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft:
                                          Radius.circular(msg.isMe ? 16 : 4),
                                      bottomRight:
                                          Radius.circular(msg.isMe ? 4 : 16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!msg.isMe)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 3),
                                          child: Text(msg.senderName,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: _C.primary
                                                      .withOpacity(0.8))),
                                        ),
                                      Text(msg.text,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: msg.isMe
                                                  ? Colors.white
                                                  : _C.dark,
                                              height: 1.4)),
                                      const SizedBox(height: 3),
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(_fmt(msg.time),
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: msg.isMe
                                                        ? Colors.white60
                                                        : _C.grey)),
                                            if (msg.isMe) ...[
                                              const SizedBox(width: 3),
                                              const Icon(Icons.done_all_rounded,
                                                  size: 12,
                                                  color: Colors.white70),
                                            ],
                                          ]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]);
                  },
                ),
              ),

              // Group input
              _ChatInput(controller: _groupMsgCtrl, onSend: _sendGroupMessage),
            ],
          ),
        ],
      ),
    );
  }

  void _showParticipantsSheet(List<_Participant> participants) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, sc) => Column(children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Group Members (${participants.length})',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _C.dark)),
          const SizedBox(height: 4),
          const Text('Johannesburg Area',
              style: TextStyle(fontSize: 12, color: _C.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: sc,
              itemCount: participants.length,
              itemBuilder: (_, i) {
                final p = participants[i];
                if (p.id == 'me') return const SizedBox.shrink();
                return ListTile(
                  leading: Stack(children: [
                    CircleAvatar(
                      backgroundColor: p.avatarColor,
                      child: Text(p.avatarLetter,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                    if (p.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: _C.green,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5)),
                        ),
                      ),
                  ]),
                  title: Text(p.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: _C.dark)),
                  subtitle: Text('${p.university} · ${p.area}',
                      style: const TextStyle(fontSize: 11, color: _C.grey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        color: _C.blue, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _openCommunityPrivateChat(p.id, p.name, p.avatarLetter);
                    },
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// DIRECT CHAT PAGE (1-to-1 from Chats tab)
// ════════════════════════════════════════════════════════════
class _DirectChatPage extends StatefulWidget {
  final _Conversation conversation;
  const _DirectChatPage({required this.conversation});
  @override
  State<_DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<_DirectChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late _Conversation _conv;

  @override
  void initState() {
    super.initState();
    _conv = widget.conversation;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _conv.messages
          .add(_Message(senderId: 'me', text: text, time: DateTime.now()));
      _msgCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final replies = [
        'Thanks!',
        'Sounds good!',
        'Let me check.',
        'Perfect!',
        'Noted!'
      ];
      setState(() {
        _conv.messages.add(_Message(
          senderId: _conv.id,
          text: replies[DateTime.now().millisecond % replies.length],
          time: DateTime.now(),
          isRead: false,
        ));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime t) {
    final now = DateTime.now();
    if (t.day == now.day) return 'Today';
    if (t.day == now.day - 1) return 'Yesterday';
    return '${t.day} ${[
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][t.month]}';
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.pop(context, _conv);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _C.dark),
            onPressed: () => Navigator.pop(context, _conv),
          ),
          title: Row(children: [
            Stack(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _C.primary.withOpacity(0.12),
                child: Text(_conv.avatarLetter,
                    style: const TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
              if (_conv.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                          color: _C.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5))),
                ),
            ]),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_conv.name,
                  style: const TextStyle(
                      color: _C.dark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text(_conv.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                      color: _conv.isOnline ? _C.green : _C.grey,
                      fontSize: 11)),
            ]),
          ]),
          actions: [
            IconButton(
                icon: const Icon(Icons.videocam_outlined,
                    color: _C.dark, size: 22),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.call_outlined,
                    color: _C.primary, size: 20),
                onPressed: () {}),
          ],
        ),
        body: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _C.primary.withOpacity(0.06),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: _C.primary, size: 14),
              const SizedBox(width: 6),
              Text('Re: ${_conv.context}',
                  style: const TextStyle(
                      color: _C.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _conv.messages.length,
              itemBuilder: (_, i) {
                final msg = _conv.messages[i];
                final isMe = msg.senderId == 'me';
                final showDate =
                    i == 0 || _conv.messages[i - 1].time.day != msg.time.day;
                return Column(children: [
                  if (showDate)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(_fmtDate(msg.time),
                          style: const TextStyle(
                              color: _C.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(
                              radius: 13,
                              backgroundColor: _C.primary.withOpacity(0.12),
                              child: Text(_conv.avatarLetter,
                                  style: const TextStyle(
                                      color: _C.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9))),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.68),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? _C.primary : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(msg.text,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isMe ? Colors.white : _C.dark,
                                          height: 1.4)),
                                  const SizedBox(height: 3),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_fmt(msg.time),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: isMe
                                                    ? Colors.white70
                                                    : _C.grey)),
                                        if (isMe) ...[
                                          const SizedBox(width: 3),
                                          Icon(Icons.done_all_rounded,
                                              size: 13,
                                              color: msg.isRead
                                                  ? Colors.white
                                                  : Colors.white54),
                                        ],
                                      ]),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]);
              },
            ),
          ),
          _ChatInput(controller: _msgCtrl, onSend: _send),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// COMMUNITY PRIVATE CHAT PAGE
// ════════════════════════════════════════════════════════════
class _CommunityPrivateChatPage extends StatefulWidget {
  final String participantId, participantName, participantAvatar;
  final List<_PrivateMessage> messages;
  final void Function(String) onSend;

  const _CommunityPrivateChatPage({
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.messages,
    required this.onSend,
  });

  @override
  State<_CommunityPrivateChatPage> createState() =>
      _CommunityPrivateChatPageState();
}

class _CommunityPrivateChatPageState extends State<_CommunityPrivateChatPage> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late List<_PrivateMessage> _msgs;

  @override
  void initState() {
    super.initState();
    _msgs = widget.messages;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    setState(() {
      _msgs = [...widget.messages];
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final replies = [
        'Got it!',
        'Sure!',
        'Let me check.',
        'Sounds good!',
        '👍'
      ];
      setState(() {
        widget.messages.add(_PrivateMessage(
            widget.participantId,
            replies[DateTime.now().millisecond % replies.length],
            DateTime.now()));
        _msgs = [...widget.messages];
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _C.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          CircleAvatar(
              radius: 17,
              backgroundColor: _C.primary.withOpacity(0.12),
              child: Text(widget.participantAvatar,
                  style: const TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.participantName,
                style: const TextStyle(
                    color: _C.dark, fontWeight: FontWeight.w700, fontSize: 14)),
            const Text('Community member',
                style: TextStyle(color: _C.grey, fontSize: 10)),
          ]),
        ]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: _C.dark),
            onSelected: (val) {
              if (val == 'report') {
                _ReportedUsers.report(widget.participantId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${widget.participantName} reported')));
              } else if (val == 'block') {
                _BlockedUsers.block(widget.participantId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${widget.participantName} blocked')));
                Navigator.pop(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'report', child: Text('Report user')),
              const PopupMenuItem(
                  value: 'block',
                  child:
                      Text('Block user', style: TextStyle(color: _C.primary))),
            ],
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: _C.primary.withOpacity(0.06),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Row(children: [
            const Icon(Icons.lock_outline_rounded, color: _C.primary, size: 13),
            const SizedBox(width: 6),
            Text('Private chat with ${widget.participantName}',
                style: const TextStyle(
                    color: _C.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: _msgs.length,
            itemBuilder: (_, i) {
              final msg = _msgs[i];
              final isMe = msg.senderId == 'me';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.70),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? _C.primary : _C.lightGrey,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(msg.text,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: isMe ? Colors.white : _C.dark,
                                      height: 1.4)),
                              const SizedBox(height: 3),
                              Text(_fmt(msg.time),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white60 : _C.grey)),
                            ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _ChatInput(controller: _ctrl, onSend: _send),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: _C.lightGrey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.border)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: _C.dark),
        decoration: const InputDecoration(
          hintText: 'Search messages…',
          hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: _C.grey, size: 18),
          contentPadding: EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _C.border))),
      child: Row(children: [
        IconButton(
            icon:
                const Icon(Icons.attach_file_rounded, color: _C.grey, size: 20),
            onPressed: () {}),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: _C.lightGrey,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _C.border)),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Type a message…',
                hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 40,
            height: 40,
            decoration:
                const BoxDecoration(color: _C.primary, shape: BoxShape.circle),
            child:
                const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
    );
  }
}
