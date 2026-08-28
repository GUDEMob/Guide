// lib/features/community/presentation/community_chat_page.dart
//
// Features:
//  - Students auto-joined into area group chat on registration
//  - Participant count visible in header
//  - Private chat with any participant (long-press or tap profile)
//  - Delete, Report, Block per message/participant (context menu)
//  - Blocked users reflected on profile (stored in _BlockedUsers)
// ─────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Colors ──────────────────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE30613);
  static const dark      = Color(0xFF1A1A1A);
  static const grey      = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border    = Color(0xFFEEEEEE);
  static const green     = Color(0xFF10B981);
  static const blue      = Color(0xFF3B82F6);
}

// ─── Blocked users registry (simulates profile-linked state) ─────────
class _BlockedUsers {
  static final Set<String> _blocked = {};
  static void block(String userId)    => _blocked.add(userId);
  static void unblock(String userId)  => _blocked.remove(userId);
  static bool isBlocked(String userId) => _blocked.contains(userId);
  static List<String> get all => _blocked.toList();
}

// ─── Reported users registry ──────────────────────────────────────────
class _ReportedUsers {
  static final Set<String> _reported = {};
  static void report(String userId) => _reported.add(userId);
  static bool isReported(String userId) => _reported.contains(userId);
}

// ─── Models ───────────────────────────────────────────────────────────
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

// ─── Seed data ────────────────────────────────────────────────────────
const _participants = [
  _Participant(id: 'me',  name: 'You',             university: 'UJ',   area: 'Johannesburg', avatarLetter: 'Y',  avatarColor: _C.primary, isOnline: true),
  _Participant(id: 'p1',  name: 'Thabo Nkosi',     university: 'Wits', area: 'Johannesburg', avatarLetter: 'TN', avatarColor: Color(0xFF3B82F6), isOnline: true),
  _Participant(id: 'p2',  name: 'Lerato Dlamini',  university: 'UJ',   area: 'Johannesburg', avatarLetter: 'LD', avatarColor: Color(0xFF10B981), isOnline: false),
  _Participant(id: 'p3',  name: 'Sipho Mahlangu',  university: 'TUT',  area: 'Johannesburg', avatarLetter: 'SM', avatarColor: Color(0xFFF59E0B), isOnline: true),
  _Participant(id: 'p4',  name: 'Aisha Patel',     university: 'Wits', area: 'Johannesburg', avatarLetter: 'AP', avatarColor: Color(0xFF8B5CF6), isOnline: false),
  _Participant(id: 'p5',  name: 'Keanu Naidoo',    university: 'UJ',   area: 'Johannesburg', avatarLetter: 'KN', avatarColor: Color(0xFFEC4899), isOnline: true),
  _Participant(id: 'p6',  name: 'Nomsa Zulu',      university: 'TUT',  area: 'Johannesburg', avatarLetter: 'NZ', avatarColor: Color(0xFF059669), isOnline: false),
  _Participant(id: 'p7',  name: 'David Mokoena',   university: 'Wits', area: 'Johannesburg', avatarLetter: 'DM', avatarColor: Color(0xFFDC2626), isOnline: true),
  _Participant(id: 'p8',  name: 'Fatima Hassan',   university: 'UJ',   area: 'Johannesburg', avatarLetter: 'FH', avatarColor: Color(0xFF7C3AED), isOnline: false),
  _Participant(id: 'p9',  name: 'Luca Ferreira',   university: 'TUT',  area: 'Johannesburg', avatarLetter: 'LF', avatarColor: Color(0xFF0891B2), isOnline: true),
  _Participant(id: 'p10', name: 'Zanele Khumalo',  university: 'Wits', area: 'Johannesburg', avatarLetter: 'ZK', avatarColor: Color(0xFF65A30D), isOnline: false),
  _Participant(id: 'p11', name: 'Reza Moosagie',   university: 'UJ',   area: 'Johannesburg', avatarLetter: 'RM', avatarColor: Color(0xFFB45309), isOnline: true),
];

List<_GroupMessage> _buildMessages() {
  final now = DateTime.now();
  return [
    _GroupMessage(id: 'm1', senderId: 'p1', senderName: 'Thabo N.', senderAvatar: 'TN', text: 'Hey everyone! Anyone need help with Maths? I\'m offering tutoring this weekend 📚', time: now.subtract(const Duration(hours: 3)), isMe: false),
    _GroupMessage(id: 'm2', senderId: 'p3', senderName: 'Sipho M.', senderAvatar: 'SM', text: 'I\'m looking for a graphic designer for a small project. Budget R200. DM me 🎨', time: now.subtract(const Duration(hours: 2, minutes: 30)), isMe: false),
    _GroupMessage(id: 'm3', senderId: 'me', senderName: 'You', senderAvatar: 'Y', text: 'Hey Sipho, I do design work! I\'ll message you.', time: now.subtract(const Duration(hours: 2, minutes: 15)), isMe: true),
    _GroupMessage(id: 'm4', senderId: 'p2', senderName: 'Lerato D.', senderAvatar: 'LD', text: 'Anyone selling a second-hand laptop? Preferably under R3000 💻', time: now.subtract(const Duration(hours: 1, minutes: 45)), isMe: false),
    _GroupMessage(id: 'm5', senderId: 'p5', senderName: 'Keanu N.', senderAvatar: 'KN', text: 'Study group for CS201 this Thursday at the library? 5pm? 🎓', time: now.subtract(const Duration(hours: 1)), isMe: false),
    _GroupMessage(id: 'm6', senderId: 'p7', senderName: 'David M.', senderAvatar: 'DM', text: 'I\'m in for Thursday!', time: now.subtract(const Duration(minutes: 45)), isMe: false),
    _GroupMessage(id: 'm7', senderId: 'me', senderName: 'You', senderAvatar: 'Y', text: 'Thursday works for me too 👍', time: now.subtract(const Duration(minutes: 30)), isMe: true),
    _GroupMessage(id: 'm8', senderId: 'p9', senderName: 'Luca F.', senderAvatar: 'LF', text: 'Anyone know a good spot to get cheap groceries near UJ?', time: now.subtract(const Duration(minutes: 10)), isMe: false),
  ];
}

// ─── Private conversation model ───────────────────────────────────────
class _PrivateMessage {
  final String text, senderId;
  final DateTime time;
  _PrivateMessage(this.senderId, this.text, this.time);
}

// ─── Community Chat Page ───────────────────────────────────────────────
class ChatsChatPage extends StatefulWidget {
  const ChatsChatPage({super.key});
  @override
  State<ChatsChatPage> createState() => _ChatsChatPageState();
}

class _ChatsChatPageState extends State<ChatsChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final List<_GroupMessage> _messages = _buildMessages();
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  // Private chat threads: participantId -> messages
  final Map<String, List<_PrivateMessage>> _privateChats = {};
  // Deleted message IDs
  final Set<String> _deletedIds = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this, initialIndex: 0);
    _seedPrivateChats();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _seedPrivateChats() {
    final now = DateTime.now();
    _privateChats['p1'] = [
      _PrivateMessage('p1', 'Hey! Still available for that design project?', now.subtract(const Duration(hours: 2))),
      _PrivateMessage('me', 'Yes still available! What do you need?', now.subtract(const Duration(hours: 1, minutes: 50))),
      _PrivateMessage('p1', 'A logo for my tutoring brand. Budget R200', now.subtract(const Duration(hours: 1, minutes: 40))),
    ];
    _privateChats['p3'] = [
      _PrivateMessage('p3', 'Still interested in the graphic design gig?', now.subtract(const Duration(hours: 3))),
      _PrivateMessage('me', 'Yes! Send me the brief when ready', now.subtract(const Duration(hours: 2, minutes: 55))),
    ];
    _privateChats['p5'] = [
      _PrivateMessage('p5', 'Are you joining the CS201 study group Thursday?', now.subtract(const Duration(minutes: 45))),
      _PrivateMessage('me', 'Definitely! See you at 5pm', now.subtract(const Duration(minutes: 30))),
      _PrivateMessage('p5', "Perfect, I'll bring notes from last week", now.subtract(const Duration(minutes: 15))),
    ];
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_GroupMessage(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        senderName: 'You',
        senderAvatar: 'Y',
        text: text,
        time: DateTime.now(),
        isMe: true,
      ));
      _msgCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  int get _onlineCount =>
      _participants.where((p) => p.isOnline && !_BlockedUsers.isBlocked(p.id)).length;

  List<_GroupMessage> get _visibleMessages =>
      _messages.where((m) =>
          !_deletedIds.contains(m.id) &&
          !_BlockedUsers.isBlocked(m.senderId)).toList();

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showMessageOptions(_GroupMessage msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          // Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '"${msg.text.length > 60 ? '${msg.text.substring(0, 60)}…' : msg.text}"',
              style: const TextStyle(fontSize: 13, color: _C.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          if (!msg.isMe) ...[
            _OptionTile(
              icon: Icons.reply_rounded,
              label: 'Message ${msg.senderName} privately',
              color: _C.blue,
              onTap: () {
                Navigator.pop(context);
                _openPrivateChat(msg.senderId, msg.senderName, msg.senderAvatar);
              },
            ),
          ],
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
                    _showSnack('${msg.senderName} blocked — reflected on your profile');
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

  void _openPrivateChat(String participantId, String name, String avatar) {
    _privateChats.putIfAbsent(participantId, () => []);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PrivateChatPage(
          participantId:    participantId,
          participantName:  name,
          participantAvatar: avatar,
          messages: _privateChats[participantId]!,
          onSend: (text) {
            setState(() {
              _privateChats[participantId]!.add(
                _PrivateMessage('me', text, DateTime.now()),
              );
            });
          },
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleParticipants = _participants
        .where((p) => !_BlockedUsers.isBlocked(p.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chats',
                style: TextStyle(
                    color: _C.dark, fontWeight: FontWeight.w800, fontSize: 18)),
            Text(
              'Johannesburg · ${visibleParticipants.length} members · $_onlineCount online',
              style: const TextStyle(color: _C.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          // Participants avatar stack
          GestureDetector(
            onTap: () => _showParticipantsSheet(visibleParticipants),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 60, height: 36,
                    child: Stack(
                      children: List.generate(
                        visibleParticipants.take(3).length,
                        (i) {
                          final p = visibleParticipants[i];
                          return Positioned(
                            left: i * 18.0,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: p.avatarColor,
                              child: Text(p.avatarLetter,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Text(
                    '+${(visibleParticipants.length - 3).clamp(0, 999)}',
                    style: const TextStyle(
                        color: _C.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _C.primary,
          unselectedLabelColor: _C.grey,
          indicatorColor: _C.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Private'),
                  if (_privateChats.values.any((msgs) =>
                      msgs.isNotEmpty && msgs.last.senderId != 'me')) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: _C.primary, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Group Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── Private Chats tab (index 0 — left) ─────────────────────
          _PrivateInbox(
            participants: visibleParticipants,
            privateChats: _privateChats,
            onOpen: (p) => _openPrivateChat(p.id, p.name, p.avatarLetter),
            onDelete: (id) => setState(() => _privateChats.remove(id)),
          ),

          // ── Group Chat tab (index 1 — right) ─────────────────────────
          Column(
            children: [
              // Info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: _C.primary.withOpacity(0.06),
                child: Row(children: [
                  const Icon(Icons.people_rounded, color: _C.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${visibleParticipants.length} students in your area are in this group',
                    style: const TextStyle(
                        color: _C.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ]),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: _visibleMessages.length,
                  itemBuilder: (_, i) {
                    final msg = _visibleMessages[i];
                    final showDate = i == 0 ||
                        _visibleMessages[i - 1].time.day != msg.time.day;
                    return Column(
                      children: [
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
                          onLongPress: () => _showMessageOptions(msg),
                          child: _GroupMessageBubble(msg: msg, fmt: _fmt),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Input
              _ChatInput(
                controller: _msgCtrl,
                onSend: _sendMessage,
              ),
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
        builder: (_, sc) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(
              'Group Members (${participants.length})',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _C.dark),
            ),
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
                  final isBlocked = _BlockedUsers.isBlocked(p.id);
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
                          bottom: 0, right: 0,
                          child: Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                                color: _C.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5)),
                          ),
                        ),
                    ]),
                    title: Text(p.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isBlocked ? _C.grey : _C.dark)),
                    subtitle: Text('${p.university} · ${p.area}',
                        style: const TextStyle(fontSize: 11, color: _C.grey)),
                    trailing: isBlocked
                        ? const Text('Blocked',
                            style: TextStyle(
                                fontSize: 11, color: _C.primary, fontWeight: FontWeight.w600))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline_rounded,
                                    color: _C.blue, size: 20),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _openPrivateChat(p.id, p.name, p.avatarLetter);
                                },
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime t) {
    final now = DateTime.now();
    if (t.day == now.day) return 'Today';
    if (t.day == now.day - 1) return 'Yesterday';
    return '${t.day} ${['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][t.month]}';
  }
}

// ─── Group message bubble ─────────────────────────────────────────────
class _GroupMessageBubble extends StatelessWidget {
  final _GroupMessage msg;
  final String Function(DateTime) fmt;
  const _GroupMessageBubble({required this.msg, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: _C.primary.withOpacity(0.12),
              child: Text(msg.senderAvatar,
                  style: const TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 9)),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isMe ? _C.primary : _C.lightGrey,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!msg.isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(msg.senderName,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _C.primary.withOpacity(0.8))),
                    ),
                  Text(msg.text,
                      style: TextStyle(
                          fontSize: 13,
                          color: msg.isMe ? Colors.white : _C.dark,
                          height: 1.4)),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(fmt(msg.time),
                          style: TextStyle(
                              fontSize: 10,
                              color: msg.isMe
                                  ? Colors.white60
                                  : _C.grey)),
                      if (msg.isMe) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.done_all_rounded,
                            size: 12, color: Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private inbox (tab 2) ────────────────────────────────────────────
class _PrivateInbox extends StatelessWidget {
  final List<_Participant> participants;
  final Map<String, List<_PrivateMessage>> privateChats;
  final void Function(_Participant) onOpen;
  final void Function(String) onDelete;

  const _PrivateInbox({
    required this.participants,
    required this.privateChats,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final active = participants
        .where((p) => p.id != 'me' && privateChats.containsKey(p.id))
        .toList();

    return Column(
      children: [
        // "Start new private chat" row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Text('Start a private chat:',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _C.grey)),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: participants.where((p) => p.id != 'me').length,
                    itemBuilder: (_, i) {
                      final p = participants
                          .where((p) => p.id != 'me')
                          .toList()[i];
                      return GestureDetector(
                        onTap: () => onOpen(p),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: p.avatarColor,
                              child: Text(p.avatarLetter,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10)),
                            ),
                            if (p.isOnline)
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 9, height: 9,
                                  decoration: BoxDecoration(
                                      color: _C.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5)),
                                ),
                              ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 20),

        if (active.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 48, color: _C.grey),
                  SizedBox(height: 12),
                  Text('No private chats yet',
                      style: TextStyle(color: _C.grey, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Tap a member\'s avatar above to start',
                      style: TextStyle(color: _C.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: active.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72, color: _C.border),
              itemBuilder: (_, i) {
                final p = active[i];
                final msgs = privateChats[p.id]!;
                final last = msgs.isNotEmpty ? msgs.last : null;
                return Dismissible(
                  key: Key(p.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: _C.primary,
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white),
                  ),
                  onDismissed: (_) => onDelete(p.id),
                  child: ListTile(
                    onTap: () => onOpen(p),
                    leading: CircleAvatar(
                      backgroundColor: p.avatarColor,
                      child: Text(p.avatarLetter,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                    title: Text(p.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: _C.dark)),
                    subtitle: Text(
                      last != null
                          ? (last.senderId == 'me' ? 'You: ${last.text}' : last.text)
                          : 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _C.grey),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: _C.grey, size: 18),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─── Private chat page ────────────────────────────────────────────────
class _PrivateChatPage extends StatefulWidget {
  final String participantId, participantName, participantAvatar;
  final List<_PrivateMessage> messages;
  final void Function(String) onSend;

  const _PrivateChatPage({
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.messages,
    required this.onSend,
  });

  @override
  State<_PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<_PrivateChatPage> {
  final _ctrl      = TextEditingController();
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
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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

    // Simulated reply
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final replies = ['Got it!', 'Sure!', 'Let me check.', 'Sounds good!', '👍'];
      setState(() {
        widget.messages.add(
          _PrivateMessage(
            widget.participantId,
            replies[DateTime.now().millisecond % replies.length],
            DateTime.now(),
          ),
        );
        _msgs = [...widget.messages];
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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
                    fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.participantName,
                style: const TextStyle(
                    color: _C.dark, fontWeight: FontWeight.w700, fontSize: 14)),
            const Text('Private · Community member',
                style: TextStyle(color: _C.grey, fontSize: 10)),
          ]),
        ]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: _C.dark),
            onSelected: (val) {
              if (val == 'report') {
                _ReportedUsers.report(widget.participantId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.participantName} reported')),
                );
              } else if (val == 'block') {
                _BlockedUsers.block(widget.participantId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.participantName} blocked')),
                );
                Navigator.pop(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'report', child: Text('Report user')),
              const PopupMenuItem(
                  value: 'block',
                  child: Text('Block user', style: TextStyle(color: _C.primary))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: _C.primary.withOpacity(0.06),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(children: [
              const Icon(Icons.lock_outline_rounded, color: _C.primary, size: 13),
              const SizedBox(width: 6),
              Text('Private chat with ${widget.participantName}',
                  style: const TextStyle(
                      color: _C.primary, fontSize: 12, fontWeight: FontWeight.w600)),
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
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.70),
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
                                      color:
                                          isMe ? Colors.white60 : _C.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _ChatInput(controller: _ctrl, onSend: _send),
        ],
      ),
    );
  }
}

// ─── Shared chat input ────────────────────────────────────────────────
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
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.attach_file_rounded, color: _C.grey, size: 20),
          onPressed: () {},
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _C.lightGrey,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _C.border),
            ),
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
            width: 40, height: 40,
            decoration: const BoxDecoration(
                color: _C.primary, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

// ─── Option tile for bottom sheet ─────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
    );
  }
}