// frontend/lib/features/community/presentation/notice_board_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/user_role_service.dart';

class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
  static const green = Color(0xFF10B981);
  static const orange = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
}

class Notice {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorAvatar;
  final DateTime timestamp;
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isPinned;
  final bool isAnnouncement;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorAvatar,
    required this.timestamp,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.isPinned = false,
    this.isAnnouncement = false,
  });
}

class NoticeBoardPage extends StatefulWidget {
  const NoticeBoardPage({super.key});

  @override
  State<NoticeBoardPage> createState() => _NoticeBoardPageState();
}

class _NoticeBoardPageState extends State<NoticeBoardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final List<Notice> _notices = [];
  final List<Notice> _announcements = [];
  final List<Notice> _events = [];
  final List<Notice> _internships = [];
  final List<Notice> _partTimeJobs = [];

  String _selectedTag = 'All';
  final List<String> _tags = [
    'All',
    'Academic',
    'Events',
    'Social',
    'Lost & Found',
    'Internships',
    'Part Time Jobs',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _notices.addAll([
      Notice(
        id: 'n1',
        title: 'Library Extended Hours During Exams',
        content:
            'The university library will be open 24/7 from November 15th to December 5th. Study rooms can be booked online.',
        author: 'University Admin',
        authorAvatar: 'U',
        timestamp: now.subtract(const Duration(hours: 2)),
        tags: ['Academic'],
        likes: 45,
        comments: 12,
        isPinned: true,
        isAnnouncement: true,
      ),
      Notice(
        id: 'n2',
        title: 'Student Market Day This Friday',
        content:
            'Come support fellow students at the Market Day! Food, crafts, and services available. 10am-4pm at the Quad.',
        author: 'Sipho M.',
        authorAvatar: 'S',
        timestamp: now.subtract(const Duration(hours: 5)),
        tags: ['Events'],
        likes: 89,
        comments: 23,
      ),
      Notice(
        id: 'n3',
        title: 'Lost MacBook - Last seen in Library',
        content:
            'Lost my silver MacBook Air in the library yesterday. If found, please contact 082 123 4567. Reward offered!',
        author: 'Thabo N.',
        authorAvatar: 'T',
        timestamp: now.subtract(const Duration(days: 1)),
        tags: ['Lost & Found'],
        likes: 34,
        comments: 8,
      ),
      Notice(
        id: 'n4',
        title: 'Maths Study Group Forming',
        content:
            'Looking for 2nd year engineering students to form a study group for Calculus. Meet MWF 2pm at the Science Block.',
        author: 'Aisha K.',
        authorAvatar: 'A',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        tags: ['Academic'],
        likes: 56,
        comments: 15,
      ),
      Notice(
        id: 'n5',
        title: 'Campus Blood Drive',
        content:
            'Join us for the annual blood drive. Free snacks for donors! Sign up at the Student Centre.',
        author: 'Student Council',
        authorAvatar: 'SC',
        timestamp: now.subtract(const Duration(days: 2)),
        tags: ['Events', 'Social'],
        likes: 112,
        comments: 34,
      ),
      Notice(
        id: 'n6',
        title: 'Software Engineering Internship – FinTech Co.',
        content:
            'FinTech Co. is looking for Software Engineering interns for Summer 2025. Must be 3rd or 4th year. Apply at careers@fintechco.co.za',
        author: 'Careers Office',
        authorAvatar: 'CO',
        timestamp: now.subtract(const Duration(days: 1)),
        tags: ['Internships'],
        likes: 143,
        comments: 41,
        isPinned: true,
      ),
      Notice(
        id: 'n7',
        title: 'Data Analytics Internship – TechCorp SA',
        content:
            'TechCorp SA offers a 6-month paid data analytics internship. Open to Statistics and Computer Science students. Stipend: R8 000/month.',
        author: 'Prof. Dlamini',
        authorAvatar: 'PD',
        timestamp: now.subtract(const Duration(days: 3)),
        tags: ['Internships'],
        likes: 98,
        comments: 27,
      ),
      Notice(
        id: 'n8',
        title: 'Part-time Tutor Needed – Grade 11 Maths',
        content:
            'Family in Sandton looking for a reliable university student to tutor Grade 11 Maths twice a week. R200/hour. WhatsApp 071 555 0123.',
        author: 'Zanele B.',
        authorAvatar: 'ZB',
        timestamp: now.subtract(const Duration(hours: 8)),
        tags: ['Part Time Jobs'],
        likes: 62,
        comments: 18,
      ),
      Notice(
        id: 'n9',
        title: 'Part-time Barista – Coffee on Campus',
        content:
            'Coffee on Campus is hiring a part-time barista for weekends. Flexible hours, student-friendly schedule. Drop your CV at the kiosk.',
        author: 'Coffee on Campus',
        authorAvatar: 'CC',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        tags: ['Part Time Jobs'],
        likes: 55,
        comments: 14,
      ),
    ]);

    _announcements.addAll(_notices.where((n) => n.isAnnouncement).toList());
    _events.addAll(_notices.where((n) => n.tags.contains('Events')).toList());
    _internships
        .addAll(_notices.where((n) => n.tags.contains('Internships')).toList());
    _partTimeJobs.addAll(
        _notices.where((n) => n.tags.contains('Part Time Jobs')).toList());
  }

  List<Notice> get _filteredNotices {
    if (_selectedTag == 'All') return _notices;
    return _notices.where((n) => n.tags.contains(_selectedTag)).toList();
  }

  void _createNotice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateNoticeSheet(onPost: (title, content, tags) {
        setState(() {
          final newNotice = Notice(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            content: content,
            author: 'You',
            authorAvatar: 'Y',
            timestamp: DateTime.now(),
            tags: tags,
          );
          _notices.insert(0, newNotice);
          if (newNotice.tags.contains('Events')) {
            _events.insert(0, newNotice);
          }
          if (newNotice.tags.contains('Internships')) {
            _internships.insert(0, newNotice);
          }
          if (newNotice.tags.contains('Part Time Jobs')) {
            _partTimeJobs.insert(0, newNotice);
          }
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Notice posted!'), backgroundColor: _C.green),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserRoleService();
    final isInstitution = userService.isInstitution;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: _C.dark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Student Notice Board',
            style: TextStyle(
                color: _C.dark, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          if (!isInstitution)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: _C.primary, size: 24),
              onPressed: _createNotice,
            ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _C.primary,
          unselectedLabelColor: _C.grey,
          indicatorColor: _C.primary,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'All Posts'),
            Tab(text: 'Announcements'),
            Tab(text: 'Events'),
            Tab(text: 'Internships'),
            Tab(text: 'Part Time Jobs'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _NoticeList(notices: _filteredNotices),
                _NoticeList(notices: _announcements),
                _NoticeList(notices: _events),
                _NoticeList(notices: _internships),
                _NoticeList(notices: _partTimeJobs),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isInstitution
          ? FloatingActionButton(
              onPressed: _createNotice,
              backgroundColor: _C.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _NoticeList extends StatelessWidget {
  final List<Notice> notices;
  const _NoticeList({required this.notices});

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: _C.grey),
            SizedBox(height: 16),
            Text('No posts yet',
                style: TextStyle(color: _C.grey, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notices.length,
      itemBuilder: (_, i) => _NoticeCard(notice: notices[i]),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  const _NoticeCard({required this.notice});

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  Color get _avatarBg {
    if (notice.isAnnouncement) return _C.primary.withOpacity(0.1);
    if (notice.tags.contains('Internships')) return _C.purple.withOpacity(0.1);
    if (notice.tags.contains('Part Time Jobs'))
      return _C.green.withOpacity(0.1);
    return _C.blue.withOpacity(0.1);
  }

  Color get _avatarFg {
    if (notice.isAnnouncement) return _C.primary;
    if (notice.tags.contains('Internships')) return _C.purple;
    if (notice.tags.contains('Part Time Jobs')) return _C.green;
    return _C.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _avatarBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(notice.authorAvatar,
                      style: TextStyle(
                        color: _avatarFg,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(notice.author,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(width: 6),
                        if (notice.isAnnouncement)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _C.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Announcement',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: _C.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        if (notice.isPinned && !notice.isAnnouncement)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _C.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Pinned',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: _C.orange,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    Text(_formatTime(notice.timestamp),
                        style: const TextStyle(fontSize: 10, color: _C.grey)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    color: _C.grey, size: 18),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(notice.title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _C.dark)),
          const SizedBox(height: 6),
          Text(notice.content,
              style:
                  const TextStyle(fontSize: 13, color: _C.grey, height: 1.4)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: notice.tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _C.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('#$tag',
                          style: const TextStyle(fontSize: 10, color: _C.grey)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionButton(
                  icon: Icons.thumb_up_outlined,
                  label: '${notice.likes}',
                  onTap: () {}),
              const SizedBox(width: 20),
              _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '${notice.comments}',
                  onTap: () {}),
              const Spacer(),
              _ActionButton(
                  icon: Icons.share_outlined, label: 'Share', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: _C.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: _C.grey)),
        ],
      ),
    );
  }
}

class _CreateNoticeSheet extends StatefulWidget {
  final Function(String, String, List<String>) onPost;
  const _CreateNoticeSheet({required this.onPost});

  @override
  State<_CreateNoticeSheet> createState() => _CreateNoticeSheetState();
}

class _CreateNoticeSheetState extends State<_CreateNoticeSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Academic',
    'Events',
    'Social',
    'Lost & Found',
    'Internships',
    'Part Time Jobs',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _C.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Create New Post',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: _C.dark)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What would you like to share?',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tags',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags
                  .map((tag) => FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        selectedColor: _C.primary.withOpacity(0.1),
                        checkmarkColor: _C.primary,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleCtrl.text.isNotEmpty &&
                      _contentCtrl.text.isNotEmpty) {
                    widget.onPost(
                        _titleCtrl.text, _contentCtrl.text, _selectedTags);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Post',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
