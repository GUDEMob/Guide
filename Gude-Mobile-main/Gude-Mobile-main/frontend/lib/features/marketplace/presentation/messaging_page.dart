import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE30613);
  static const dark      = Color(0xFF1A1A1A);
  static const grey      = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border    = Color(0xFFEEEEEE);
}

// ─────────────────────────────────────────────
// MESSAGE MODEL
// ─────────────────────────────────────────────
class _Message {
  final String senderId;
  final String text;
  final DateTime time;
  final bool isRead;

  const _Message({
    required this.senderId,
    required this.text,
    required this.time,
    this.isRead = true,
  });
}

// ─────────────────────────────────────────────
// CONVERSATION MODEL
// ─────────────────────────────────────────────
class _Conversation {
  final String id;
  final String name;
  final String avatarLetter;
  final String context; // product/service name
  final bool isOnline;
  List<_Message> messages;
  final bool isFavourite;
  final bool isUnread;

  _Conversation({
    required this.id,
    required this.name,
    required this.avatarLetter,
    required this.context,
    required this.messages,
    this.isOnline = false,
    this.isFavourite = false,
    this.isUnread = false,
  });

  String get lastMessageText =>
      messages.isEmpty ? '' : messages.last.text;

  DateTime? get lastMessageTime =>
      messages.isEmpty ? null : messages.last.time;
}

// ─────────────────────────────────────────────
// SEED DATA
// ─────────────────────────────────────────────
List<_Conversation> _buildConversations() {
  final now = DateTime.now();
  return [
    _Conversation(
      id: 'u2',
      name: 'Vanessa Top',
      avatarLetter: 'V',
      context: 'HP Laptop',
      isOnline: true,
      isUnread: true,
      isFavourite: true,
      messages: [
        _Message(
          senderId: 'u2',
          text: 'Good morning Featuring, are we going together today or not?',
          time: now.subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
        _Message(
          senderId: 'me',
          text: 'Ok, I guess I will meet you in the afternoon class today.',
          time: now.subtract(const Duration(minutes: 3)),
        ),
        _Message(
          senderId: 'u2',
          text: 'Thanks for asking, but I\'ll see you then, have a wonderful day 😊',
          time: now.subtract(const Duration(minutes: 1)),
          isRead: false,
        ),
      ],
    ),
    _Conversation(
      id: 'u3',
      name: 'Paul Gabler',
      avatarLetter: 'P',
      context: 'Maths Tutoring',
      isOnline: false,
      messages: [
        _Message(
          senderId: 'u3',
          text: 'Thank you so much for the e...',
          time: now.subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    _Conversation(
      id: 'u4',
      name: 'Mia Scott',
      avatarLetter: 'M',
      context: 'Graphic Design',
      isOnline: true,
      messages: [
        _Message(
          senderId: 'u4',
          text: 'Thank you very much for the e...',
          time: now.subtract(const Duration(hours: 4)),
        ),
      ],
    ),
    _Conversation(
      id: 'u5',
      name: 'David Pred',
      avatarLetter: 'D',
      context: 'Study Table',
      messages: [
        _Message(
          senderId: 'me',
          text: 'Are you writing tomorrow I are part of the group for this coming week?',
          time: now.subtract(const Duration(days: 1)),
        ),
        _Message(
          senderId: 'u5',
          text: 'I\'m writing tomorrow too, join us are you writing today if you are writing today.',
          time: now.subtract(const Duration(hours: 20)),
          isRead: false,
        ),
      ],
    ),
    _Conversation(
      id: 'u6',
      name: 'Mason Margelis',
      avatarLetter: 'M',
      context: 'Photography',
      messages: [
        _Message(
          senderId: 'u6',
          text: 'Let\'s meet at the plumber in 2…',
          time: now.subtract(const Duration(days: 2)),
        ),
      ],
    ),
    _Conversation(
      id: 'u7',
      name: 'Stacey Clerk',
      avatarLetter: 'S',
      context: 'iPhone 12',
      isOnline: true,
      messages: [
        _Message(
          senderId: 'me',
          text: 'Stacey, It',
          time: now.subtract(const Duration(days: 3)),
        ),
      ],
    ),
    _Conversation(
      id: 'u8',
      name: 'Eviss Preme',
      avatarLetter: 'E',
      context: 'CV Writing',
      messages: [
        _Message(
          senderId: 'u8',
          text: 'Are you going able to join us for a class tomorrow?',
          time: now.subtract(const Duration(days: 3)),
        ),
      ],
    ),
    _Conversation(
      id: 'u9',
      name: 'Shelly Given',
      avatarLetter: 'S',
      context: 'Coding Help',
      messages: [
        _Message(
          senderId: 'u9',
          text: 'Let\'s meet at the gate at 12 ↑…',
          time: now.subtract(const Duration(days: 4)),
        ),
        _Message(
          senderId: 'me',
          text: 'Let\'s meet at the gate at 12 pm',
          time: now.subtract(const Duration(days: 4)),
        ),
      ],
    ),
    _Conversation(
      id: 'u10',
      name: 'Social Undercover',
      avatarLetter: 'S',
      context: 'Air Fryer',
      messages: [
        _Message(
          senderId: 'u10',
          text: 'Drag. Thank you so much…',
          time: now.subtract(const Duration(days: 5)),
        ),
      ],
    ),
  ];
}

// ─────────────────────────────────────────────
// MESSAGING INBOX PAGE
// ─────────────────────────────────────────────
class MessagingInboxPage extends StatefulWidget {
  const MessagingInboxPage({super.key});

  @override
  State<MessagingInboxPage> createState() => _MessagingInboxPageState();
}

class _MessagingInboxPageState extends State<MessagingInboxPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final List<_Conversation> _conversations = _buildConversations();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Conversation> get _filtered => _conversations.where((c) {
        if (_searchQuery.isEmpty) return true;
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.context.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

  void _addOrUpdateConv(_Conversation updated) {
    setState(() {
      final idx = _conversations.indexWhere((c) => c.id == updated.id);
      if (idx >= 0) {
        _conversations[idx] = updated;
      } else {
        _conversations.insert(0, updated);
      }
    });
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return 'now ${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${t.day}/${t.month}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = _conversations
        .where((c) => c.messages.any((m) => m.senderId != 'me' && !m.isRead))
        .length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Messaging',
              style: TextStyle(
                  color: _C.dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: _C.dark, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: _C.dark, size: 22),
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
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('All'),
                  if (unread > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                          color: _C.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Favourite'),
            const Tab(text: 'Unread'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _C.lightGrey,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 13, color: _C.dark),
                decoration: const InputDecoration(
                  hintText: 'Search messages…',
                  hintStyle:
                      TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                  border: InputBorder.none,
                  prefixIcon:
                      Icon(Icons.search, color: _C.grey, size: 18),
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _ConvList(
                  conversations: _filtered,
                  formatTime: _formatTime,
                  onTap: (conv) => _openChat(conv),
                ),
                _ConvList(
                  conversations:
                      _filtered.where((c) => c.isFavourite).toList(),
                  formatTime: _formatTime,
                  onTap: (conv) => _openChat(conv),
                ),
                _ConvList(
                  conversations: _filtered
                      .where((c) => c.messages
                          .any((m) => m.senderId != 'me' && !m.isRead))
                      .toList(),
                  formatTime: _formatTime,
                  onTap: (conv) => _openChat(conv),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(_Conversation conv) async {
    final updated = await Navigator.push<_Conversation>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(conversation: conv),
      ),
    );
    if (updated != null) _addOrUpdateConv(updated);
  }
}

// ─────────────────────────────────────────────
// CONVERSATION LIST WIDGET
// ─────────────────────────────────────────────
class _ConvList extends StatelessWidget {
  final List<_Conversation> conversations;
  final String Function(DateTime?) formatTime;
  final void Function(_Conversation) onTap;

  const _ConvList({
    required this.conversations,
    required this.formatTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 48, color: _C.grey),
            SizedBox(height: 12),
            Text('No messages yet',
                style: TextStyle(color: _C.grey, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 72, endIndent: 0),
      itemBuilder: (_, i) {
        final conv = conversations[i];
        final hasUnread = conv.messages
            .any((m) => m.senderId != 'me' && !m.isRead);
        final lastMsg = conv.messages.isNotEmpty ? conv.messages.last : null;
        final isLastFromMe = lastMsg?.senderId == 'me';

        return InkWell(
          onTap: () => onTap(conv),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _C.primary.withOpacity(0.15),
                      child: Text(
                        conv.avatarLetter,
                        style: const TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      ),
                    ),
                    if (conv.isOnline)
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.name,
                              style: TextStyle(
                                  fontWeight: hasUnread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 14,
                                  color: _C.dark),
                            ),
                          ),
                          Text(
                            formatTime(conv.lastMessageTime),
                            style: TextStyle(
                                fontSize: 11,
                                color: hasUnread ? _C.primary : _C.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Context badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _C.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          conv.context,
                          style: const TextStyle(
                              fontSize: 9,
                              color: _C.primary,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (isLastFromMe)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.done_all_rounded,
                                  size: 13, color: _C.primary),
                            ),
                          Expanded(
                            child: Text(
                              conv.lastMessageText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: hasUnread ? _C.dark : _C.grey,
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal),
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                  color: _C.primary, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// CHAT PAGE (thread view)
// ─────────────────────────────────────────────
class ChatPage extends StatefulWidget {
  final _Conversation conversation;
  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgCtrl    = TextEditingController();
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
    final msg = _Message(senderId: 'me', text: text, time: DateTime.now());
    setState(() {
      _conv.messages.add(msg);
      _msgCtrl.clear();
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());

    // Simulate reply after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final replies = [
        'Thanks! When would you like to meet?',
        'Sure, I can help with that!',
        'Great! Let me know your availability.',
        'I\'ll get back to you shortly.',
        'Sounds good! Send me more details.',
      ];
      final reply = _Message(
        senderId: _conv.id,
        text: replies[DateTime.now().millisecond % replies.length],
        time: DateTime.now(),
        isRead: false,
      );
      setState(() => _conv.messages.add(reply));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  String _formatMsgTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _conv);
        return false;
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
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _C.primary.withOpacity(0.15),
                    child: Text(
                      _conv.avatarLetter,
                      style: const TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14),
                    ),
                  ),
                  if (_conv.isOnline)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 9, height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _conv.name,
                    style: const TextStyle(
                        color: _C.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  Text(
                    _conv.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                        color:
                            _conv.isOnline ? const Color(0xFF10B981) : _C.grey,
                        fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam_outlined,
                  color: _C.dark, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.call_outlined,
                  color: _C.primary, size: 20),
              onPressed: () {},
            ),
          ],
        ),

        // Context banner
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _C.primary.withOpacity(0.06),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: _C.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Re: ${_conv.context}',
                    style: const TextStyle(
                        color: _C.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _conv.messages.length,
                itemBuilder: (_, i) {
                  final msg = _conv.messages[i];
                  final isMe = msg.senderId == 'me';

                  // Date separator
                  final showDate = i == 0 ||
                      _conv.messages[i - 1].time.day != msg.time.day;

                  return Column(
                    children: [
                      if (showDate)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _formatDate(msg.time),
                            style: const TextStyle(
                                color: _C.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
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
                                radius: 14,
                                backgroundColor:
                                    _C.primary.withOpacity(0.15),
                                child: Text(
                                  _conv.avatarLetter,
                                  style: const TextStyle(
                                      color: _C.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.68,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? _C.primary
                                      : _C.lightGrey,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                                    bottomRight:
                                        Radius.circular(isMe ? 4 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      msg.text,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isMe
                                              ? Colors.white
                                              : _C.dark,
                                          height: 1.4),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatMsgTime(msg.time),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: isMe
                                                  ? Colors.white70
                                                  : _C.grey),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 3),
                                          Icon(
                                            Icons.done_all_rounded,
                                            size: 13,
                                            color: msg.isRead
                                                ? Colors.white
                                                : Colors.white54,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _C.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded,
                        color: _C.grey, size: 20),
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
                        controller: _msgCtrl,
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Type a message…',
                          hintStyle: TextStyle(
                              color: Color(0xFFAAAAAA), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                          color: _C.primary, shape: BoxShape.circle),
                      child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime t) {
    final now = DateTime.now();
    if (t.day == now.day) return 'Today';
    if (t.day == now.day - 1) return 'Yesterday';
    return '${t.day} ${_monthName(t.month)} ${t.year}';
  }

  String _monthName(int m) => [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

// ─────────────────────────────────────────────
// OPEN CHAT FROM OUTSIDE (product/service detail)
// Usage: Navigator.push(context, MaterialPageRoute(
//   builder: (_) => ChatPage(conversation: _Conversation(
//     id: sellerId, name: sellerName, avatarLetter: sellerName[0],
//     context: productName, messages: [],
//   )),
// ));
// ─────────────────────────────────────────────