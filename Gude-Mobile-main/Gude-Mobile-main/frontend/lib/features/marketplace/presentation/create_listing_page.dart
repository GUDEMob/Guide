// lib/features/marketplace/presentation/create_listing_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});
  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Listing',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Sell an Item'),
            Tab(text: 'Offer a Service'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _SellItemForm(),
          _OfferServiceForm(),
        ],
      ),
    );
  }
}

// ─── Sell Item Form ───────────────────────────────────────────────────
class _SellItemForm extends StatefulWidget {
  const _SellItemForm();
  @override
  State<_SellItemForm> createState() => _SellItemFormState();
}

class _SellItemFormState extends State<_SellItemForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedCategory = 'Electronics';
  String _selectedCondition = 'Good';
  bool _isAvailable = true;
  bool _negotiable = false;

  static const _categories = [
    'Electronics',
    'Furniture',
    'Books',
    'Stationery',
    'Clothes',
    'Bags',
    'Appliances',
    'Other',
  ];
  static const _conditions = ['New', 'Like New', 'Good', 'Fair'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in Title and Price'),
            backgroundColor: AppColors.primary),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Listing Created! 🎉',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '"${_titleCtrl.text}" has been listed for R${_priceCtrl.text}. '
          'Other students and buyers can now see and purchase your item. '
          'They will be able to view your profile when they tap on your listing.',
          style: const TextStyle(
              fontSize: 13, color: Color(0xFF555555), height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            const Expanded(
                child: Text(
              'Buyers and other students can view your profile when they tap on your listing. Make sure your profile is up to date!',
              style: TextStyle(
                  fontSize: 11, color: AppColors.primary, height: 1.4),
            )),
          ]),
        ),
        // Title
        _card(children: [
          _label('Item Title *'),
          TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  hintText: 'e.g. iPhone 12 Pro – 128GB Black')),
          const SizedBox(height: 16),
          _label('Category'),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
        ]),
        const SizedBox(height: 12),
        // Price & Condition
        _card(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Price (ZAR) *'),
                  TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: 'e.g. 1200', prefixText: 'R ')),
                ])),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Location'),
                  TextField(
                      controller: _locationCtrl,
                      decoration:
                          const InputDecoration(hintText: 'e.g. Cape Town')),
                ])),
          ]),
          const SizedBox(height: 14),
          _label('Condition'),
          const SizedBox(height: 8),
          Row(
              children: _conditions.map((c) {
            final sel = _selectedCondition == c;
            return Expanded(
                child: GestureDetector(
              onTap: () => setState(() => _selectedCondition = c),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color:
                      sel ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  border: Border.all(
                      color: sel ? AppColors.primary : AppColors.inputBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(c,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel ? AppColors.primary : AppColors.textGrey)),
              ),
            ));
          }).toList()),
          const SizedBox(height: 14),
          // Availability toggle
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Available Now',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const Text('Turn off if already sold or reserved',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ]),
            Switch(
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
                activeColor: AppColors.primary),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price Negotiable',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text('Allow buyers to make offers',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textGrey)),
                ]),
            Switch(
                value: _negotiable,
                onChanged: (v) => setState(() => _negotiable = v),
                activeColor: AppColors.primary),
          ]),
        ]),
        const SizedBox(height: 12),
        // Description
        _card(children: [
          _label('Description *'),
          TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                  hintText:
                      'Describe the item in detail — brand, model, specs, reason for selling, any defects...')),
          const SizedBox(height: 14),
          _label('Photos (optional)'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.inputBorder, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(Icons.upload_file_outlined,
                        color: AppColors.textGrey, size: 32),
                    SizedBox(height: 8),
                    Text('Upload item photos',
                        style:
                            TextStyle(color: AppColors.textGrey, fontSize: 13)),
                  ])),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('List Item for Sale',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark)),
    );
  }
}

// ─── Offer Service Form ───────────────────────────────────────────────
class _OfferServiceForm extends StatefulWidget {
  const _OfferServiceForm();
  @override
  State<_OfferServiceForm> createState() => _OfferServiceFormState();
}

class _OfferServiceFormState extends State<_OfferServiceForm> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedCategory = 'Academic';
  final Set<String> _selectedDays = {};
  bool _onlineAvailable = true;
  bool _inPerson = true;

  static const _categories = [
    'Academic',
    'Creative',
    'Digital',
    'Professional',
    'Lifestyle'
  ];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in Service Name and Price'),
            backgroundColor: AppColors.primary),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Service Listed! 🎉',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '"${_nameCtrl.text}" is now live. Students and buyers searching for this skill will find your profile. '
          'They can view your full profile, message you, and request your services.',
          style: const TextStyle(
              fontSize: 13, color: Color(0xFF555555), height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                color: Color(0xFF3B82F6), size: 16),
            const SizedBox(width: 8),
            const Expanded(
                child: Text(
              'Your service will appear in the Skills & Services tab. Students and institutions can find you by skill and view your full profile.',
              style: TextStyle(
                  fontSize: 11, color: Color(0xFF1E3A5F), height: 1.4),
            )),
          ]),
        ),
        _card(children: [
          _label('Service Name *'),
          TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  hintText: 'e.g. Maths Tutoring – Grade 12 & First Year')),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Category'),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.inputBorder)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14)),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ])),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _label('Price / Rate *'),
                  TextField(
                      controller: _priceCtrl,
                      decoration:
                          const InputDecoration(hintText: 'e.g. R150/hr')),
                ])),
          ]),
        ]),
        const SizedBox(height: 12),
        _card(children: [
          _label('Description *'),
          TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText:
                      'Describe your service, experience level, what clients can expect, and any requirements...')),
          const SizedBox(height: 14),
          _label('Availability (select days)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _days.map((d) {
              final sel = _selectedDays.contains(d);
              return GestureDetector(
                onTap: () => setState(() {
                  sel ? _selectedDays.remove(d) : _selectedDays.add(d);
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(d,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.textGrey)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Delivery mode
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Online',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text('Via video call or remote',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textGrey)),
                ]),
            Switch(
                value: _onlineAvailable,
                onChanged: (v) => setState(() => _onlineAvailable = v),
                activeColor: AppColors.primary),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('In-Person',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text('Face-to-face sessions',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textGrey)),
                ]),
            Switch(
                value: _inPerson,
                onChanged: (v) => setState(() => _inPerson = v),
                activeColor: AppColors.primary),
          ]),
        ]),
        const SizedBox(height: 12),
        _card(children: [
          _label('Portfolio (optional)'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.inputBorder)),
              child: const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(Icons.upload_file_outlined,
                        color: AppColors.textGrey, size: 32),
                    SizedBox(height: 6),
                    Text('Upload portfolio files',
                        style:
                            TextStyle(color: AppColors.textGrey, fontSize: 13)),
                  ])),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('List My Service',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark)),
    );
  }
}