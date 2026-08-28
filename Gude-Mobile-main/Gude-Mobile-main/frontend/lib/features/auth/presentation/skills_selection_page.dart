import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class SkillsSelectionPage extends StatefulWidget {
  const SkillsSelectionPage({super.key});
  @override
  State<SkillsSelectionPage> createState() => _SkillsSelectionPageState();
}

class _SkillsSelectionPageState extends State<SkillsSelectionPage> {
  final Set<String> _selected = {};

  final _skills = [
    {'label': 'Tutoring', 'icon': Icons.school_outlined},
    {'label': 'Design', 'icon': Icons.design_services_outlined},
    {'label': 'Coding', 'icon': Icons.code_outlined},
    {'label': 'Writing', 'icon': Icons.edit_outlined},
    {'label': 'Photography', 'icon': Icons.camera_alt_outlined},
    {'label': 'Marketing', 'icon': Icons.campaign_outlined},
    {'label': 'Accounting', 'icon': Icons.calculate_outlined},
    {'label': 'Translation', 'icon': Icons.translate_outlined},
    {'label': 'Music', 'icon': Icons.music_note_outlined},
    {'label': 'Fitness', 'icon': Icons.fitness_center_outlined},
    {'label': 'Cooking', 'icon': Icons.restaurant_outlined},
    {'label': 'Hair & Beauty', 'icon': Icons.face_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Your Skills', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text('Choose skills you can offer to other students. You can add more later.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14, height: 1.4)),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
                  itemCount: _skills.length,
                  itemBuilder: (_, i) {
                    final skill = _skills[i];
                    final label = skill['label'] as String;
                    final icon = skill['icon'] as IconData;
                    final selected = _selected.contains(label);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selected.remove(label);
                        } else {
                          _selected.add(label);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.inputBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: selected ? Colors.white : AppColors.textGrey, size: 28),
                            const SizedBox(height: 8),
                            Text(label, textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.textDark,
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('${_selected.length} skills selected',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/verify-student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/verify-student'),
                child: const Center(child: Text('Skip', style: TextStyle(color: AppColors.textGrey))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
