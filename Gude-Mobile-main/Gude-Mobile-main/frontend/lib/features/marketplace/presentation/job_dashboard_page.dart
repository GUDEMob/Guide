import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class JobDashboardPage extends StatefulWidget {
  const JobDashboardPage({super.key});
  @override
  State<JobDashboardPage> createState() => _JobDashboardPageState();
}

class _JobDashboardPageState extends State<JobDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  final _active = [
    {'title': 'Maths Tutoring', 'client': 'Sipho M.', 'amount': 'R450', 'due': 'Due tomorrow'},
    {'title': 'Logo Design', 'client': 'Amara K.', 'amount': 'R800', 'due': 'Due in 3 days'},
  ];

  final _pending = [
    {'title': 'Web Development', 'client': 'Thabo N.', 'amount': 'R1200', 'due': 'Awaiting response'},
  ];

  final _completed = [
    {'title': 'Essay Editing', 'client': 'Lerato D.', 'amount': 'R300', 'due': 'Completed'},
    {'title': 'Physics Tutoring', 'client': 'Nandi Z.', 'amount': 'R600', 'due': 'Completed'},
    {'title': 'Poster Design', 'client': 'Karabo L.', 'amount': 'R500', 'due': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('My Jobs', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Pending'), Tab(text: 'Completed')],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('R2,650', 'Total Earned'),
                _divider(),
                _stat('5', 'Jobs Done'),
                _divider(),
                _stat('4.9', 'Rating'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _jobList(_active, Colors.blue),
                _jobList(_pending, Colors.orange),
                _jobList(_completed, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
    ],
  );

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3));

  Widget _jobList(List<Map<String, String>> jobs, Color color) {
    if (jobs.isEmpty) return const Center(child: Text('No jobs here', style: TextStyle(color: AppColors.textGrey)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jobs.length,
      itemBuilder: (_, i) {
        final j = jobs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 4, height: 50,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(j['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Client: ${j['client']}', style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    Text(j['due']!, style: TextStyle(color: color, fontSize: 12)),
                  ],
                ),
              ),
              Text(j['amount']!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }
}
