import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class WeeklyCheckinPage extends StatefulWidget {
  const WeeklyCheckinPage({super.key});
  @override
  State<WeeklyCheckinPage> createState() => _WeeklyCheckinPageState();
}

class _WeeklyCheckinPageState extends State<WeeklyCheckinPage> {
  int? _selected;
  int _step = 0;

  final _questions = [
    {
      'question': 'How are you feeling this week?',
      'options': [
        {
          'label': 'Doing well',
          'icon': Icons.sentiment_very_satisfied_outlined,
          'color': 0xFF4CAF50
        },
        {
          'label': 'Stressed',
          'icon': Icons.sentiment_neutral_outlined,
          'color': 0xFFFF9800
        },
        {
          'label': 'Struggling',
          'icon': Icons.sentiment_dissatisfied_outlined,
          'color': 0xFFFF5722
        },
        {
          'label': 'Need help',
          'icon': Icons.sentiment_very_dissatisfied_outlined,
          'color': 0xFFF44336
        },
      ],
    },
    {
      'question': 'How is your financial situation?',
      'options': [
        {
          'label': 'Comfortable',
          'icon': Icons.account_balance_wallet_outlined,
          'color': 0xFF4CAF50
        },
        {
          'label': 'Managing',
          'icon': Icons.savings_outlined,
          'color': 0xFFFF9800
        },
        {
          'label': 'Tight',
          'icon': Icons.money_off_outlined,
          'color': 0xFFFF5722
        },
        {
          'label': 'Critical',
          'icon': Icons.warning_outlined,
          'color': 0xFFF44336
        },
      ],
    },
    {
      'question': 'How are your studies going?',
      'options': [
        {
          'label': 'On track',
          'icon': Icons.school_outlined,
          'color': 0xFF4CAF50
        },
        {
          'label': 'Behind a bit',
          'icon': Icons.menu_book_outlined,
          'color': 0xFFFF9800
        },
        {
          'label': 'Falling behind',
          'icon': Icons.assignment_late_outlined,
          'color': 0xFFFF5722
        },
        {
          'label': 'Need support',
          'icon': Icons.help_outline,
          'color': 0xFFF44336
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final q = _questions[_step];
    final options = q['options'] as List;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textDark),
            onPressed: () => context.pop()),
        title: Text('Check-In ${_step + 1}/${_questions.length}',
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / _questions.length,
              backgroundColor: AppColors.inputBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 40),
            Text(q['question'] as String,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.3)),
            const SizedBox(height: 40),
            ...List.generate(options.length, (i) {
              final opt = options[i];
              final color = Color(opt['color'] as int);
              final selected = _selected == i;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.1) : Colors.white,
                    border: Border.all(
                        color: selected ? color : AppColors.inputBorder,
                        width: selected ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(opt['icon'] as IconData,
                          color: selected ? color : AppColors.textGrey,
                          size: 28),
                      const SizedBox(width: 16),
                      Text(opt['label'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                            color: selected ? color : AppColors.textDark,
                          )),
                      const Spacer(),
                      if (selected)
                        Icon(Icons.check_circle, color: color, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      if (_step < _questions.length - 1) {
                        setState(() {
                          _step++;
                          _selected = null;
                        });
                      } else {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Check-In Complete!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  content: const Text(
                                      'Your responses have been recorded. Your stability score has been updated.'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        context.pop();
                                        context.pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary),
                                      child: const Text('Done',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                disabledBackgroundColor: AppColors.inputBorder,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(_step < _questions.length - 1 ? 'Next' : 'Submit',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
