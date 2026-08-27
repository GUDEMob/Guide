import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _red      = Color(0xFFE30613);
const _surface  = Color(0xFFF2F2F2);
const _txt1     = Color(0xFF1A1A1A);
const _txt2     = Color(0xFF666666);
const _txtHint  = Color(0xFF9E9E9E);

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bioCtrl   = TextEditingController();
  bool _isLoading  = false;
  bool _photoAdded = false;

  @override
  void dispose() { _bioCtrl.dispose(); super.dispose(); }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds:800));
    setState(() => _isLoading = false);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children:[
        // header
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left:24, right:24, bottom:24),
          decoration: const BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.only(bottomLeft:Radius.circular(32), bottomRight:Radius.circular(32)),
          ),
          child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            _StepBar(step:2, total:2),
            const SizedBox(height:20),
            const Text('Complete Your Profile', style:TextStyle(fontSize:24, fontWeight:FontWeight.w700, color:Colors.white)),
            const SizedBox(height:6),
            const Text('Help buyers know who you are', style:TextStyle(fontSize:13, color:Colors.white70)),
          ]),
        ),

        // form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              // photo
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _photoAdded = true),
                  child: Stack(children:[
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: _photoAdded ? _red.withOpacity(0.12) : _surface,
                      child: Icon(_photoAdded ? Icons.person_rounded : Icons.add_a_photo_outlined,
                        size:38, color: _photoAdded ? _red : _txtHint),
                    ),
                    Positioned(bottom:0, right:0,
                      child:Container(width:28, height:28,
                        decoration: const BoxDecoration(color:_red, shape:BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color:Colors.white, size:16))),
                  ]),
                ),
              ),
              const SizedBox(height:8),
              const Center(child:Text('Add profile photo', style:TextStyle(fontSize:13, color:_txt2))),
              const SizedBox(height:28),

              // bio
              const Text('About You', style:TextStyle(fontSize:14, fontWeight:FontWeight.w500, color:_txt1)),
              const SizedBox(height:10),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 4, maxLength: 200,
                style: const TextStyle(fontSize:14, color:_txt1),
                decoration: InputDecoration(
                  hintText: 'Tell buyers about yourself — your skills, experience, and what makes you great...',
                  hintStyle: const TextStyle(color:_txtHint, fontSize:13),
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.all(14),
                  filled: true, fillColor: _surface,
                  border: OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide:const BorderSide(color:_red, width:1.5)),
                ),
              ),
              const SizedBox(height:20),

              // info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color:_red.withOpacity(0.06), borderRadius:BorderRadius.circular(12)),
                child: Row(children:[
                  Container(width:36, height:36,
                    decoration: BoxDecoration(color:_red.withOpacity(0.12), shape:BoxShape.circle),
                    child: const Icon(Icons.rocket_launch_outlined, color:_red, size:18)),
                  const SizedBox(width:12),
                  const Expanded(child:Text(
                    "You're almost in! Complete your profile to start earning on the Gude Marketplace.",
                    style:TextStyle(fontSize:12, color:_txt2, height:1.4))),
                ]),
              ),
              const SizedBox(height:32),
            ]),
          ),
        ),

        // CTA
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
          child: Column(children:[
            SizedBox(
              width: double.infinity, height:52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _finish,
                style: ElevatedButton.styleFrom(backgroundColor:_red, shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
                child: _isLoading
                  ? const SizedBox(width:22, height:22, child:CircularProgressIndicator(color:Colors.white, strokeWidth:2.5))
                  : const Text('Enter Dashboard', style:TextStyle(color:Colors.white, fontSize:16, fontWeight:FontWeight.w600)),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Skip for now', style:TextStyle(color:_txt2)),
            ),
          ]),
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
