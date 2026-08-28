// lib/features/marketplace/presentation/create_post_page.dart
// Three distinct tabs — Sell Item · Create a Post (Other services) · Ridebuddy
// Matches wireframe exactly while following the Gude app design system.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
// COLOURS  (Gude palette)
// ─────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFFE30613);
  static const dark      = Color(0xFF1A1A1A);
  static const grey      = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border    = Color(0xFFEEEEEE);
  static const bg        = Color(0xFFF6F6F6);
  static const hint      = Color(0xFF9E9E9E);
}

// ─────────────────────────────────────────────
// CATEGORY LISTS
// ─────────────────────────────────────────────
const _productCategories = [
  'Electronics', 'Clothing', 'Books & Textbooks', 'Furniture',
  'Sports & Fitness', 'Appliances', 'Food & Snacks', 'Other',
];

const _serviceCategories = [
  'Tutoring', 'Design', 'Photography', 'Programming',
  'Writing', 'Music Lessons', 'Hair & Beauty', 'Other',
];

const _rideCategories = [
  'Daily Commute', 'Weekend Trip', 'Airport Transfer',
  'Campus Shuttle', 'Late Night Ride', 'Other',
];

// ─────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _C.dark, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Create a post',
          style: TextStyle(
              color: _C.dark, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1)),
                  ],
                ),
                labelColor: _C.dark,
                unselectedLabelColor: _C.hint,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w400),
                tabs: const [
                  Tab(text: 'Sell item'),
                  Tab(text: 'Create a post'),
                  Tab(text: 'Ridebuddy'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _SellItemTab(),
          _CreatePostTab(),
          _RidebuddyTab(),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 1 — SELL ITEM
// ═════════════════════════════════════════════════════════════
class _SellItemTab extends StatefulWidget {
  const _SellItemTab();

  @override
  State<_SellItemTab> createState() => _SellItemTabState();
}

class _SellItemTabState extends State<_SellItemTab> {
  bool _isLink         = true;
  String _category     = 'Electronics';
  bool _moreExpanded   = false;
  final _picker        = ImagePicker();
  final List<XFile> _images = [];

  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _serialCtrl   = TextEditingController();
  final _linkCtrl     = TextEditingController();
  final _conditionCtrl= TextEditingController();
  final _brandCtrl    = TextEditingController();

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _priceCtrl, _locationCtrl,
      _serialCtrl, _linkCtrl, _conditionCtrl, _brandCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) setState(() => _images.addAll(picked));
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in Title and Price'),
          backgroundColor: _C.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Item listed successfully!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Link / Manual toggle ─────────────────────────────
        _ModeToggle(
          isLink: _isLink,
          onLink:   () => setState(() => _isLink = true),
          onManual: () => setState(() => _isLink = false),
        ),
        const SizedBox(height: 12),

        // ── Link field (shown when isLink) ───────────────────
        if (_isLink) ...[
          _FieldLabel('Product Link'),
          _InputField(
            controller: _linkCtrl,
            hint: 'Paste product URL (Takealot, OLX, etc.)',
            prefix: Icons.link_rounded,
          ),
          const SizedBox(height: 4),
          _InfoBanner(
            text: 'We\'ll auto-fill details from the link. '
                'You can edit them after.',
          ),
          const SizedBox(height: 12),
        ],

        // ── Title ────────────────────────────────────────────
        _FieldLabel('Title'),
        _InputField(controller: _titleCtrl, hint: 'Add title'),

        // ── Description ──────────────────────────────────────
        _FieldLabel('Description'),
        _InputField(
            controller: _descCtrl,
            hint: 'Add Detailed Description',
            maxLines: 3),

        // ── Category + Price row ─────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Category'),
                  _DropdownField(
                    value: _category,
                    items: _productCategories,
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Price'),
                  _InputField(
                    controller: _priceCtrl,
                    hint: 'R 0.00',
                    keyboardType: TextInputType.number,
                    prefix: Icons.sell_outlined,
                  ),
                ]),
          ),
        ]),

        // ── Locations ────────────────────────────────────────
        _FieldLabel('Locations'),
        _InputField(
          controller: _locationCtrl,
          hint: 'Current location',
          prefix: Icons.location_on_outlined,
        ),

        // ── Upload image ─────────────────────────────────────
        _FieldLabel('Upload Image'),
        _ImageUploadRow(
          images: _images,
          onPickImages: _pickImages,
          onRemove: (i) => setState(() => _images.removeAt(i)),
        ),

        // ── Serial Number ─────────────────────────────────────
        _FieldLabel('Serial Number'),
        _InputField(
          controller: _serialCtrl,
          hint: 'Put Valid Serial for Verification',
          prefix: Icons.qr_code_outlined,
        ),

        // ── More Options (expandable) ─────────────────────────
        _MoreOptionsSection(
          expanded: _moreExpanded,
          onToggle: () => setState(() => _moreExpanded = !_moreExpanded),
          children: [
            _FieldLabel('Condition'),
            _InputField(controller: _conditionCtrl, hint: 'New / Used / Refurbished'),
            _FieldLabel('Brand'),
            _InputField(controller: _brandCtrl, hint: 'Brand name'),
            _FieldLabel('Negotiable'),
            _DropdownField(
              value: 'Yes',
              items: const ['Yes', 'No'],
              onChanged: (_) {},
            ),
          ],
        ),

        const SizedBox(height: 16),
        _PostButton(onTap: _submit, label: 'Post now'),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 2 — CREATE A POST (Other Services)
// ═════════════════════════════════════════════════════════════
class _CreatePostTab extends StatefulWidget {
  const _CreatePostTab();

  @override
  State<_CreatePostTab> createState() => _CreatePostTabState();
}

class _CreatePostTabState extends State<_CreatePostTab> {
  bool _isLink     = true;
  String _category = 'Tutoring';
  bool _moreExpanded = false;
  final _picker    = ImagePicker();
  final List<XFile> _images = [];

  final _titleCtrl     = TextEditingController();
  final _descCtrl      = TextEditingController();
  final _priceCtrl     = TextEditingController();
  final _locationCtrl  = TextEditingController();
  final _serialCtrl    = TextEditingController();
  final _linkCtrl      = TextEditingController();
  final _availCtrl     = TextEditingController();
  final _durationCtrl  = TextEditingController();

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _priceCtrl, _locationCtrl,
      _serialCtrl, _linkCtrl, _availCtrl, _durationCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) setState(() => _images.addAll(picked));
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a title for your service'),
          backgroundColor: _C.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Service posted successfully!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Link / Manual toggle ─────────────────────────────
        _ModeToggle(
          isLink: _isLink,
          onLink:   () => setState(() => _isLink = true),
          onManual: () => setState(() => _isLink = false),
        ),
        const SizedBox(height: 12),

        if (_isLink) ...[
          _FieldLabel('Portfolio / Profile Link'),
          _InputField(
            controller: _linkCtrl,
            hint: 'Link to your portfolio or profile',
            prefix: Icons.link_rounded,
          ),
          const SizedBox(height: 4),
          _InfoBanner(
            text: 'Add your portfolio link so clients can see your work.',
          ),
          const SizedBox(height: 12),
        ],

        // ── Service title ────────────────────────────────────
        _FieldLabel('Title'),
        _InputField(controller: _titleCtrl, hint: 'e.g. Maths Tutoring — Grade 10-12'),

        // ── Description ──────────────────────────────────────
        _FieldLabel('Description'),
        _InputField(
            controller: _descCtrl,
            hint: 'Describe your service in detail…',
            maxLines: 3),

        // ── Category + Rate row ──────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Category'),
                  _DropdownField(
                    value: _category,
                    items: _serviceCategories,
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Price'),
                  _InputField(
                    controller: _priceCtrl,
                    hint: 'R 0 /hr',
                    keyboardType: TextInputType.number,
                    prefix: Icons.paid_outlined,
                  ),
                ]),
          ),
        ]),

        // ── Location ─────────────────────────────────────────
        _FieldLabel('Locations'),
        _InputField(
          controller: _locationCtrl,
          hint: 'Current location / Online',
          prefix: Icons.location_on_outlined,
        ),

        // ── Upload Image ─────────────────────────────────────
        _FieldLabel('Upload Image'),
        _ImageUploadRow(
          images: _images,
          onPickImages: _pickImages,
          onRemove: (i) => setState(() => _images.removeAt(i)),
        ),

        // ── Credentials / Verification ───────────────────────
        _FieldLabel('Serial Number'),
        _InputField(
          controller: _serialCtrl,
          hint: 'Student number or credential reference',
          prefix: Icons.badge_outlined,
        ),

        // ── More Options ─────────────────────────────────────
        _MoreOptionsSection(
          expanded: _moreExpanded,
          onToggle: () => setState(() => _moreExpanded = !_moreExpanded),
          children: [
            _FieldLabel('Availability'),
            _InputField(
                controller: _availCtrl,
                hint: 'e.g. Weekdays after 14:00, Weekends'),
            _FieldLabel('Session Duration'),
            _InputField(
                controller: _durationCtrl, hint: 'e.g. 1 hour per session'),
            _FieldLabel('Mode'),
            _DropdownField(
              value: 'In-Person',
              items: const ['In-Person', 'Online', 'Both'],
              onChanged: (_) {},
            ),
          ],
        ),

        const SizedBox(height: 16),
        _PostButton(onTap: _submit, label: 'Post now'),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 3 — RIDEBUDDY
// ═════════════════════════════════════════════════════════════
class _RidebuddyTab extends StatefulWidget {
  const _RidebuddyTab();

  @override
  State<_RidebuddyTab> createState() => _RidebuddyTabState();
}

class _RidebuddyTabState extends State<_RidebuddyTab> {
  bool _isLink     = true;
  String _category = 'Daily Commute';
  String _seats    = '1';
  bool _moreExpanded = false;
  final _picker    = ImagePicker();
  final List<XFile> _images = [];

  final _titleCtrl     = TextEditingController();
  final _descCtrl      = TextEditingController();
  final _priceCtrl     = TextEditingController();
  final _fromCtrl      = TextEditingController();
  final _toCtrl        = TextEditingController();
  final _dateCtrl      = TextEditingController();
  final _timeCtrl      = TextEditingController();
  final _serialCtrl    = TextEditingController();
  final _plateCtrl     = TextEditingController();
  final _carCtrl       = TextEditingController();

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _priceCtrl, _fromCtrl, _toCtrl,
      _dateCtrl, _timeCtrl, _serialCtrl, _plateCtrl, _carCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) setState(() => _images.addAll(picked));
  }

  void _submit() {
    if (_fromCtrl.text.trim().isEmpty || _toCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in From and To locations'),
          backgroundColor: _C.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🚗 Ridebuddy post published!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Ridebuddy hero info card ──────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _C.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.primary.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Text('🚗', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Share a ride, split the cost. '
                'Post your route and connect with fellow students.',
                style: TextStyle(
                    fontSize: 12,
                    color: _C.dark,
                    height: 1.4),
              ),
            ),
          ]),
        ),

        // ── Link / Manual toggle ─────────────────────────────
        _ModeToggle(
          isLink: _isLink,
          onLink:   () => setState(() => _isLink = true),
          onManual: () => setState(() => _isLink = false),
        ),
        const SizedBox(height: 12),

        // ── Title ────────────────────────────────────────────
        _FieldLabel('Title'),
        _InputField(
            controller: _titleCtrl,
            hint: 'e.g. Joburg CBD → Wits Daily Ride'),

        // ── Description ──────────────────────────────────────
        _FieldLabel('Description'),
        _InputField(
            controller: _descCtrl,
            hint: 'Add Detailed Description',
            maxLines: 3),

        // ── Category + Price row ─────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Category'),
                  _DropdownField(
                    value: _category,
                    items: _rideCategories,
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Price'),
                  _InputField(
                    controller: _priceCtrl,
                    hint: 'R 0 /seat',
                    keyboardType: TextInputType.number,
                    prefix: Icons.paid_outlined,
                  ),
                ]),
          ),
        ]),

        // ── From / To ─────────────────────────────────────────
        _FieldLabel('From'),
        _InputField(
          controller: _fromCtrl,
          hint: 'Departure location',
          prefix: Icons.trip_origin_rounded,
          prefixColor: _C.primary,
        ),
        _FieldLabel('To'),
        _InputField(
          controller: _toCtrl,
          hint: 'Destination',
          prefix: Icons.location_on_rounded,
          prefixColor: const Color(0xFF10B981),
        ),

        // ── Date + Time row ───────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Date'),
                  _InputField(
                    controller: _dateCtrl,
                    hint: 'DD/MM/YYYY',
                    prefix: Icons.calendar_today_outlined,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: _C.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        _dateCtrl.text =
                            '${picked.day}/${picked.month}/${picked.year}';
                      }
                    },
                  ),
                ]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Time'),
                  _InputField(
                    controller: _timeCtrl,
                    hint: 'HH:MM',
                    prefix: Icons.access_time_rounded,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: _C.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        _timeCtrl.text = picked.format(context);
                      }
                    },
                  ),
                ]),
          ),
        ]),

        // ── Seats available ───────────────────────────────────
        _FieldLabel('Seats Available'),
        _DropdownField(
          value: _seats,
          items: ['1', '2', '3', '4', '5', '6', '7'],
          onChanged: (v) => setState(() => _seats = v!),
        ),

        // ── Upload Image ──────────────────────────────────────
        _FieldLabel('Upload Image'),
        _ImageUploadRow(
          images: _images,
          onPickImages: _pickImages,
          onRemove: (i) => setState(() => _images.removeAt(i)),
        ),

        // ── Serial / Vehicle verification ─────────────────────
        _FieldLabel('Serial Number'),
        _InputField(
          controller: _serialCtrl,
          hint: 'Driver\'s licence or vehicle reference',
          prefix: Icons.badge_outlined,
        ),

        // ── More Options ──────────────────────────────────────
        _MoreOptionsSection(
          expanded: _moreExpanded,
          onToggle: () => setState(() => _moreExpanded = !_moreExpanded),
          children: [
            _FieldLabel('Vehicle'),
            _InputField(controller: _carCtrl, hint: 'e.g. Toyota Corolla 2020'),
            _FieldLabel('Number Plate'),
            _InputField(controller: _plateCtrl, hint: 'e.g. CA 123-456'),
            _FieldLabel('Recurring'),
            _DropdownField(
              value: 'Daily',
              items: const ['Once', 'Daily', 'Weekdays', 'Custom'],
              onChanged: (_) {},
            ),
            _FieldLabel('Luggage Allowed'),
            _DropdownField(
              value: 'Small bag only',
              items: const ['No luggage', 'Small bag only', 'Yes'],
              onChanged: (_) {},
            ),
          ],
        ),

        const SizedBox(height: 16),
        _PostButton(onTap: _submit, label: 'Post now'),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═════════════════════════════════════════════════════════════

// ── Mode Toggle (link / manual) ──────────────────────────────
class _ModeToggle extends StatelessWidget {
  final bool isLink;
  final VoidCallback onLink, onManual;

  const _ModeToggle(
      {required this.isLink,
      required this.onLink,
      required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        _Btn('Create a post with link', isLink, onLink),
        _Btn('Create a post manually', !isLink, onManual),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;
  const _Btn(this.text, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1)),
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.w400,
              color: active ? _C.dark : _C.hint,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.dark),
      ),
    );
  }
}

// ── Text input ────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final IconData? prefix;
  final Color? prefixColor;
  final VoidCallback? onTap;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.prefixColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: onTap != null,
        onTap: onTap,
        style: const TextStyle(fontSize: 13, color: _C.dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: _C.hint),
          prefixIcon: prefix != null
              ? Icon(prefix, size: 17,
                  color: prefixColor ?? _C.hint)
              : null,
          contentPadding: EdgeInsets.symmetric(
              horizontal: prefix != null ? 0 : 10, vertical: 11),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: _C.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Dropdown ──────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                size: 18, color: _C.hint),
            style: const TextStyle(fontSize: 13, color: _C.dark),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

// ── Image upload row ──────────────────────────────────────────
class _ImageUploadRow extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemove;

  const _ImageUploadRow({
    required this.images,
    required this.onPickImages,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Browse button (dropdown style like wireframe) ─────
        GestureDetector(
          onTap: onPickImages,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _C.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('browse in png or jpeg',
                    style:
                        TextStyle(fontSize: 12, color: _C.hint)),
                Icon(Icons.keyboard_arrow_down,
                    size: 18, color: _C.hint),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Image preview squares ─────────────────────────────
        Row(
          children: List.generate(6, (i) {
            final hasImage = i < images.length;
            return GestureDetector(
              onTap: hasImage ? () => onRemove(i) : onPickImages,
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasImage
                      ? Colors.transparent
                      : const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasImage
                        ? _C.primary.withOpacity(0.4)
                        : _C.border,
                  ),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(
                          File(images[i].path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined,
                        size: 18, color: _C.hint),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ── Info banner ───────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline,
            size: 14, color: Color(0xFF3B82F6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF3B82F6),
                  height: 1.4)),
        ),
      ]),
    );
  }
}

// ── More Options (expandable section) ────────────────────────
class _MoreOptionsSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _MoreOptionsSection({
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('More Options',
                  style: TextStyle(fontSize: 12, color: _C.dark)),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down,
                    size: 18, color: _C.hint),
              ),
            ],
          ),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: expanded
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children),
              )
            : const SizedBox.shrink(),
      ),
    ]);
  }
}

// ── Post Now button ───────────────────────────────────────────
class _PostButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _PostButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}