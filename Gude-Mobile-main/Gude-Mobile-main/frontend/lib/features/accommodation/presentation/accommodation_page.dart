import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gude_app/services/user_role_service.dart';

const _ink = Color(0xFF17212B);
const _teal = Color(0xFF0B8B78);
const _red = Color(0xFFE30613);
const _canvas = Color(0xFFF5F8F7);

class _Stay {
  final String id, title, area, type, description;
  final int rent;
  final IconData icon;
  final Color color;
  final List<String> features;
  const _Stay(this.id, this.title, this.area, this.type, this.description,
      this.rent, this.icon, this.color, this.features);
}

const _stays = <_Stay>[
  _Stay(
      'studio',
      'The Study Studio',
      'Campus area',
      'Studio',
      'A private space to study, rest and make it your own.',
      4200,
      Icons.apartment_rounded,
      Color(0xFFDBF4EC),
      ['Wi-Fi', 'Furnished', 'Study space']),
  _Stay(
      'share',
      'Campus House Share',
      'Student neighbourhood',
      'Shared',
      'A social shared home with room for your own routine.',
      3100,
      Icons.home_work_rounded,
      Color(0xFFE5EBFF),
      ['Wi-Fi', 'Shared kitchen', 'Laundry']),
  _Stay(
      'room',
      'Quiet Corner Room',
      'Campus area',
      'Private room',
      'A calm room for focused study and a comfortable night.',
      3600,
      Icons.bed_rounded,
      Color(0xFFFFE8DE),
      ['Furnished', 'Study space', 'Secure entry']),
];

class _Review {
  final String id, stayId, author, body;
  final int rating;
  final bool recommend;
  final DateTime date;
  const _Review(this.id, this.stayId, this.author, this.body, this.rating,
      this.recommend, this.date);

  Map<String, dynamic> toJson() => {
        'id': id,
        'stayId': stayId,
        'author': author,
        'body': body,
        'rating': rating,
        'recommend': recommend,
        'date': date.toIso8601String(),
      };

  factory _Review.fromJson(Map<String, dynamic> json) => _Review(
        json['id'] as String,
        json['stayId'] as String,
        json['author'] as String,
        json['body'] as String,
        json['rating'] as int,
        json['recommend'] as bool,
        DateTime.parse(json['date'] as String),
      );
}

class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  final _search = TextEditingController();
  final _school = TextEditingController();
  String _type = 'All';
  bool _savedOnly = false;
  int? _maxRent;
  Set<String> _saved = {};
  List<_Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _school.text = UserRoleService().institutionName.trim();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _school.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final entries = prefs.getStringList('accommodation_reviews_v1') ?? [];
    final reviews = <_Review>[];
    for (final entry in entries) {
      try {
        reviews
            .add(_Review.fromJson(jsonDecode(entry) as Map<String, dynamic>));
      } catch (_) {
        // Ignore malformed older local entries.
      }
    }
    setState(() {
      _saved = (prefs.getStringList('accommodation_saved_v1') ?? []).toSet();
      _reviews = reviews;
      _school.text = prefs.getString('accommodation_school_v1') ?? _school.text;
    });
  }

  Future<void> _toggleSaved(_Stay stay) async {
    setState(() => _saved.contains(stay.id)
        ? _saved.remove(stay.id)
        : _saved.add(stay.id));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('accommodation_saved_v1', _saved.toList());
  }

  Future<void> _saveReview(_Review review) async {
    setState(() => _reviews = [review, ..._reviews]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('accommodation_reviews_v1',
        _reviews.map((r) => jsonEncode(r.toJson())).toList());
  }

  Future<void> _setSchool() async {
    final controller = TextEditingController(text: _school.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your school'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Nelson Mandela University',
            labelText: 'University or college',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    setState(() => _school.text = result);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accommodation_school_v1', result);
  }

  List<_Stay> get _visible {
    final query = _search.text.toLowerCase().trim();
    return _stays.where((stay) {
      return (query.isEmpty ||
              '${stay.title} ${stay.area} ${stay.type} ${stay.features.join(' ')}'
                  .toLowerCase()
                  .contains(query)) &&
          (_type == 'All' || stay.type == _type) &&
          (_maxRent == null || stay.rent <= _maxRent!) &&
          (!_savedOnly || _saved.contains(stay.id));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _campusCard(),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search rooms, studios or features',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final type in [
                          'All',
                          'Private room',
                          'Studio',
                          'Shared'
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: _type == type,
                              onSelected: (_) => setState(() => _type = type),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.bookmark_outline_rounded,
                            size: 17),
                        label: const Text('Saved'),
                        selected: _savedOnly,
                        onSelected: (value) =>
                            setState(() => _savedOnly = value),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _rentSheet,
                        icon: const Icon(Icons.tune_rounded, size: 17),
                        label: Text(
                            _maxRent == null ? 'Budget' : 'Up to R$_maxRent'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Find your fit',
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.w800)),
                      ),
                      Text('${visible.length} places',
                          style: const TextStyle(
                              color: _teal, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Illustrative homes to explore the experience',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 12),
                  if (visible.isEmpty)
                    _emptyState()
                  else
                    for (final stay in visible) ...[
                      _stayCard(stay),
                      const SizedBox(height: 12),
                    ],
                  _safetyCard(),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        color: _ink,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 23),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.apartment_rounded,
                  color: Colors.white, size: 27),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accommodation',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800)),
                  Text('A place to feel at home',
                      style: TextStyle(color: Color(0xFFB8E7DD), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.location_city_rounded, color: Color(0xFF8DE2CE)),
          ],
        ),
      );

  Widget _campusCard() => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFE2F4EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBCE6DA)),
        ),
        child: Row(children: [
          const CircleAvatar(
            backgroundColor: _teal,
            child: Icon(Icons.school_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Find a place near your school',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 3),
              Text(
                  _school.text.isEmpty
                      ? 'Add your university or college'
                      : _school.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: _teal)),
            ]),
          ),
          IconButton(
            tooltip: 'Choose school',
            onPressed: _setSchool,
            icon: const Icon(Icons.edit_location_alt_rounded, color: _teal),
          ),
        ]),
      );

  Widget _stayCard(_Stay stay) {
    final reviews =
        _reviews.where((review) => review.stayId == stay.id).toList();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDetails(stay),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 112,
              width: double.infinity,
              decoration: BoxDecoration(
                color: stay.color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(children: [
                Center(child: Icon(stay.icon, size: 63, color: _ink)),
                const Positioned(
                  left: 10,
                  top: 10,
                  child: _Tag('DEMO LISTING', _ink, Colors.white),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: IconButton(
                    tooltip: _saved.contains(stay.id)
                        ? 'Remove saved place'
                        : 'Save place',
                    onPressed: () => _toggleSaved(stay),
                    icon: Icon(
                        _saved.contains(stay.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _red),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Text(stay.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800))),
              Text('R${stay.rent}/mo',
                  style: const TextStyle(
                      color: _teal, fontSize: 16, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 5),
            Text('${stay.type} • ${stay.area}',
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final feature in stay.features)
                _Tag(feature, _teal, const Color(0xFFEAF8F3)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.rate_review_outlined, color: _teal, size: 17),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(
                      reviews.isEmpty
                          ? 'Be the first to review'
                          : '${reviews.length} student review${reviews.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54))),
              const Text('View profile',
                  style: TextStyle(
                      color: _red, fontWeight: FontWeight.w800, fontSize: 12)),
              const Icon(Icons.chevron_right_rounded, color: _red),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: const Column(children: [
          Icon(Icons.search_off_rounded, size: 38, color: _teal),
          SizedBox(height: 9),
          Text('No places match those filters',
              style: TextStyle(fontWeight: FontWeight.w700)),
          Text('Try another type, budget or search term.'),
        ]),
      );

  Widget _safetyCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF2E0),
            borderRadius: BorderRadius.circular(17)),
        child:
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.verified_user_outlined, color: Color(0xFFB86D08)),
          SizedBox(width: 10),
          Expanded(
              child: Text(
                  'Stay smart: tour the place, check the lease and confirm who owns it before paying a deposit. Demo listings are not bookable.',
                  style: TextStyle(fontSize: 12, height: 1.4))),
        ]),
      );

  void _rentSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Monthly rent budget',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                for (final amount in <int?>[null, 3000, 3500, 4000, 4500])
                  ListTile(
                    title:
                        Text(amount == null ? 'Any budget' : 'Up to R$amount'),
                    trailing: _maxRent == amount
                        ? const Icon(Icons.check, color: _teal)
                        : null,
                    onTap: () {
                      setState(() => _maxRent = amount);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ]),
        ),
      ),
    );
  }

  void _showDetails(_Stay stay) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _canvas,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, refresh) {
          final reviews = _reviews.where((r) => r.stayId == stay.id).toList();
          final average = reviews.isEmpty
              ? null
              : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  reviews.length;
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 25),
                children: [
                  Container(
                      height: 148,
                      decoration: BoxDecoration(
                          color: stay.color,
                          borderRadius: BorderRadius.circular(20)),
                      child: Icon(stay.icon, size: 82, color: _ink)),
                  const SizedBox(height: 14),
                  const _Tag('DEMO LISTING', _ink, Color(0xFFE6ECEA)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: Text(stay.title,
                            style: const TextStyle(
                                fontSize: 23, fontWeight: FontWeight.w800))),
                    IconButton(
                      tooltip: 'Save place',
                      onPressed: () async {
                        await _toggleSaved(stay);
                        refresh(() {});
                      },
                      icon: Icon(
                          _saved.contains(stay.id)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _red),
                    ),
                  ]),
                  Text('R${stay.rent} per month • ${stay.type} • ${stay.area}',
                      style: const TextStyle(
                          color: _teal, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(stay.description),
                  const SizedBox(height: 15),
                  Wrap(spacing: 7, runSpacing: 7, children: [
                    for (final feature in stay.features)
                      _Tag(feature, _teal, const Color(0xFFE0F3EC)),
                  ]),
                  const SizedBox(height: 20),
                  const Text('Before you choose',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text(
                      'Ask about the deposit, utilities, transport to campus, safety and the written lease. Exact distance and availability are not verified.'),
                  const SizedBox(height: 22),
                  Row(children: [
                    const Expanded(
                        child: Text('Student reviews',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800))),
                    if (average != null) ...[
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB11B), size: 19),
                      Text('${average.toStringAsFixed(1)} / 5'),
                    ],
                  ]),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    const Text(
                        'No reviews yet. Share an honest experience to help other students.',
                        style: TextStyle(color: Colors.black54))
                  else
                    for (final review in reviews) _reviewTile(review),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: _red,
                        minimumSize: const Size(double.infinity, 48)),
                    onPressed: () async {
                      await _reviewSheet(stay);
                      refresh(() {});
                    },
                    icon: const Icon(Icons.rate_review_rounded),
                    label: const Text('Write a review'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      'Reviews are stored on this device for the demo. Real listings and bookings need a connected accommodation service.',
                      style: TextStyle(fontSize: 11, color: Colors.black54)),
                ]),
          );
        },
      ),
    );
  }

  Widget _reviewTile(_Review review) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(review.author,
                    style: const TextStyle(fontWeight: FontWeight.w800))),
            Text('${review.rating}/5 ★',
                style: const TextStyle(
                    color: Color(0xFFB87300), fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 3),
          Text(review.recommend ? 'Would recommend' : 'Would not recommend',
              style: TextStyle(
                  fontSize: 11, color: review.recommend ? _teal : _red)),
          const SizedBox(height: 8),
          Text(review.body),
        ]),
      );

  Future<void> _reviewSheet(_Stay stay) async {
    final body = TextEditingController();
    var rating = 5;
    var anonymous = true;
    var recommend = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, refresh) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 20),
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share your experience',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(stay.title),
              const SizedBox(height: 14),
              Wrap(children: [
                for (var value = 1; value <= 5; value++)
                  IconButton(
                    tooltip: '$value stars',
                    onPressed: () => refresh(() => rating = value),
                    icon: Icon(
                        value <= rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFFB11B),
                        size: 32),
                  ),
              ]),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('I would recommend it'),
                value: recommend,
                onChanged: (value) => refresh(() => recommend = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Post anonymously'),
                subtitle:
                    const Text('Your name will not appear on this review'),
                value: anonymous,
                onChanged: (value) => refresh(() => anonymous = value),
              ),
              TextField(
                controller: body,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'What should other students know?',
                  hintText: 'Share the good and the not-so-good...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    minimumSize: const Size(double.infinity, 48)),
                onPressed: () async {
                  final comment = body.text.trim();
                  if (comment.length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please write at least 10 characters.')),
                    );
                    return;
                  }
                  final name = UserRoleService().userName.trim();
                  await _saveReview(_Review(
                    DateTime.now().microsecondsSinceEpoch.toString(),
                    stay.id,
                    anonymous
                        ? 'Anonymous student'
                        : (name.isEmpty ? 'Student' : name),
                    comment,
                    rating,
                    recommend,
                    DateTime.now(),
                  ));
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: const Text('Post review'),
              ),
            ],
          )),
        ),
      ),
    );
    body.dispose();
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color foreground, background;
  const _Tag(this.label, this.foreground, this.background);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(9)),
        child: Text(label,
            style: TextStyle(
                color: foreground, fontSize: 10, fontWeight: FontWeight.w800)),
      );
}
