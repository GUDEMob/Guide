import 'package:flutter/material.dart';
import 'package:gude_app/features/accommodation/data/accommodation_demo_store.dart';

const _ink = Color(0xFF17212B);
const _teal = Color(0xFF0B8B78);
const _red = Color(0xFFE30613);

class AccommodationManagerDemoPage extends StatefulWidget {
  const AccommodationManagerDemoPage({super.key});
  @override
  State<AccommodationManagerDemoPage> createState() =>
      _AccommodationManagerDemoPageState();
}

class _AccommodationManagerDemoPageState
    extends State<AccommodationManagerDemoPage> {
  final store = DemoAccommodationStore.instance;
  String propertyId = demoProperties.first.id;
  String tab = 'Overview';

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
      builder: (context, _) {
        final property = propertyById(propertyId)!;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F8F7),
          appBar: AppBar(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              title: const Text('Accommodation manager demo',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                    tooltip: 'Manager updates',
                    onPressed: _updates,
                    icon: const Icon(Icons.notifications_outlined))
              ]),
          body: !store.loaded
              ? const Center(child: CircularProgressIndicator())
              : Column(children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'DEMO MODE • anyone on this device can switch properties',
                                style: TextStyle(
                                    color: _red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                            DropdownButton<String>(
                                isExpanded: true,
                                value: propertyId,
                                items: [
                                  for (final p in demoProperties)
                                    DropdownMenuItem(
                                        value: p.id, child: Text(p.name))
                                ],
                                onChanged: (v) =>
                                    setState(() => propertyId = v!)),
                          ])),
                  SizedBox(
                      height: 46,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            for (final choice in const [
                              'Overview',
                              'Residents',
                              'Incoming',
                              'Outgoing',
                              'Viewings',
                              'Notice board',
                              'Messages',
                            ])
                              Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                      label: Text(choice),
                                      selected: tab == choice,
                                      onSelected: (_) =>
                                          setState(() => tab = choice)))
                          ])),
                  Expanded(
                      child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                        switch (tab) {
                          'Residents' => _residents(property),
                          'Incoming' => _incoming(property),
                          'Outgoing' => _outgoing(property),
                          'Viewings' => _viewings(property),
                          'Notice board' => _notices(property),
                          'Messages' => _messages(property),
                          _ => _overview(property),
                        }
                      ])),
                ]),
        );
      });

  Widget _overview(DemoProperty p) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: _heading),
        const SizedBox(height: 6),
        const Text('Illustrative capacity; not a live property inventory.',
            style: _muted),
        const SizedBox(height: 12),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              '${store.availableRooms(p.id)} / ${p.capacity} demo rooms available',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
              '${store.requests.where((r) => r['toPropertyId'] == p.id && r['status'] == TransferStatus.pending.name).length} pending incoming requests'),
          Text(
              '${store.requests.where((r) => r['fromPropertyId'] == p.id && TransferStatus.values.byName(r['status'] as String).active).length} outgoing moves'),
        ])),
        const SizedBox(height: 12),
        const Text(
            'Approvals do not switch the resident’s home. Confirm move-in separately on or after the effective date.',
            style: _muted),
      ]);

  Widget _residents(DemoProperty p) {
    final current = store.activePropertyId == p.id;
    final incoming = store.requests
        .where((r) =>
            r['toPropertyId'] == p.id &&
            TransferStatus.values.byName(r['status'] as String).active)
        .toList();
    final outgoing = store.requests
        .where((r) =>
            r['fromPropertyId'] == p.id &&
            TransferStatus.values.byName(r['status'] as String).active)
        .toList();
    final former = store.history.where((h) => h['name'] == p.name).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Resident records', style: _heading),
      _group(
          'Current residents',
          current
              ? [
                  '${store.requests.where((r) => r['status'] == TransferStatus.completed.name).isEmpty ? 'Demo student' : store.requests.firstWhere((r) => r['status'] == TransferStatus.completed.name)['studentName']} • Room ${store.currentRoom.isEmpty ? 'unassigned' : store.currentRoom}'
                ]
              : []),
      _group('Incoming residents',
          incoming.map((r) => '${r['studentName']} • ${_label(r)}').toList()),
      _group('Outgoing residents',
          outgoing.map((r) => '${r['studentName']} • ${_label(r)}').toList()),
      _group(
          'Former residents',
          former
              .map((h) => 'Demo student • moved out ${_date(h['moveOut'])}')
              .toList()),
    ]);
  }

  Widget _group(String title, List<String> items) => Padding(
      padding: const EdgeInsets.only(top: 15),
      child:
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        if (items.isEmpty) const Text('No records yet.', style: _muted),
        for (final item in items)
          Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(item)),
      ])));

  Widget _incoming(DemoProperty p) {
    final items =
        store.requests.where((r) => r['toPropertyId'] == p.id).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Incoming students', style: _heading),
      const SizedBox(height: 12),
      if (items.isEmpty) _card(const Text('No incoming requests yet.')),
      for (final r in items) ...[
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r['studentName'] as String,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text('Student ID: ${r['studentId']}'),
          Text(
              'From: ${r['fromName'] == '' ? 'First accommodation' : r['fromName']}'),
          Text(
              'Requested: ${_date(r['moveIn'])} • Submitted: ${_date(r['createdAt'])}',
              style: _muted),
          Text(
              'Room: ${(r['room'] as String).isEmpty ? 'Not assigned' : r['room']}'),
          Text(_label(r),
              style:
                  const TextStyle(color: _teal, fontWeight: FontWeight.w800)),
          if (r['status'] == TransferStatus.pending.name ||
              r['status'] == TransferStatus.moreInfo.name)
            Wrap(spacing: 5, children: [
              FilledButton(
                  onPressed: () => _run(() => store.managerDecision(
                      r['id'] as String, p.id, TransferStatus.approved)),
                  child: const Text('Approve')),
              TextButton(
                  onPressed: () => _decisionDialog(r, TransferStatus.rejected),
                  child: const Text('Reject')),
              TextButton(
                  onPressed: () => _decisionDialog(r, TransferStatus.moreInfo),
                  child: const Text('Request info')),
            ]),
          if (r['status'] == TransferStatus.approved.name)
            OutlinedButton(
                onPressed: () => _schedule(r),
                child: const Text('Schedule move-in & assign room')),
          if (r['status'] == TransferStatus.scheduled.name)
            FilledButton(
                onPressed: () => _confirmMove(r),
                child: const Text('Confirm move-in & complete transfer')),
          const Divider(),
          for (final event in (r['events'] as List).cast<Map>())
            Text('• ${event['text']} (${_date(event['at'])})', style: _muted),
        ])),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Widget _outgoing(DemoProperty p) {
    final items =
        store.requests.where((r) => r['fromPropertyId'] == p.id).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Outgoing students', style: _heading),
      const SizedBox(height: 10),
      if (items.isEmpty) _card(const Text('No outgoing moves yet.')),
      for (final r in items) ...[
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r['studentName'] as String,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
              'Current room: ${store.currentRoom.isEmpty ? 'Not assigned' : store.currentRoom}'),
          Text('Expected move-out: ${_date(r['moveOut'])}'),
          Text(
              'Destination: ${propertyById(r['toPropertyId'] as String?)?.name ?? 'Unknown'}'),
          Text(_label(r), style: const TextStyle(color: _teal)),
          Text(
              'Departure acknowledged: ${r['outgoingAcknowledged'] == true ? 'Yes' : 'Not yet'}'),
          Text(
              'Room handover: ${r['handoverConfirmed'] == true ? 'Confirmed' : 'Pending'}'),
          Text('Actual move-out: ${_date(r['actualMoveOut'])}', style: _muted),
          if ((r['outgoingIssue'] as String? ?? '').isNotEmpty)
            Text('Issue: ${r['outgoingIssue']}'),
          Wrap(spacing: 7, runSpacing: 7, children: [
            if (r['outgoingAcknowledged'] != true)
              OutlinedButton(
                  onPressed: () => _run(() => store.outgoingUpdate(
                      r['id'] as String, p.id, 'acknowledge')),
                  child: const Text('Acknowledge')),
            if (r['handoverConfirmed'] != true)
              OutlinedButton(
                  onPressed: () => _run(() => store.outgoingUpdate(
                      r['id'] as String, p.id, 'handover')),
                  child: const Text('Confirm handover')),
            TextButton(
                onPressed: () => _reportIssue(r),
                child: const Text('Report issue')),
          ]),
          const Text(
              'Demo records only. Actual room release needs verified property inventory.',
              style: _muted),
        ])),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Widget _viewings(DemoProperty p) {
    final items = store.viewings.where((v) => v['propertyId'] == p.id).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Viewing requests', style: _heading),
      const SizedBox(height: 10),
      if (items.isEmpty) _card(const Text('No viewing requests yet.')),
      for (final v in items) ...[
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(store.viewingStatus(p.id).label),
          Text('Requested: ${_date(v['requestedAt'])}', style: _muted),
          if (store.viewingStatus(p.id) == ViewingStatus.requested)
            Wrap(spacing: 8, children: [
              FilledButton(
                  onPressed: () => _scheduleViewing(p),
                  child: const Text('Schedule')),
              TextButton(
                  onPressed: () => _run(
                      () => store.updateViewing(p.id, ViewingStatus.cancelled)),
                  child: const Text('Cancel')),
            ]),
          if (store.viewingStatus(p.id) == ViewingStatus.awaitingConfirmation)
            FilledButton(
                onPressed: () =>
                    _run(() => store.updateViewing(p.id, ViewingStatus.viewed)),
                child: const Text('Confirm physical visit')),
        ])),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Widget _notices(DemoProperty p) {
    final items = store.notices.where((n) => n['propertyId'] == p.id).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Private notice board', style: _heading),
      const SizedBox(height: 7),
      FilledButton.icon(
          onPressed: () => _postNotice(p),
          icon: const Icon(Icons.add),
          label: const Text('Publish notice')),
      const SizedBox(height: 12),
      if (items.isEmpty) _card(const Text('No notices yet.')),
      for (final n in items) ...[
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n['category'] as String,
              style:
                  const TextStyle(color: _teal, fontWeight: FontWeight.w800)),
          Text(n['text'] as String),
          Text(_date(n['at']), style: _muted),
        ])),
        const SizedBox(height: 8),
      ],
    ]);
  }

  Widget _messages(DemoProperty p) {
    final requests = store.requests
        .where((r) => r['toPropertyId'] == p.id || r['fromPropertyId'] == p.id)
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Transfer messages', style: _heading),
      const Text('Demo: staff-only notes are hidden from the student view.',
          style: _muted),
      const SizedBox(height: 10),
      if (requests.isEmpty) _card(const Text('No transfer threads yet.')),
      for (final r in requests) ...[
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${r['studentName']} • ${_label(r)}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          for (final m
              in store.messages.where((m) => m['requestId'] == r['id']))
            Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                    '${propertyById(m['sender'] as String?)?.name ?? 'Staff'}: ${m['text']} ${m['studentVisible'] == true ? '(student can see)' : '(staff only)'}',
                    style: _muted)),
          const SizedBox(height: 8),
          OutlinedButton(
              onPressed: () => _compose(r),
              child: const Text('Write transfer update')),
        ])),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Future<void> _reportIssue(Map<String, dynamic> request) async {
    String detail = '';
    final send = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Report handover issue'),
              content: TextField(
                  maxLines: 3,
                  onChanged: (value) => detail = value,
                  decoration: const InputDecoration(
                      labelText: 'What needs attention?',
                      border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Record issue')),
              ],
            ));
    if (send == true) {
      _run(() => store.outgoingUpdate(
          request['id'] as String, propertyId, 'issue',
          detail: detail));
    }
  }

  Future<void> _decisionDialog(
      Map<String, dynamic> r, TransferStatus decision) async {
    String detail = '';
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: Text(decision == TransferStatus.rejected
                    ? 'Reject request'
                    : 'Request information'),
                content: TextField(
                    onChanged: (v) => detail = v,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Reason or question',
                        border: OutlineInputBorder())),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Send'))
                ]));
    if (confirmed == true) {
      _run(() => store.managerDecision(r['id'] as String, propertyId, decision,
          detail: detail));
    }
  }

  Future<void> _schedule(Map<String, dynamic> r) async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.tryParse(r['moveIn'] as String) ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));
    if (date == null || !mounted) return;
    String room = '';
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: const Text('Assign a room'),
                content: TextField(
                    onChanged: (v) => room = v,
                    decoration: const InputDecoration(
                        labelText: 'Room number (optional)')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Schedule'))
                ]));
    if (confirmed == true) {
      _run(() => store.scheduleMove(
          r['id'] as String, propertyId, date.toIso8601String(), room));
    }
  }

  Future<void> _confirmMove(Map<String, dynamic> r) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: const Text('Confirm actual move-in?'),
                content: const Text(
                    'This changes the demo student’s current accommodation and private notice board. Approval alone does not do this.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Not yet')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Complete transfer'))
                ]));
    if (confirmed == true) {
      _run(() => store.completeMove(r['id'] as String, propertyId));
    }
  }

  Future<void> _scheduleViewing(DemoProperty p) async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (date != null) {
      _run(() => store.updateViewing(p.id, ViewingStatus.scheduled,
          scheduledAt: date.toIso8601String()));
    }
  }

  Future<void> _postNotice(DemoProperty p) async {
    String category = 'Announcement', text = '';
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => StatefulBuilder(
            builder: (dialog, refresh) => AlertDialog(
                    title: const Text('Publish notice'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButton<String>(
                          isExpanded: true,
                          value: category,
                          items: [
                            for (final c in const [
                              'Announcement',
                              'Maintenance',
                              'Safety',
                              'Event',
                              'Deadline',
                              'Move-in',
                              'Move-out',
                              'House rules',
                              'Emergency'
                            ])
                              DropdownMenuItem(value: c, child: Text(c))
                          ],
                          onChanged: (v) => refresh(() => category = v!)),
                      TextField(
                          maxLines: 3,
                          onChanged: (v) => text = v,
                          decoration:
                              const InputDecoration(labelText: 'Message')),
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: const Text('Publish'))
                    ])));
    if (confirmed == true) _run(() => store.addNotice(p.id, category, text));
  }

  Future<void> _compose(Map<String, dynamic> r) async {
    String text = '';
    bool studentVisible = false;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => StatefulBuilder(
            builder: (dialog, refresh) => AlertDialog(
                    title: const Text('Transfer update'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          maxLines: 3,
                          onChanged: (v) => text = v,
                          decoration:
                              const InputDecoration(labelText: 'Message')),
                      CheckboxListTile(
                          value: studentVisible,
                          title: const Text('Show to student'),
                          onChanged: (v) =>
                              refresh(() => studentVisible = v ?? false)),
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: const Text('Send'))
                    ])));
    if (confirmed == true) {
      _run(() => store.addMessage(r['id'] as String, propertyId, text,
          studentVisible: studentVisible));
    }
  }

  void _updates() {
    final updates =
        store.notifications.where((n) => n['audience'] == 'admin:$propertyId');
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) =>
            ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Manager updates', style: _heading),
              for (final item in updates)
                ListTile(
                  leading:
                      const Icon(Icons.notifications_outlined, color: _teal),
                  title: Text(item['text'] as String),
                  subtitle: Text(_date(item['at'])),
                  onTap: () {
                    Navigator.pop(sheet);
                    setState(() => tab =
                        (item['text'] as String).contains('viewing')
                            ? 'Viewings'
                            : 'Incoming');
                  },
                ),
            ]));
  }
}

String _label(Map<String, dynamic> request) =>
    TransferStatus.values.byName(request['status'] as String).label;

String _date(Object? raw) {
  final date = DateTime.tryParse(raw?.toString() ?? '');
  return date == null ? 'Not set' : '${date.day}/${date.month}/${date.year}';
}

const _heading =
    TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _ink);
const _muted = TextStyle(fontSize: 12, color: Colors.black54, height: 1.4);
Widget _card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECEA))),
    child: child);
