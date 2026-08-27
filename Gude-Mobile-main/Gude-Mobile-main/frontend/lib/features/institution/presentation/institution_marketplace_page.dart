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
}

class JobPost {
  final String id;
  final String title;
  final String description;
  final String department;
  final DateTime postedDate;
  final DateTime deadline;
  final String compensation;
  final String duration;
  final List<String> requirements;
  final int applications;
  final bool isActive;

  JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.postedDate,
    required this.deadline,
    required this.compensation,
    required this.duration,
    required this.requirements,
    this.applications = 0,
    this.isActive = true,
  });
}

class InstitutionMarketplacePage extends StatefulWidget {
  const InstitutionMarketplacePage({super.key});

  @override
  State<InstitutionMarketplacePage> createState() =>
      _InstitutionMarketplacePageState();
}

class _InstitutionMarketplacePageState
    extends State<InstitutionMarketplacePage> {
  final List<JobPost> _jobPosts = [];
  final List<JobPost> _activeJobs = [];
  final List<JobPost> _draftJobs = [];

  @override
  void initState() {
    super.initState();
    _loadMockJobs();
  }

  void _loadMockJobs() {
    final now = DateTime.now();
    _jobPosts.addAll([
      JobPost(
        id: 'j1',
        title: 'Research Assistant - Psychology Department',
        description:
            'Assist with data collection and analysis for ongoing research projects. Must have strong attention to detail.',
        department: 'Psychology',
        postedDate: now.subtract(const Duration(days: 2)),
        deadline: now.add(const Duration(days: 14)),
        compensation: 'R50/hour',
        duration: 'Part-time (10-15 hrs/week)',
        requirements: [
          'Psychology student',
          'Good academic record',
          'Excel skills'
        ],
        applications: 8,
      ),
      JobPost(
        id: 'j2',
        title: 'IT Support Assistant',
        description:
            'Provide technical support to students and staff. Help with computer lab maintenance.',
        department: 'IT Services',
        postedDate: now.subtract(const Duration(days: 3)),
        deadline: now.add(const Duration(days: 10)),
        compensation: 'R65/hour',
        duration: 'Flexible hours',
        requirements: ['IT/Computer Science student', 'Problem-solving skills'],
        applications: 12,
      ),
      JobPost(
        id: 'j3',
        title: 'Library Assistant',
        description:
            'Assist with library operations, help students find resources, and maintain organization.',
        department: 'Library',
        postedDate: now.subtract(const Duration(days: 5)),
        deadline: now.add(const Duration(days: 7)),
        compensation: 'R45/hour',
        duration: '20 hrs/week',
        requirements: ['Organized', 'Customer service skills'],
        applications: 5,
      ),
    ]);
    _activeJobs.addAll(_jobPosts);
  }

  void _createJobPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateJobSheet(
        onPost: (title, description, department, compensation, duration,
            requirements, deadline) {
          setState(() {
            _jobPosts.insert(
                0,
                JobPost(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  description: description,
                  department: department,
                  postedDate: DateTime.now(),
                  deadline: deadline,
                  compensation: compensation,
                  duration: duration,
                  requirements: requirements,
                ));
            _activeJobs.insert(0, _jobPosts.first);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Job posted successfully!'),
                backgroundColor: _C.green),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserRoleService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // no back arrow — this is a nav tab
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userService.institutionName,
                style: const TextStyle(
                    color: _C.dark, fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Job Postings',
                style: TextStyle(color: _C.grey, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: _C.primary, size: 28),
            onPressed: _createJobPost,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _C.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: _C.primary,
                unselectedLabelColor: _C.grey,
                indicatorColor: _C.primary,
                tabs: const [
                  Tab(text: 'Active Jobs', icon: Icon(Icons.work_outline)),
                  Tab(text: 'Drafts', icon: Icon(Icons.drafts_outlined)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _JobList(jobs: _activeJobs, onRefresh: () => setState(() {})),
                  _JobList(jobs: _draftJobs, onRefresh: () => setState(() {})),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  final List<JobPost> jobs;
  final VoidCallback onRefresh;
  const _JobList({required this.jobs, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 64, color: _C.grey),
            SizedBox(height: 16),
            Text('No job posts yet', style: TextStyle(color: _C.grey)),
            SizedBox(height: 8),
            Text('Tap + to create your first job posting',
                style: TextStyle(color: _C.grey, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (_, i) => _JobCard(job: jobs[i], onRefresh: onRefresh),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobPost job;
  final VoidCallback onRefresh;
  const _JobCard({required this.job, required this.onRefresh});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = job.deadline.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft < 7 && daysLeft > 0;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _C.dark)),
                    const SizedBox(height: 2),
                    Text(job.department,
                        style: const TextStyle(fontSize: 12, color: _C.grey)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: job.isActive
                      ? _C.green.withOpacity(0.1)
                      : _C.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.isActive ? 'Active' : 'Closed',
                  style: TextStyle(
                    fontSize: 11,
                    color: job.isActive ? _C.green : _C.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(job.description,
              style:
                  const TextStyle(fontSize: 12, color: _C.grey, height: 1.4)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: job.requirements
                .map((req) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _C.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('• $req',
                          style: const TextStyle(fontSize: 11, color: _C.grey)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(icon: Icons.attach_money, label: job.compensation),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.access_time, label: job.duration),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Posted: ${_formatDate(job.postedDate)}',
                  style: const TextStyle(fontSize: 10, color: _C.grey)),
              if (isUrgent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Urgent!',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600)),
                ),
              Text('${job.applications} applications',
                  style: const TextStyle(fontSize: 10, color: _C.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _C.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Applications',
                      style: TextStyle(color: _C.primary, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Edit Post',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _C.lightGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _C.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: _C.grey)),
        ],
      ),
    );
  }
}

class _CreateJobSheet extends StatefulWidget {
  final Function(String, String, String, String, String, List<String>, DateTime)
      onPost;
  const _CreateJobSheet({required this.onPost});

  @override
  State<_CreateJobSheet> createState() => _CreateJobSheetState();
}

class _CreateJobSheetState extends State<_CreateJobSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _compCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final List<String> _requirements = [];
  final _reqCtrl = TextEditingController();
  DateTime? _deadline;

  void _addRequirement() {
    if (_reqCtrl.text.isNotEmpty) {
      setState(() {
        _requirements.add(_reqCtrl.text);
        _reqCtrl.clear();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
    });
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date != null) {
      setState(() => _deadline = date);
    }
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
        child: SingleChildScrollView(
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
              const Text('Create Job Post',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _C.dark)),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Job Title',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deptCtrl,
                decoration: const InputDecoration(
                  hintText: 'Department',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Job Description',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _compCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Compensation',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _durationCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Duration',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _selectDeadline,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: _C.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: _C.grey),
                      const SizedBox(width: 8),
                      Text(
                        _deadline == null
                            ? 'Select Deadline'
                            : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                        style: TextStyle(
                            color: _deadline == null ? _C.grey : _C.dark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Requirements',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reqCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Add requirement',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) => _addRequirement(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: _C.primary),
                    onPressed: _addRequirement,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _requirements.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final req = entry.value;
                  return Chip(
                    label: Text(req),
                    onDeleted: () => _removeRequirement(idx),
                    deleteIcon: const Icon(Icons.close, size: 14),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleCtrl.text.isNotEmpty &&
                        _descCtrl.text.isNotEmpty &&
                        _deadline != null) {
                      widget.onPost(
                        _titleCtrl.text,
                        _descCtrl.text,
                        _deptCtrl.text,
                        _compCtrl.text,
                        _durationCtrl.text,
                        _requirements,
                        _deadline!,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post Job',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
