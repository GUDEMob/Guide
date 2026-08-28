import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _red      = Color(0xFFE30613);
const _surface  = Color(0xFFF2F2F2);
const _txt2     = Color(0xFF666666);

const List<Map<String, dynamic>> _skills = [
  {'label': 'Tutoring',       'icon': Icons.menu_book_outlined},
  {'label': 'Design',         'icon': Icons.brush_outlined},
  {'label': 'Coding',         'icon': Icons.code_rounded},
  {'label': 'Photography',    'icon': Icons.camera_alt_outlined},
  {'label': 'Writing',        'icon': Icons.edit_note_outlined},
  {'label': 'Video Editing',  'icon': Icons.movie_filter_outlined},
  {'label': 'Translation',    'icon': Icons.translate_outlined},
  {'label': 'Music',          'icon': Icons.music_note_outlined},
  {'label': 'Math & Science', 'icon': Icons.calculate_outlined},
  {'label': 'Social Media',   'icon': Icons.smartphone_outlined},
  {'label': 'Delivery',       'icon': Icons.delivery_dining_outlined},
  {'label': 'Campus Help',    'icon': Icons.school_outlined},
];

class SkillsSelectionScreen extends StatefulWidget {
  const SkillsSelectionScreen({super.key});

  @override
  State<SkillsSelectionScreen> createState() => _SkillsSelectionScreenState();
}

class _SkillsSelectionScreenState extends State<SkillsSelectionScreen> {
  final Set<String> _selected = {};

  void _toggle(String s) => setState(() => _selected.contains(s) ? _selected.remove(s) : _selected.add(s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        // header
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left:24, right:24, bottom:24),
          decoration: const BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.only(bottomLeft:Radius.circular(32), bottomRight:Radius.circular(32)),
          ),
          child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            _StepBar(step:1, total:2),
            const SizedBox(height:20),
            const Text('What are your skills?', style:TextStyle(fontSize:24, fontWeight:FontWeight.w700, color:Colors.white)),
            const SizedBox(height:6),
            const Text('Select skills you can offer on the marketplace', style:TextStyle(fontSize:13, color:Colors.white70)),
          ]),
        ),

        // grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              Text('${_selected.length} selected', style: const TextStyle(fontSize:13, color:_txt2)),
              const SizedBox(height:16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:3, crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:1.0),
                itemCount: _skills.length,
                itemBuilder: (ctx, i) {
                  final label    = _skills[i]['label'] as String;
                  final icon     = _skills[i]['icon'] as IconData;
                  final selected = _selected.contains(label);
                  return GestureDetector(
                    onTap: () => _toggle(label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds:180),
                      decoration: BoxDecoration(
                        color: selected ? _red.withOpacity(0.08) : _surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: selected ? _red : Colors.transparent, width:1.5),
                      ),
                      child: Column(mainAxisAlignment:MainAxisAlignment.center, children:[
                        Icon(icon, size:28, color: selected ? _red : _txt2),
                        const SizedBox(height:8),
                        Text(label, textAlign:TextAlign.center,
                          style:TextStyle(fontSize:11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? _red : _txt2)),
                      ]),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),

        // CTA
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
          child: SizedBox(
            width: double.infinity, height:52,
            child: ElevatedButton(
              onPressed: () => context.go('/onboarding/profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
              ),
              child: Text(
                _selected.isEmpty ? 'Skip for now' : 'Continue with ${_selected.length} skill${_selected.length==1?'':'s'}',
                style: const TextStyle(color:Colors.white, fontSize:16, fontWeight:FontWeight.w600),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int step, total;
  const _StepBar({required this.step, required this.total});
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(total, (i) => Expanded(
      child: Container(
        margin: EdgeInsets.only(right: i < total-1 ? 6 : 0),
        height: 4,
        decoration: BoxDecoration(
          color: i < step ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    )),
  );
}
