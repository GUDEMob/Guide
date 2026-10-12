import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/features/accommodation/data/accommodation_demo_store.dart';
import 'package:gude_app/services/user_role_service.dart';

const _red = Color(0xFFE30613);
const _ink = Color(0xFF17212B);
const _teal = Color(0xFF0B8B78);
const _pale = Color(0xFFF5F8F7);

String _date(Object? raw) {
  final date = DateTime.tryParse(raw?.toString() ?? '');
  return date == null ? 'Not set' : '${date.day}/${date.month}/${date.year}';
}

class AccommodationPortalPage extends StatefulWidget {
  const AccommodationPortalPage({super.key});
  @override
  State<AccommodationPortalPage> createState() =>
      _AccommodationPortalPageState();
}

class _AccommodationPortalPageState extends State<AccommodationPortalPage> {
  final store = DemoAccommodationStore.instance;
  String section = 'Explore';
  String type = 'All';
  String viewingFilter = 'All';
  bool availableOnly = false;
  int? maxRent;

  @override
  void initState() {
    super.initState();
    store.load();
  }

  void _error(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error is StateError ? error.message : '$error')));
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _error(error);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) => Scaffold(
          backgroundColor: _pale,
          appBar: AppBar(
            backgroundColor: _ink,
            foregroundColor: Colors.white,
            leading: IconButton(
              tooltip: 'Back to Accommodation',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/accommodation'),
            ),
            title: const Text('Student accommodation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                  tooltip: 'Accommodation notifications',
                  onPressed: _studentNotifications,
                  icon: const Icon(Icons.notifications_outlined)),
            ],
          ),
          body: !store.loaded
              ? const Center(child: CircularProgressIndicator())
              : Column(children: [
                  Container(
                      color: _ink,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      height: 54,
                      child:
                          ListView(scrollDirection: Axis.horizontal, children: [
                        for (final item in const [
                          'Explore',
                          'My accommodation',
                          'My viewings',
                          'Transfers',
                          'Notice board',
                        ])
                          Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: ChoiceChip(
                                  label: Text(item),
                                  selected: section == item,
                                  onSelected: (_) =>
                                      setState(() => section = item))),
                      ])),
                  Expanded(
                      child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                        const Text('FRONTEND DEMO • saved on this device',
                            style: TextStyle(
                                color: _teal,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 1)),
                        const SizedBox(height: 12),
                        switch (section) {
                          'My accommodation' => _myAccommodation(),
                          'My viewings' => _viewings(),
                          'Transfers' => _transfers(),
                          'Notice board' => _noticeBoard(),
                          _ => _explore(),
                        },
                      ])),
                ]),
        ),
      );

  Widget _explore() {
    final items = demoProperties.where((p) {
      final status = store.viewingStatus(p.id);
      return (type == 'All' || type == p.type) &&
          (maxRent == null || p.rent <= maxRent!) &&
          (!availableOnly || store.availableRooms(p.id) > 0) &&
          (viewingFilter == 'All' ||
              (viewingFilter == 'Viewed' && status == ViewingStatus.viewed) ||
              (viewingFilter == 'Not Viewed' &&
                  status != ViewingStatus.viewed));
    }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Find a place that fits', style: _heading),
      const SizedBox(height: 5),
      const Text(
          'Demo properties: locations, prices and rooms are illustrative.',
          style: _muted),
      const SizedBox(height: 12),
      SizedBox(
          height: 43,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final choice in const [
              'All',
              'Studio',
              'Shared',
              'Private room'
            ])
              Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ChoiceChip(
                      label: Text(choice),
                      selected: type == choice,
                      onSelected: (_) => setState(() => type = choice)))
          ])),
      Wrap(spacing: 7, children: [
        for (final choice in const ['All', 'Viewed', 'Not Viewed'])
          ChoiceChip(
              label: Text(choice),
              selected: viewingFilter == choice,
              onSelected: (_) => setState(() => viewingFilter = choice)),
        FilterChip(
            label: const Text('Rooms available'),
            selected: availableOnly,
            onSelected: (value) => setState(() => availableOnly = value)),
      ]),
      DropdownButton<int?>(
          value: maxRent,
          items: const [
            DropdownMenuItem(value: null, child: Text('Any monthly budget')),
            DropdownMenuItem(value: 3200, child: Text('Up to R3 200')),
            DropdownMenuItem(value: 3800, child: Text('Up to R3 800')),
            DropdownMenuItem(value: 4500, child: Text('Up to R4 500')),
          ],
          onChanged: (value) => setState(() => maxRent = value)),
      const SizedBox(height: 6),
      if (items.isEmpty)
        _panel(const Text('No demo properties match these filters.')),
      for (final p in items) ...[_propertyCard(p), const SizedBox(height: 12)],
    ]);
  }

  Widget _propertyCard(DemoProperty p) =>
      _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 76,
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color(0xFFE1F3EE),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.apartment_rounded, size: 49, color: _teal)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: Text(p.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800))),
          Text('R${p.rent}/mo',
              style: const TextStyle(color: _red, fontWeight: FontWeight.w800))
        ]),
        Text('${p.area} • ${p.type} • ${store.availableRooms(p.id)} demo rooms',
            style: _muted),
        const SizedBox(height: 5),
        Text(store.viewingStatus(p.id).label,
            style: const TextStyle(color: _teal, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(spacing: 7, runSpacing: 7, children: [
          OutlinedButton(
              onPressed: () => _details(p), child: const Text('View details')),
          OutlinedButton(
              onPressed: () => _run(() => store.requestViewing(p.id)),
              child: const Text('Request viewing')),
          FilledButton(
              onPressed: () => _requestForm(p),
              style: FilledButton.styleFrom(backgroundColor: _red),
              child: Text(store.currentName.isEmpty
                  ? 'Request move-in'
                  : 'Request transfer')),
        ]),
      ]));

  Future<void> _details(DemoProperty p) async {
    await store.recordProfileVisit();
    if (!mounted) return;
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheet) => FractionallySizedBox(
            heightFactor: 0.8,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Container(
                  height: 140,
                  color: const Color(0xFFE1F3EE),
                  child: const Icon(Icons.apartment_rounded,
                      size: 78, color: _teal)),
              const SizedBox(height: 14),
              Text(p.name, style: _heading),
              Text('${p.area} • ${p.type} • R${p.rent}/month'),
              const SizedBox(height: 10),
              Text(p.description),
              const SizedBox(height: 10),
              Text('Facilities: ${p.facilities.join(', ')}'),
              Text('Contact: ${p.contact}'),
              Text('Availability: ${store.availableRooms(p.id)} demo rooms'),
              const SizedBox(height: 14),
              Text('Physical viewing: ${store.viewingStatus(p.id).label}',
                  style: const TextStyle(
                      color: _teal, fontWeight: FontWeight.w700)),
              const Text('Opening this profile does not mark it as viewed.',
                  style: _muted),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheet);
                    _requestForm(p);
                  },
                  icon: const Icon(Icons.move_up_rounded),
                  label: const Text('Request to move in')),
            ])));
  }

  Widget _myAccommodation() {
    final p = propertyById(store.activePropertyId);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('My accommodation', style: _heading),
      const SizedBox(height: 12),
      _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.home_work_rounded, color: _teal, size: 34),
        const SizedBox(height: 8),
        Text(
            store.currentName.isEmpty
                ? 'You are not currently registered with an accommodation.'
                : store.currentName,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        if (store.currentName.isNotEmpty) ...[
          Text(store.currentArea, style: _muted),
          Text(
              'Room: ${store.currentRoom.isEmpty ? 'Not assigned' : store.currentRoom}'),
          Text(
              'Membership: ${p == null ? 'Self-reported (demo)' : 'Active demo membership'}'),
          Text('Move-in: ${_date(store.moveInDate)}'),
          Text(
              'Contact: ${store.currentContact.isEmpty ? 'Not provided' : store.currentContact}'),
        ],
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (p != null)
            OutlinedButton.icon(
                onPressed: () => setState(() => section = 'Notice board'),
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Notice board')),
          FilledButton.icon(
              onPressed: () => setState(() => section = 'Explore'),
              icon: const Icon(Icons.move_up_rounded),
              label: Text(store.currentName.isEmpty
                  ? 'Browse accommodation'
                  : 'Request to Move')),
        ]),
      ])),
      const SizedBox(height: 20),
      const Text('Accommodation history', style: _heading),
      const SizedBox(height: 8),
      if (store.history.isEmpty)
        _panel(const Text('No previous accommodation yet.')),
      for (final entry in store.history)
        _panel(ListTile(
            title: Text(entry['name'] as String? ?? ''),
            subtitle: Text('Moved out: ${_date(entry['moveOut'])}'))),
    ]);
  }

  Widget _viewings() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('My viewings', style: _heading),
        const SizedBox(height: 8),
        Text(
            'Profile opens: ${store.profileVisits} • Physical visits are tracked separately.',
            style: _muted),
        const SizedBox(height: 12),
        if (store.viewings.isEmpty)
          _panel(const Text('No viewings yet. Explore places to request one.')),
        for (final item in store.viewings) ...[
          _panel(
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                propertyById(item['propertyId'] as String?)?.name ??
                    'Accommodation',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(store.viewingStatus(item['propertyId'] as String).label,
                style: const TextStyle(color: _teal)),
            Text('Scheduled: ${_date(item['scheduledAt'])}', style: _muted),
            if (store.viewingStatus(item['propertyId'] as String) ==
                ViewingStatus.scheduled)
              OutlinedButton(
                  onPressed: () => _run(() => store.updateViewing(
                      item['propertyId'] as String,
                      ViewingStatus.awaitingConfirmation)),
                  child: const Text('I attended — ask manager to confirm')),
          ])),
          const SizedBox(height: 10),
        ],
      ]);

  Widget _transfers() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Transfer requests', style: _heading),
        const SizedBox(height: 10),
        if (store.requests.isEmpty)
          _panel(const Text('No requests yet. Choose a place in Explore.')),
        for (final item in store.requests) ...[
          _panel(
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                '${item['fromName'] == '' ? 'First accommodation' : item['fromName']} → ${propertyById(item['toPropertyId'] as String?)?.name ?? 'Accommodation'}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            _status(item['status'] as String),
            Text('Requested move-in: ${_date(item['moveIn'])}', style: _muted),
            if ((item['rejectionReason'] as String? ?? '').isNotEmpty)
              Text('Reason: ${item['rejectionReason']}'),
            if ((item['infoRequest'] as String? ?? '').isNotEmpty)
              Text('Manager asks: ${item['infoRequest']}'),
            if (item['status'] == TransferStatus.moreInfo.name)
              OutlinedButton(
                  onPressed: () => _replyToManager(item),
                  child: const Text('Send additional information')),
            const Divider(),
            const Text('Timeline',
                style: TextStyle(fontWeight: FontWeight.w800)),
            for (final event in (item['events'] as List).cast<Map>())
              Text(
                  '• ${event['text']} — ${event['actor']} (${_date(event['at'])})',
                  style: _muted),
            if (item['status'] == TransferStatus.pending.name ||
                item['status'] == TransferStatus.moreInfo.name)
              TextButton(
                  onPressed: () =>
                      _run(() => store.cancelRequest(item['id'] as String)),
                  child: const Text('Cancel pending request')),
            for (final message in store.messages.where((m) =>
                m['requestId'] == item['id'] && m['studentVisible'] == true))
              Text('Manager update: ${message['text']}',
                  style: const TextStyle(color: _teal)),
          ])),
          const SizedBox(height: 10),
        ],
      ]);

  Widget _noticeBoard() {
    final propertyId = store.activePropertyId;
    final p = propertyById(propertyId);
    if (p == null) {
      return _panel(const Text(
          'Private notices are available after a completed move into a demo property.'));
    }
    final notices =
        store.notices.where((n) => n['propertyId'] == propertyId).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${p.name} notice board', style: _heading),
      const Text(
          'Welcome to your new accommodation! You can now access announcements, updates and important information from your accommodation.',
          style: _muted),
      const SizedBox(height: 12),
      if (notices.isEmpty)
        _panel(const Text('No notices have been posted yet.')),
      for (final notice in notices) ...[
        _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notice['category'] as String,
              style:
                  const TextStyle(color: _teal, fontWeight: FontWeight.w800)),
          Text(notice['text'] as String),
          Text(_date(notice['at']), style: _muted),
        ])),
        const SizedBox(height: 8),
      ],
    ]);
  }

  Future<void> _requestForm(DemoProperty p) async {
    final name = UserRoleService().userName.trim();
    final lastId = store.requests.isEmpty
        ? ''
        : store.requests.first['studentId'] as String;
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TransferForm(
          property: p,
          studentName: name,
          studentId: lastId,
          currentName: store.currentName),
    );
    if (result == null) return;
    try {
      await store.submitRequest(
          studentName: result['name']!,
          studentId: result['studentId']!,
          toPropertyId: p.id,
          moveIn: result['moveIn']!,
          moveOut: result['moveOut']!,
          reason: result['reason']!,
          comments: result['comments']!);
      if (!mounted) return;
      setState(() => section = 'Transfers');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Your transfer request has been submitted successfully. You will be notified once the accommodation has reviewed your request.')));
    } catch (error) {
      _error(error);
    }
  }

  Future<void> _replyToManager(Map<String, dynamic> request) async {
    String reply = '';
    final send = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Reply to accommodation'),
              content: TextField(
                  maxLines: 3,
                  onChanged: (value) => reply = value,
                  decoration: const InputDecoration(
                      labelText: 'Additional information',
                      border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Send')),
              ],
            ));
    if (send == true) {
      _run(() => store.studentReply(request['id'] as String, reply));
    }
  }

  void _studentNotifications() {
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) =>
            ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Accommodation updates', style: _heading),
              for (final item in store.notifications
                  .where((n) => n['audience'] == 'student'))
                ListTile(
                    leading:
                        const Icon(Icons.notifications_rounded, color: _teal),
                    title: Text(item['text'] as String),
                    subtitle: Text(_date(item['at'])),
                    onTap: () {
                      Navigator.pop(sheet);
                      setState(() => section =
                          (item['text'] as String).contains('Viewing')
                              ? 'My viewings'
                              : 'Transfers');
                    }),
            ]));
  }
}

const _heading =
    TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _ink);
const _muted = TextStyle(fontSize: 12, color: Colors.black54, height: 1.4);

Widget _panel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5ECEA))),
    child: child);

Widget _status(String raw) {
  final status = TransferStatus.values.byName(raw);
  final color = switch (status) {
    TransferStatus.completed => _teal,
    TransferStatus.rejected || TransferStatus.cancelled => _red,
    TransferStatus.pending ||
    TransferStatus.moreInfo =>
      const Color(0xFFB97300),
    _ => const Color(0xFF0866E9),
  };
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(status.label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w800, fontSize: 12)));
}

class _TransferForm extends StatefulWidget {
  final DemoProperty property;
  final String studentName, studentId, currentName;
  const _TransferForm(
      {required this.property,
      required this.studentName,
      required this.studentId,
      required this.currentName});
  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  late String name = widget.studentName;
  late String studentId = widget.studentId;
  String reason = '', comments = '';
  DateTime? moveIn, moveOut;

  Future<void> _pick(bool incoming) async {
    final picked = await showDatePicker(
        context: context,
        initialDate:
            incoming ? (moveIn ?? DateTime.now()) : (moveOut ?? DateTime.now()),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));
    if (picked != null && mounted) {
      setState(() {
        if (incoming) {
          moveIn = picked;
        } else {
          moveOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 0, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
        child: FractionallySizedBox(
            heightFactor: 0.82,
            child: ListView(children: [
              const Text('Request accommodation', style: _heading),
              const SizedBox(height: 6),
              Text(
                  '${widget.currentName.isEmpty ? 'First accommodation' : widget.currentName} → ${widget.property.name}',
                  style: _muted),
              const SizedBox(height: 14),
              TextFormField(
                  initialValue: name,
                  onChanged: (v) => name = v,
                  decoration: const InputDecoration(
                      labelText: 'Student name', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextFormField(
                  initialValue: studentId,
                  onChanged: (v) => studentId = v,
                  decoration: const InputDecoration(
                      labelText: 'Student number / ID',
                      helperText: 'Not stored by the existing signup flow',
                      border: OutlineInputBorder())),
              ListTile(
                  title: const Text('Expected move-out'),
                  subtitle: Text(_date(moveOut?.toIso8601String())),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: () => _pick(false)),
              ListTile(
                  title: const Text('Preferred move-in'),
                  subtitle: Text(_date(moveIn?.toIso8601String())),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: () => _pick(true)),
              TextFormField(
                  onChanged: (v) => reason = v,
                  decoration: const InputDecoration(
                      labelText: 'Reason (optional)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextFormField(
                  maxLines: 2,
                  onChanged: (v) => comments = v,
                  decoration: const InputDecoration(
                      labelText: 'Additional comments (optional)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: () {
                    if (name.trim().isEmpty ||
                        studentId.trim().isEmpty ||
                        moveIn == null ||
                        moveOut == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Add your identity and both move dates.')));
                      return;
                    }
                    Navigator.pop(context, {
                      'name': name,
                      'studentId': studentId,
                      'moveIn': moveIn!.toIso8601String(),
                      'moveOut': moveOut!.toIso8601String(),
                      'reason': reason,
                      'comments': comments,
                    });
                  },
                  style: FilledButton.styleFrom(backgroundColor: _red),
                  child: const Text('Submit Transfer Request')),
            ])),
      );
}
