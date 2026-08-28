// lib/features/profile/presentation/profile_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────

const String _kProfilePicKey = 'profile_pic_path';

// ─────────────────────────────────────────────
// AVAILABLE SKILLS
// ─────────────────────────────────────────────

const List<Map<String, dynamic>> _availableSkills = [
  {'label': 'Mathematics', 'icon': Icons.calculate_outlined},
  {'label': 'Tutoring', 'icon': Icons.menu_book_outlined},
  {'label': 'Python', 'icon': Icons.code_rounded},
  {'label': 'Design', 'icon': Icons.brush_outlined},
  {'label': 'Photography', 'icon': Icons.camera_alt_outlined},
  {'label': 'Writing', 'icon': Icons.edit_note_outlined},
  {'label': 'Video Editing', 'icon': Icons.movie_filter_outlined},
  {'label': 'Translation', 'icon': Icons.translate_outlined},
  {'label': 'Music', 'icon': Icons.music_note_outlined},
  {'label': 'Social Media', 'icon': Icons.smartphone_outlined},
  {'label': 'Delivery', 'icon': Icons.delivery_dining_outlined},
  {'label': 'Campus Help', 'icon': Icons.school_outlined},
  {'label': 'Accounting', 'icon': Icons.receipt_long_outlined},
  {'label': 'Data Analysis', 'icon': Icons.bar_chart_outlined},
  {'label': 'Web Development', 'icon': Icons.language_outlined},
  {'label': 'Graphic Design', 'icon': Icons.palette_outlined},
  {'label': 'Content Writing', 'icon': Icons.article_outlined},
  {'label': 'Marketing', 'icon': Icons.campaign_outlined},
  {'label': 'Economics', 'icon': Icons.trending_up_rounded},
  {'label': 'Cooking', 'icon': Icons.restaurant_outlined},
  {'label': 'Cleaning', 'icon': Icons.cleaning_services_outlined},
  {'label': 'Babysitting', 'icon': Icons.child_care_outlined},
  {'label': 'Haircare', 'icon': Icons.content_cut_outlined},
  {'label': 'Fitness Coaching', 'icon': Icons.fitness_center_outlined},
];

const List<String> _faculties = [
  'Engineering, the Built Environment & Technology',
  'Business & Economic Sciences',
  'Health Sciences',
  'Humanities',
  'Law',
  'Science',
  'Education',
  'Arts',
];

const List<String> _studyYears = [
  '1st Year',
  '2nd Year',
  '3rd Year',
  '4th Year',
  'Honours',
  'Masters',
  'PhD',
  'Part-time',
];

// ─────────────────────────────────────────────
// PROFILE PAGE
// ─────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  // ── Verification ───────────────────────────
  final bool _emailVerified = true;
  bool _studentIdUploaded = false;
  bool _universityVerified = false;
  bool _isUploadingId = false;

  // ── Profile picture ─────────────────────────
  // On mobile: _profilePicFile holds the copied permanent File.
  // On web:    _profilePicBytes holds the raw bytes (no file system access).
  File? _profilePicFile;
  Uint8List? _profilePicBytes;

  // ── Bio ─────────────────────────────────────
  String _bio = '';

  // ── Professional fields ─────────────────────
  String _degree = '';
  String _faculty = '';
  String _yearOfStudy = '';
  String _portfolioUrl = '';
  String _linkedInUrl = '';
  bool _openToWork = true;

  // ── Skills ──────────────────────────────────
  List<String> _skills = ['Mathematics', 'Tutoring', 'Python'];

  // ── Animation ───────────────────────────────
  late AnimationController _progressAnim;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _loadSavedProfilePic();
    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressValue = Tween<double>(begin: 0, end: _completionPercent / 100)
        .animate(CurvedAnimation(parent: _progressAnim, curve: Curves.easeOut));
    _progressAnim.forward();
  }

  @override
  void dispose() {
    _progressAnim.dispose();
    super.dispose();
  }

  void _refreshProgress() {
    _progressValue = Tween<double>(
            begin: _progressValue.value, end: _completionPercent / 100)
        .animate(CurvedAnimation(parent: _progressAnim, curve: Curves.easeOut));
    _progressAnim.forward(from: 0);
  }

  // ─────────────────────────────────────────────
  // PROFILE PIC PERSISTENCE
  // ─────────────────────────────────────────────

  Future<void> _loadSavedProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      // On web we stored the image as a base64 string.
      final b64 = prefs.getString(_kProfilePicKey);
      if (b64 != null && mounted) {
        setState(() => _profilePicBytes = base64Decode(b64));
        _refreshProgress();
      }
    } else {
      final path = prefs.getString(_kProfilePicKey);
      if (path != null && mounted) {
        final file = File(path);
        if (await file.exists()) {
          setState(() => _profilePicFile = file);
          _refreshProgress();
        }
      }
    }
  }

  Future<void> _saveProfilePic(XFile picked) async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      // Web has no file system — store as base64 in shared_preferences.
      final bytes = await picked.readAsBytes();
      await prefs.setString(_kProfilePicKey, base64Encode(bytes));
      if (mounted) setState(() => _profilePicBytes = bytes);
    } else {
      // Mobile/desktop — copy to permanent app documents directory so the
      // path survives OS cache clears and app restarts.
      final appDir = await _getDocumentsDirectory();
      final fileName =
          'profile_pic_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanent =
          await File(picked.path).copy('${appDir.path}/$fileName');
      await prefs.setString(_kProfilePicKey, permanent.path);
      if (mounted) setState(() => _profilePicFile = permanent);
    }
  }

  /// Returns the app documents directory on native platforms.
  /// Never called on web (guarded by kIsWeb checks above).
  Future<Directory> _getDocumentsDirectory() async {
    // Dynamically resolved to avoid importing path_provider on web.
    return _NativePathHelper.getDocumentsDirectory();
  }

  Future<void> _clearProfilePicPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProfilePicKey);
    if (mounted) {
      setState(() {
        _profilePicFile = null;
        _profilePicBytes = null;
      });
    }
  }

  // ── Completion calculation ──────────────────
  double get _completionPercent {
    int done = 0;
    if (_profilePicFile != null || _profilePicBytes != null) done++;
    if (_bio.isNotEmpty) done++;
    if (_degree.isNotEmpty) done++;
    if (_faculty.isNotEmpty) done++;
    if (_yearOfStudy.isNotEmpty) done++;
    if (_skills.isNotEmpty) done++;
    if (_studentIdUploaded) done++;
    if (_portfolioUrl.isNotEmpty || _linkedInUrl.isNotEmpty) done++;
    return (done / 8) * 100;
  }

  List<_CompletionStep> get _completionSteps => [
        _CompletionStep(
          label: 'Profile photo',
          done: _profilePicFile != null || _profilePicBytes != null,
          onTap: _showProfilePicOptions,
        ),
        _CompletionStep(
          label: 'Academic details',
          done: _degree.isNotEmpty &&
              _faculty.isNotEmpty &&
              _yearOfStudy.isNotEmpty,
          onTap: _showAcademicSheet,
        ),
        _CompletionStep(
          label: 'Bio',
          done: _bio.isNotEmpty,
          onTap: _showEditBioSheet,
        ),
        _CompletionStep(
          label: 'Skills',
          done: _skills.isNotEmpty,
          onTap: _showAddSkillSheet,
        ),
        _CompletionStep(
          label: 'Links (portfolio / LinkedIn)',
          done: _portfolioUrl.isNotEmpty || _linkedInUrl.isNotEmpty,
          onTap: _showLinksSheet,
        ),
        _CompletionStep(
          label: 'Student ID verification',
          done: _studentIdUploaded,
          onTap: _handleUploadStudentId,
        ),
      ];

  // ─────────────────────────────────────────────
  // IMAGE PICKER — web-safe
  // ─────────────────────────────────────────────
  Future<void> _pickAndSaveImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (picked == null) return;
      await _saveProfilePic(picked);
      _refreshProgress();
      if (mounted) {
        _showSnackbar('Profile picture updated!', const Color(0xFF10B981));
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Could not open picker: $e', const Color(0xFFEF4444));
      }
    }
  }

  // ─────────────────────────────────────────────
  // PROFILE PICTURE
  // ─────────────────────────────────────────────
  void _showProfilePicOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 18),
              _SheetTitle(
                  icon: Icons.account_circle_outlined,
                  title: 'Profile Picture'),
              const SizedBox(height: 20),
              _UploadOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take a photo',
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndSaveImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _UploadOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndSaveImage(ImageSource.gallery);
                },
              ),
              if (_profilePicFile != null || _profilePicBytes != null) ...[
                const SizedBox(height: 10),
                _UploadOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove photo',
                  onTap: () async {
                    Navigator.pop(context);
                    await _clearProfilePicPath();
                    _refreshProgress();
                    _showSnackbar(
                        'Profile picture removed.', const Color(0xFF888888));
                  },
                ),
              ],
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(
                    child: Text('Cancel',
                        style: TextStyle(color: Color(0xFF888888)))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACADEMIC DETAILS
  // ─────────────────────────────────────────────
  void _showAcademicSheet() {
    final degreeCtrl = TextEditingController(text: _degree);
    String selectedFaculty = _faculty;
    String selectedYear = _yearOfStudy;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetHandle(),
                  const SizedBox(height: 18),
                  _SheetTitle(
                      icon: Icons.school_outlined, title: 'Academic Details'),
                  const SizedBox(height: 6),
                  const Text(
                    'This appears on your public profile and helps institutions and students find you.',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF666666), height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Degree / Qualification'),
                  const SizedBox(height: 6),
                  _StyledTextField(
                    controller: degreeCtrl,
                    hint: 'e.g. BSc Computer Science',
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Faculty'),
                  const SizedBox(height: 6),
                  _StyledDropdown(
                    value: selectedFaculty.isEmpty ? null : selectedFaculty,
                    hint: 'Select your faculty',
                    items: _faculties,
                    onChanged: (v) =>
                        setModalState(() => selectedFaculty = v ?? ''),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Year of Study'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _studyYears.map((y) {
                      final selected = selectedYear == y;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedYear = y),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withOpacity(0.1)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(y,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: selected
                                      ? AppColors.primary
                                      : const Color(0xFF666666))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: 'Save Details',
                    onTap: () {
                      setState(() {
                        _degree = degreeCtrl.text.trim();
                        _faculty = selectedFaculty;
                        _yearOfStudy = selectedYear;
                      });
                      _refreshProgress();
                      Navigator.pop(ctx);
                      _showSnackbar(
                          'Academic details saved!', const Color(0xFF10B981));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BIO
  // ─────────────────────────────────────────────
  void _showEditBioSheet() {
    final ctrl = TextEditingController(text: _bio);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SheetHandle(),
                const SizedBox(height: 18),
                _SheetTitle(
                    icon: Icons.edit_note_outlined, title: 'Professional Bio'),
                const SizedBox(height: 6),
                const Text(
                  'Write a short bio — your degree, what you offer, and what makes you stand out.',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF666666), height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: TextField(
                    controller: ctrl,
                    maxLines: 6,
                    maxLength: 300,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1A1A1A), height: 1.5),
                    decoration: const InputDecoration(
                      hintText:
                          '3rd-year Computer Science student at NMU. I tutor maths, build websites, and do data analysis. Available weekends.',
                      hintStyle:
                          TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _PrimaryButton(
                  label: 'Save Bio',
                  onTap: () {
                    setState(() => _bio = ctrl.text.trim());
                    _refreshProgress();
                    Navigator.pop(ctx);
                    _showSnackbar('Bio saved!', const Color(0xFF10B981));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LINKS
  // ─────────────────────────────────────────────
  void _showLinksSheet() {
    final portfolioCtrl = TextEditingController(text: _portfolioUrl);
    final linkedInCtrl = TextEditingController(text: _linkedInUrl);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SheetHandle(),
                const SizedBox(height: 18),
                _SheetTitle(
                    icon: Icons.link_rounded, title: 'Links & Portfolio'),
                const SizedBox(height: 6),
                const Text(
                  'Add links to your work so employers and clients can see what you\'ve built.',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF666666), height: 1.5),
                ),
                const SizedBox(height: 20),
                _FieldLabel('Portfolio / GitHub / Website'),
                const SizedBox(height: 6),
                _StyledTextField(
                  controller: portfolioCtrl,
                  hint: 'https://github.com/yourname',
                  prefixIcon: Icons.code_rounded,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                _FieldLabel('LinkedIn Profile'),
                const SizedBox(height: 6),
                _StyledTextField(
                  controller: linkedInCtrl,
                  hint: 'https://linkedin.com/in/yourname',
                  prefixIcon: Icons.business_center_outlined,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 24),
                _PrimaryButton(
                  label: 'Save Links',
                  onTap: () {
                    setState(() {
                      _portfolioUrl = portfolioCtrl.text.trim();
                      _linkedInUrl = linkedInCtrl.text.trim();
                    });
                    _refreshProgress();
                    Navigator.pop(ctx);
                    _showSnackbar('Links saved!', const Color(0xFF10B981));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STUDENT ID
  // ─────────────────────────────────────────────
  Future<void> _handleUploadStudentId() async {
    await _showStudentIdSheet();
  }

  Future<void> _showStudentIdSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              const SizedBox(height: 18),
              _SheetTitle(
                  icon: Icons.badge_outlined, title: 'Upload Student ID'),
              const SizedBox(height: 6),
              const Text(
                'Upload a clear photo of your student card. Your university will be verified automatically once approved.',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF666666), height: 1.5),
              ),
              const SizedBox(height: 20),
              _UploadOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take a photo',
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? picked = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 85);
                  if (picked != null && mounted) _applyStudentId(picked);
                },
              ),
              const SizedBox(height: 10),
              _UploadOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? picked = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 85);
                  if (picked != null && mounted) _applyStudentId(picked);
                },
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(
                    child: Text('Cancel',
                        style: TextStyle(color: Color(0xFF888888)))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyStudentId(XFile file) async {
    setState(() => _isUploadingId = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isUploadingId = false;
      _studentIdUploaded = true;
      _universityVerified = true;
    });
    _refreshProgress();
    _showSnackbar(
        'Student ID uploaded — university verified!', const Color(0xFF10B981));
  }

  // ─────────────────────────────────────────────
  // SKILLS
  // ─────────────────────────────────────────────
  void _showAddSkillSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddSkillSheet(
        currentSkills: List.from(_skills),
        onSave: (selected) {
          setState(() => _skills = selected);
          _refreshProgress();
        },
      ),
    );
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
    _refreshProgress();
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final percent = _completionPercent;
    final isComplete = percent >= 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            forceElevated: innerBoxIsScrolled,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined,
                    color: Colors.white, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE30613), Color(0xFF8B0000)],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.06,
                    child: CustomPaint(painter: _GridPainter()),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Profile header card ─────────
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        children: [
                          // Avatar + open to work badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: _showProfilePicOptions,
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primary, width: 3),
                                  ),
                                  child: ClipOval(
                                    child: _profilePicBytes != null
                                        ? Image.memory(
                                            _profilePicBytes!,
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover,
                                          )
                                        : _profilePicFile != null
                                            ? Image.file(
                                                _profilePicFile!,
                                                width: 88,
                                                height: 88,
                                                fit: BoxFit.cover,
                                              )
                                            : CircleAvatar(
                                                radius: 41,
                                                backgroundColor: AppColors
                                                    .primary
                                                    .withOpacity(0.1),
                                                child: const Text('S',
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 36)),
                                              ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: _showProfilePicOptions,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 13),
                                  ),
                                ),
                              ),
                              if (_openToWork)
                                Positioned(
                                  top: -4,
                                  left: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('OPEN',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Name
                          const Text('Student Name',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 2),

                          // Email
                          const Text('s21961082@mandela.ac.za',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF888888))),
                          const SizedBox(height: 8),

                          // Degree + faculty pill
                          if (_degree.isNotEmpty || _yearOfStudy.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F5F7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                [
                                  if (_degree.isNotEmpty) _degree,
                                  if (_yearOfStudy.isNotEmpty) _yearOfStudy
                                ].join(' · '),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444444),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),

                          // University pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: _universityVerified
                                        ? AppColors.primary
                                        : const Color(0xFFCCCCCC),
                                    size: 13),
                                const SizedBox(width: 5),
                                const Text('Nelson Mandela University',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Stats row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ProfileStat(label: 'Jobs Done', value: '0'),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: const Color(0xFFEEEEEE)),
                                _ProfileStat(label: 'Rating', value: '—'),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: const Color(0xFFEEEEEE)),
                                _ProfileStat(label: 'Earned', value: 'R0'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Open to work toggle
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _openToWork
                                  ? const Color(0xFF10B981).withOpacity(0.08)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _openToWork
                                    ? const Color(0xFF10B981).withOpacity(0.3)
                                    : const Color(0xFFEEEEEE),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _openToWork
                                      ? Icons.work_outline_rounded
                                      : Icons.work_off_outlined,
                                  color: _openToWork
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF888888),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _openToWork
                                        ? 'Open to work & gigs'
                                        : 'Not currently available',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _openToWork
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF888888)),
                                  ),
                                ),
                                Switch(
                                  value: _openToWork,
                                  activeColor: const Color(0xFF10B981),
                                  onChanged: (v) =>
                                      setState(() => _openToWork = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Profile completion banner ───
              if (!isComplete)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.rocket_launch_outlined,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Complete your profile',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
                                Text(
                                  '${percent.toInt()}% complete — ${_completionSteps.where((s) => !s.done).length} steps remaining',
                                  style: const TextStyle(
                                      color: Color(0xFF999999), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        AnimatedBuilder(
                          animation: _progressValue,
                          builder: (_, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              color: AppColors.primary,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ..._completionSteps.map((step) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: step.done ? null : step.onTap,
                                child: Row(children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: step.done
                                          ? const Color(0xFF10B981)
                                              .withOpacity(0.15)
                                          : Colors.white.withOpacity(0.06),
                                      border: Border.all(
                                        color: step.done
                                            ? const Color(0xFF10B981)
                                            : Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      step.done
                                          ? Icons.check_rounded
                                          : Icons.circle_outlined,
                                      size: 12,
                                      color: step.done
                                          ? const Color(0xFF10B981)
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(step.label,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: step.done
                                                ? Colors.white.withOpacity(0.4)
                                                : Colors.white,
                                            decoration: step.done
                                                ? TextDecoration.lineThrough
                                                : null,
                                            decorationColor:
                                                Colors.white.withOpacity(0.4))),
                                  ),
                                  if (!step.done)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('Add',
                                          style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                ]),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),

              // ── Academic details ────────────
              _SectionCard(
                title: 'Academic Details',
                icon: Icons.school_outlined,
                isDone: _degree.isNotEmpty &&
                    _faculty.isNotEmpty &&
                    _yearOfStudy.isNotEmpty,
                actionLabel: (_degree.isEmpty) ? 'Add' : 'Edit',
                onAction: _showAcademicSheet,
                child: _degree.isEmpty
                    ? _EmptyState(
                        label: 'Add your degree and year of study',
                        onTap: _showAcademicSheet)
                    : Column(
                        children: [
                          _InfoRow(
                              icon: Icons.menu_book_outlined, value: _degree),
                          if (_faculty.isNotEmpty)
                            _InfoRow(
                                icon: Icons.domain_outlined, value: _faculty),
                          if (_yearOfStudy.isNotEmpty)
                            _InfoRow(
                                icon: Icons.calendar_today_outlined,
                                value: _yearOfStudy),
                        ],
                      ),
              ),

              // ── Bio ─────────────────────────
              _SectionCard(
                title: 'Professional Bio',
                icon: Icons.person_outline_rounded,
                isDone: _bio.isNotEmpty,
                actionLabel: _bio.isEmpty ? 'Add' : 'Edit',
                onAction: _showEditBioSheet,
                child: _bio.isEmpty
                    ? _EmptyState(
                        label: 'Tell employers and clients about yourself',
                        onTap: _showEditBioSheet)
                    : Text(_bio,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF444444),
                            height: 1.6)),
              ),

              // ── Skills ──────────────────────
              _SectionCard(
                title: 'Skills & Services',
                icon: Icons.bolt_rounded,
                isDone: _skills.isNotEmpty,
                actionLabel: 'Add',
                onAction: _showAddSkillSheet,
                child: _skills.isEmpty
                    ? _EmptyState(
                        label: 'Add skills so people can find you',
                        onTap: _showAddSkillSheet)
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skills
                            .map((s) => _SkillChip(
                                label: s, onRemove: () => _removeSkill(s)))
                            .toList(),
                      ),
              ),

              // ── Links ────────────────────────
              _SectionCard(
                title: 'Portfolio & Links',
                icon: Icons.link_rounded,
                isDone: _portfolioUrl.isNotEmpty || _linkedInUrl.isNotEmpty,
                actionLabel: (_portfolioUrl.isEmpty && _linkedInUrl.isEmpty)
                    ? 'Add'
                    : 'Edit',
                onAction: _showLinksSheet,
                child: (_portfolioUrl.isEmpty && _linkedInUrl.isEmpty)
                    ? _EmptyState(
                        label: 'Add your portfolio or LinkedIn',
                        onTap: _showLinksSheet)
                    : Column(
                        children: [
                          if (_portfolioUrl.isNotEmpty)
                            _InfoRow(
                                icon: Icons.code_rounded,
                                value: _portfolioUrl,
                                isLink: true),
                          if (_linkedInUrl.isNotEmpty)
                            _InfoRow(
                                icon: Icons.business_center_outlined,
                                value: _linkedInUrl,
                                isLink: true),
                        ],
                      ),
              ),

              // ── Verification ─────────────────
              _SectionCard(
                title: 'Verification',
                icon: Icons.shield_outlined,
                isDone:
                    _emailVerified && _studentIdUploaded && _universityVerified,
                child: Column(
                  children: [
                    _VerificationRow(
                        label: 'Email verified', done: _emailVerified),
                    _VerificationRow(
                      label: 'Student ID uploaded',
                      done: _studentIdUploaded,
                      isLoading: _isUploadingId,
                      onVerify:
                          _studentIdUploaded ? null : _handleUploadStudentId,
                    ),
                    _VerificationRow(
                      label: 'University verified',
                      done: _universityVerified,
                      subtitle: _universityVerified
                          ? null
                          : 'Auto-verified when student ID is uploaded',
                    ),
                  ],
                ),
              ),

              // ── Settings ─────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _SettingsTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          onTap: () {}),
                      _SettingsTile(
                          icon: Icons.lock_outline,
                          label: 'Privacy & Security',
                          onTap: () {}),
                      _SettingsTile(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          onTap: () {}),
                      _SettingsTile(
                        icon: Icons.logout,
                        label: 'Log Out',
                        isRed: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Text('Log out',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text(
                                  'Are you sure you want to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style:
                                          TextStyle(color: AppColors.textGrey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(80, 36),
                                  ),
                                  onPressed: () {
                                    final nav = GoRouter.of(context);
                                    Navigator.pop(context);
                                    Future.microtask(() => nav.go('/login'));
                                  },
                                  child: const Text('Log out',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPLETION STEP MODEL
// ─────────────────────────────────────────────

class _CompletionStep {
  final String label;
  final bool done;
  final VoidCallback onTap;
  const _CompletionStep(
      {required this.label, required this.done, required this.onTap});
}

// ─────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDone;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.isDone,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon,
                        size: 17,
                        color: isDone
                            ? const Color(0xFF10B981)
                            : AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A))),
                  ),
                  if (isDone)
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 18),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(actionLabel!,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _EmptyState({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFFCCCCCC), size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFO ROW
// ─────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isLink;
  const _InfoRow(
      {required this.icon, required this.value, this.isLink = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: const Color(0xFF888888)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: isLink ? AppColors.primary : const Color(0xFF444444),
                  decoration: isLink ? TextDecoration.underline : null,
                  decorationColor: AppColors.primary)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SHEET HELPERS
// ─────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2)),
        ),
      );
}

class _SheetTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SheetTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A)))),
      ]);
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666)));
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFFAAAAAA), size: 18)
                : null,
          ),
        ),
      );
}

class _StyledDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
            isExpanded: true,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
            items: items
                .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ),
      );
}

// ─────────────────────────────────────────────
// GRID PAINTER (banner texture)
// ─────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
// ADD SKILL SHEET
// ─────────────────────────────────────────────

class _AddSkillSheet extends StatefulWidget {
  final List<String> currentSkills;
  final void Function(List<String>) onSave;
  const _AddSkillSheet({required this.currentSkills, required this.onSave});

  @override
  State<_AddSkillSheet> createState() => _AddSkillSheetState();
}

class _AddSkillSheetState extends State<_AddSkillSheet> {
  late Set<String> _selected;
  final TextEditingController _customCtrl = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.currentSkills);
    _customCtrl.addListener(
        () => setState(() => _filter = _customCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter.isEmpty) return _availableSkills;
    return _availableSkills
        .where((s) => (s['label'] as String).toLowerCase().contains(_filter))
        .toList();
  }

  void _toggleSkill(String label) => setState(() {
        if (_selected.contains(label)) {
          _selected.remove(label);
        } else {
          _selected.add(label);
        }
      });

  void _addCustom() {
    final custom = _customCtrl.text.trim();
    if (custom.isEmpty) return;
    final formatted = custom[0].toUpperCase() + custom.substring(1);
    setState(() {
      _selected.add(formatted);
      _customCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(children: [
              const Expanded(
                child: Text('Add Skills',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A))),
              ),
              if (_selected.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${_selected.length} selected',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _customCtrl,
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
                    decoration: const InputDecoration(
                      hintText: 'Search or type a custom skill...',
                      hintStyle:
                          TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: Color(0xFFAAAAAA), size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),
              if (_customCtrl.text.isNotEmpty &&
                  !_availableSkills.any((s) =>
                      (s['label'] as String).toLowerCase() ==
                      _customCtrl.text.trim().toLowerCase())) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addCustom,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No skills match your search',
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 13)))
                : GridView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final skill = filtered[i];
                      final label = skill['label'] as String;
                      final icon = skill['icon'] as IconData;
                      final selected = _selected.contains(label);
                      return GestureDetector(
                        onTap: () => _toggleSkill(label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withOpacity(0.08)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.5),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon,
                                    size: 26,
                                    color: selected
                                        ? AppColors.primary
                                        : const Color(0xFF888888)),
                                const SizedBox(height: 6),
                                Text(label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: selected
                                            ? AppColors.primary
                                            : const Color(0xFF666666))),
                              ]),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_selected.toList());
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(
                  _selected.isEmpty
                      ? 'Save (no skills)'
                      : 'Save ${_selected.length} skill${_selected.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPLOAD OPTION TILE
// ─────────────────────────────────────────────

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC), size: 20),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────
// VERIFICATION ROW
// ─────────────────────────────────────────────

class _VerificationRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool isLoading;
  final String? subtitle;
  final VoidCallback? onVerify;

  const _VerificationRow({
    required this.label,
    required this.done,
    this.isLoading = false,
    this.subtitle,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (isLoading)
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary))
            else
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? const Color(0xFF10B981) : AppColors.textGrey,
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: done ? AppColors.textDark : AppColors.textGrey)),
            ),
            if (!done && !isLoading && onVerify != null)
              GestureDetector(
                onTap: onVerify,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Text('Verify',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            if (isLoading)
              const Text('Processing...',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ]),
          if (subtitle != null && !done) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(subtitle!,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFAAAAAA),
                      fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SKILL CHIP
// ─────────────────────────────────────────────

class _SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SkillChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 11, color: AppColors.primary),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────
// PROFILE STAT
// ─────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A))),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
      ]);
}

// ─────────────────────────────────────────────
// SETTINGS TILE
// ─────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isRed;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading:
            Icon(icon, color: isRed ? AppColors.primary : AppColors.textGrey),
        title: Text(label,
            style: TextStyle(
                fontSize: 14,
                color: isRed ? AppColors.primary : AppColors.textDark)),
        trailing: isRed
            ? null
            : const Icon(Icons.chevron_right, color: AppColors.textGrey),
        onTap: onTap,
      );
}

// ─────────────────────────────────────────────
// NATIVE PATH HELPER
// ─────────────────────────────────────────────

class _NativePathHelper {
  static Future<Directory> getDocumentsDirectory() async {
    return _getDir();
  }

  static Future<Directory> _getDir() async {
    // ignore: depend_on_referenced_packages
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }
}
