import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class HireStudentPage extends StatefulWidget {
  final Map<String, String> listing;
  const HireStudentPage({super.key, required this.listing});
  @override
  State<HireStudentPage> createState() => _HireStudentPageState();
}

class _HireStudentPageState extends State<HireStudentPage> {
  final _description = TextEditingController();
  final _budget = TextEditingController();
  DateTime? _deadline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
        title: const Text('Hire Student', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24, backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(widget.listing['name']![0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.listing['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(widget.listing['title']!, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Text(widget.listing['price']!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Job Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(controller: _description, maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Describe what you need help with...')),
                  const SizedBox(height: 16),
                  const Text('Your Budget', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(controller: _budget, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Enter amount', prefixText: 'R ')),
                  const SizedBox(height: 16),
                  const Text('Deadline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (d != null) setState(() => _deadline = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.inputBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.textGrey, size: 18),
                          const SizedBox(width: 8),
                          Text(_deadline == null ? 'Select deadline' : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                            style: TextStyle(color: _deadline == null ? AppColors.textGrey : AppColors.textDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(context: context, builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Request Sent!', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Your job request has been sent. The student will respond shortly.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () { context.pop(); context.pop(); context.pop(); },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
