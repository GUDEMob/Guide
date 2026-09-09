import 'package:flutter/material.dart';

class _BuyerColors {
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF687385);
  static const line = Color(0xFFDCE7FF);
  static const canvas = Color(0xFFF6F8FF);
  static const navy = Color(0xFF1D4ED8);
  static const blue = Color(0xFF2563EB);
  static const red = Color(0xFFE50914);
  static const teal = Color(0xFF16875D);
  static const amber = Color(0xFFF59E0B);
}

class _BuyerMessage {
  final String senderId;
  final String text;
  final DateTime time;
  final bool isRead;

  const _BuyerMessage({
    required this.senderId,
    required this.text,
    required this.time,
    this.isRead = true,
  });
}

class _BuyerConversation {
  final String id;
  final String name;
  final String title;
  final String status;
  final String budget;
  final Color accent;
  final bool online;
  final List<_BuyerMessage> messages;

  const _BuyerConversation({
    required this.id,
    required this.name,
    required this.title,
    required this.status,
    required this.budget,
    required this.accent,
    required this.messages,
    this.online = false,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length < 2) return name.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get lastMessage => messages.isEmpty ? '' : messages.last.text;

  DateTime? get lastTime => messages.isEmpty ? null : messages.last.time;

  bool get hasUnread =>
      messages.any((message) => message.senderId != 'buyer' && !message.isRead);
}

List<_BuyerConversation> _mockConversations() {
  final now = DateTime.now();

  return [
    _BuyerConversation(
      id: '1',
      name: 'Priya S.',
      title: 'CV and cover letter rewrite',
      status: 'Awaiting brief',
      budget: 'R180',
      accent: _BuyerColors.teal,
      online: true,
      messages: [
        _BuyerMessage(
          senderId: 'seller',
          text:
              'I can start today. Please send your current CV and target role.',
          time: now.subtract(const Duration(minutes: 12)),
          isRead: false,
        ),
      ],
    ),
    _BuyerConversation(
      id: '2',
      name: 'Yusuf A.',
      title: 'Social media design pack',
      status: 'In progress',
      budget: 'R200',
      accent: _BuyerColors.blue,
      messages: [
        _BuyerMessage(
          senderId: 'buyer',
          text: 'Please keep the design clean and professional.',
          time: now.subtract(const Duration(hours: 4)),
        ),
        _BuyerMessage(
          senderId: 'seller',
          text: 'Got it. I will send the first draft by 16:00.',
          time: now.subtract(const Duration(hours: 3)),
          isRead: false,
        ),
      ],
    ),
    _BuyerConversation(
      id: '3',
      name: 'Nandi M.',
      title: 'Product photography session',
      status: 'Booked',
      budget: 'R350',
      accent: _BuyerColors.amber,
      online: true,
      messages: [
        _BuyerMessage(
          senderId: 'buyer',
          text: 'Saturday morning works for me.',
          time: now.subtract(const Duration(days: 1)),
        ),
      ],
    ),
    _BuyerConversation(
      id: '4',
      name: 'Keanu N.',
      title: 'Python dashboard cleanup',
      status: 'Delivered',
      budget: 'R150/hr',
      accent: _BuyerColors.red,
      messages: [
        _BuyerMessage(
          senderId: 'seller',
          text: 'The dashboard is cleaned up. I also added notes for handover.',
          time: now.subtract(const Duration(days: 2)),
        ),
      ],
    ),
  ];
}

class BuyerMessagesPage extends StatefulWidget {
  const BuyerMessagesPage({super.key});

  @override
  State<BuyerMessagesPage> createState() => _BuyerMessagesPageState();
}

class _BuyerMessagesPageState extends State<BuyerMessagesPage> {
  final _searchCtrl = TextEditingController();
  final _conversations = _mockConversations();
  String _query = '';

  int get _unreadCount =>
      _conversations.where((conversation) => conversation.hasUnread).length;

  List<_BuyerConversation> get _visibleConversations {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _conversations;
    return _conversations.where((conversation) {
      return conversation.name.toLowerCase().contains(q) ||
          conversation.title.toLowerCase().contains(q) ||
          conversation.status.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _visibleConversations;

    return Scaffold(
      backgroundColor: _BuyerColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: _BuyerColors.blue,
            foregroundColor: Colors.white,
            title: const Text(
              'Buyer Inbox',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'New message',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Choose a product or service to message the seller.'),
                  ),
                ),
                icon: const Icon(Icons.edit_square),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_BuyerColors.red, _BuyerColors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Row(
                    children: [
                      _SummaryCard(
                        label: 'Unread',
                        value: '$_unreadCount',
                        icon: Icons.mark_chat_unread_outlined,
                      ),
                      const SizedBox(width: 10),
                      const _SummaryCard(
                        label: 'Active orders',
                        value: '3',
                        icon: Icons.assignment_outlined,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search sellers or orders',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _BuyerColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _BuyerColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _BuyerColors.blue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverList.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  index == conversations.length - 1 ? 24 : 0,
                ),
                child: _ConversationCard(
                  conversation: conversations[index],
                  onTap: () => _openConversation(conversations[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openConversation(_BuyerConversation conversation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BuyerChatPage(conversation: conversation),
      ),
    );
    if (mounted) setState(() {});
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final _BuyerConversation conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: conversation.hasUnread
                ? conversation.accent.withValues(alpha: 0.28)
                : _BuyerColors.line,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: conversation.accent.withValues(alpha: 0.1),
                  child: Text(
                    conversation.initials,
                    style: TextStyle(
                      color: conversation.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (conversation.online)
                  Positioned(
                    right: -1,
                    bottom: 2,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: _BuyerColors.teal,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(
                            color: _BuyerColors.ink,
                            fontWeight: conversation.hasUnread
                                ? FontWeight.w900
                                : FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastTime),
                        style: TextStyle(
                          color: conversation.hasUnread
                              ? conversation.accent
                              : _BuyerColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _BuyerColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    conversation.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _BuyerColors.muted,
                      height: 1.25,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatusPill(
                        label: conversation.status,
                        color: conversation.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation.budget,
                        style: const TextStyle(
                          color: _BuyerColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (conversation.hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: conversation.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}';
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _BuyerChatPage extends StatefulWidget {
  final _BuyerConversation conversation;

  const _BuyerChatPage({required this.conversation});

  @override
  State<_BuyerChatPage> createState() => _BuyerChatPageState();
}

class _BuyerChatPageState extends State<_BuyerChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final List<_BuyerMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [...widget.conversation.messages];
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BuyerColors.canvas,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _BuyerColors.ink,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  widget.conversation.accent.withValues(alpha: 0.1),
              child: Text(
                widget.conversation.initials,
                style: TextStyle(
                  color: widget.conversation.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.name,
                    style: const TextStyle(
                      color: _BuyerColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _BuyerColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Call',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Calls can be added once seller contacts are connected.'),
              ),
            ),
            icon: const Icon(Icons.call_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: _StatusPill(
              label:
                  '${widget.conversation.status} - ${widget.conversation.budget}',
              color: widget.conversation.accent,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                final isMe = message.senderId == 'buyer';
                return _ChatBubble(
                  message: message,
                  isMe: isMe,
                  color: widget.conversation.accent,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _BuyerColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Write a message',
                      filled: true,
                      fillColor: _BuyerColors.canvas,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: _BuyerColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: _BuyerColors.line),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: _BuyerColors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _BuyerMessage(
          senderId: 'buyer',
          text: text,
          time: DateTime.now(),
        ),
      );
      _inputCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _BuyerMessage message;
  final bool isMe;
  final Color color;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? _BuyerColors.navy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 18),
          ),
          border: isMe ? null : Border.all(color: _BuyerColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : _BuyerColors.ink,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatClock(message.time),
              style: TextStyle(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.65)
                    : _BuyerColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatClock(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
