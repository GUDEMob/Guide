import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Frontend-only demonstration. This is not an authentication or authorisation
/// boundary; a backend is required before using real resident information.
class DemoProperty {
  final String id, name, area, type, description, contact;
  final int rent, capacity;
  final List<String> facilities;
  const DemoProperty(this.id, this.name, this.area, this.type, this.description,
      this.contact, this.rent, this.capacity, this.facilities);
}

const demoProperties = <DemoProperty>[
  DemoProperty(
      'studio',
      'The Study Studio',
      'Campus area',
      'Studio',
      'A private space to study and rest.',
      'Contact details not connected',
      4200,
      3,
      ['Wi-Fi', 'Furnished', 'Study space']),
  DemoProperty(
      'share',
      'Campus House Share',
      'Student neighbourhood',
      'Shared',
      'A social shared home with room for your own routine.',
      'Contact details not connected',
      3100,
      4,
      ['Wi-Fi', 'Shared kitchen', 'Laundry']),
  DemoProperty(
      'room',
      'Quiet Corner Room',
      'Campus area',
      'Private room',
      'A calm room for focused study and a comfortable night.',
      'Contact details not connected',
      3600,
      2,
      ['Furnished', 'Study space', 'Secure entry']),
];

DemoProperty? propertyById(String? id) {
  for (final property in demoProperties) {
    if (property.id == id) return property;
  }
  return null;
}

enum ViewingStatus {
  notViewed,
  requested,
  scheduled,
  awaitingConfirmation,
  viewed,
  cancelled,
}

extension ViewingLabel on ViewingStatus {
  String get label => switch (this) {
        ViewingStatus.notViewed => 'Not Viewed',
        ViewingStatus.requested => 'Viewing Requested',
        ViewingStatus.scheduled => 'Viewing Scheduled',
        ViewingStatus.awaitingConfirmation => 'Confirming visit',
        ViewingStatus.viewed => 'Viewed',
        ViewingStatus.cancelled => 'Viewing Cancelled',
      };
}

enum TransferStatus {
  pending,
  moreInfo,
  rejected,
  approved,
  scheduled,
  completed,
  cancelled,
}

extension TransferLabel on TransferStatus {
  String get label => switch (this) {
        TransferStatus.pending => 'Pending Approval',
        TransferStatus.moreInfo => 'More Information Required',
        TransferStatus.rejected => 'Rejected',
        TransferStatus.approved => 'Approved',
        TransferStatus.scheduled => 'Move-In Scheduled',
        TransferStatus.completed => 'Transfer Completed',
        TransferStatus.cancelled => 'Cancelled',
      };

  bool get active =>
      this == TransferStatus.pending ||
      this == TransferStatus.moreInfo ||
      this == TransferStatus.approved ||
      this == TransferStatus.scheduled;
}

class DemoAccommodationStore extends ChangeNotifier {
  DemoAccommodationStore._();
  static final instance = DemoAccommodationStore._();
  static const _key = 'gude_accommodation_demo_v2';

  Map<String, dynamic> _state = {};
  bool loaded = false;

  String? get activePropertyId => _state['activePropertyId'] as String?;
  String get currentName => (_state['currentName'] as String?) ?? '';
  String get currentArea => (_state['currentArea'] as String?) ?? '';
  String get currentRoom => (_state['currentRoom'] as String?) ?? '';
  String get currentContact => (_state['currentContact'] as String?) ?? '';
  String? get moveInDate => _state['moveInDate'] as String?;
  int get profileVisits => (_state['profileVisits'] as int?) ?? 0;

  List<Map<String, dynamic>> get requests => _list('requests');
  List<Map<String, dynamic>> get viewings => _list('viewings');
  List<Map<String, dynamic>> get history => _list('history');
  List<Map<String, dynamic>> get notices => _list('notices');
  List<Map<String, dynamic>> get messages => _list('messages');
  List<Map<String, dynamic>> get notifications => _list('notifications');

  List<Map<String, dynamic>> _list(String key) =>
      ((_state[key] as List?) ?? const [])
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList();

  Future<void> load() async {
    if (loaded) return;
    final prefs = await SharedPreferences.getInstance();
    try {
      _state = Map<String, dynamic>.from(
          jsonDecode(prefs.getString(_key) ?? '{}') as Map);
    } catch (_) {
      _state = {};
    }
    _state.putIfAbsent('requests', () => <Map<String, dynamic>>[]);
    _state.putIfAbsent('viewings', () => <Map<String, dynamic>>[]);
    _state.putIfAbsent('history', () => <Map<String, dynamic>>[]);
    _state.putIfAbsent('notices', () => <Map<String, dynamic>>[]);
    _state.putIfAbsent('messages', () => <Map<String, dynamic>>[]);
    _state.putIfAbsent('notifications', () => <Map<String, dynamic>>[]);
    if (!_state.containsKey('currentName')) {
      _state['currentName'] =
          prefs.getString('accommodation_current_name_v1') ?? '';
      _state['currentArea'] =
          prefs.getString('accommodation_current_area_v1') ?? '';
      final name = _state['currentName'] as String;
      for (final property in demoProperties) {
        if (property.name == name) _state['activePropertyId'] = property.id;
      }
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _commit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_state));
    notifyListeners();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  String _now() => DateTime.now().toIso8601String();
  void _add(String key, Map<String, dynamic> value) =>
      (_state[key] as List).insert(0, value);

  void _event(Map<String, dynamic> request, String text, String actor) {
    (request['events'] as List)
        .add({'text': text, 'actor': actor, 'at': _now()});
  }

  void _notify(String audience, String text, String requestId) {
    final id = '$audience:$requestId:$text';
    if (notifications.any((n) => n['id'] == id)) return;
    _add('notifications', {
      'id': id,
      'audience': audience,
      'text': text,
      'requestId': requestId,
      'at': _now(),
    });
  }

  ViewingStatus viewingStatus(String propertyId) {
    for (final viewing in viewings) {
      if (viewing['propertyId'] == propertyId) {
        return ViewingStatus.values.byName(viewing['status'] as String);
      }
    }
    return ViewingStatus.notViewed;
  }

  Map<String, dynamic>? viewingFor(String propertyId) {
    for (final viewing in viewings) {
      if (viewing['propertyId'] == propertyId) return viewing;
    }
    return null;
  }

  Future<void> recordProfileVisit() async {
    _state['profileVisits'] = profileVisits + 1;
    await _commit();
  }

  Future<void> requestViewing(String propertyId) async {
    if (propertyById(propertyId) == null) throw StateError('Unknown property.');
    final status = viewingStatus(propertyId);
    if (status != ViewingStatus.notViewed &&
        status != ViewingStatus.cancelled) {
      throw StateError('A viewing is already in progress.');
    }
    final item = {
      'id': _id(),
      'propertyId': propertyId,
      'status': ViewingStatus.requested.name,
      'requestedAt': _now(),
      'scheduledAt': null,
    };
    (_state['viewings'] as List)
        .removeWhere((v) => (v as Map)['propertyId'] == propertyId);
    _add('viewings', item);
    _notify('student', 'Your viewing request was received.', item['id']!);
    _notify('admin:$propertyId', 'New viewing request.', item['id']!);
    await _commit();
  }

  Future<void> updateViewing(String propertyId, ViewingStatus next,
      {String? scheduledAt}) async {
    final item = viewingFor(propertyId);
    if (item == null) throw StateError('No viewing request found.');
    final current = viewingStatus(propertyId);
    final valid = switch (current) {
      ViewingStatus.requested =>
        next == ViewingStatus.scheduled || next == ViewingStatus.cancelled,
      ViewingStatus.scheduled => next == ViewingStatus.awaitingConfirmation ||
          next == ViewingStatus.cancelled,
      ViewingStatus.awaitingConfirmation =>
        next == ViewingStatus.viewed || next == ViewingStatus.cancelled,
      _ => false,
    };
    if (!valid) throw StateError('This viewing change is not available.');
    (_state['viewings'] as List).firstWhere(
        (v) => (v as Map)['propertyId'] == propertyId)['status'] = next.name;
    if (scheduledAt != null) {
      (_state['viewings'] as List).firstWhere(
              (v) => (v as Map)['propertyId'] == propertyId)['scheduledAt'] =
          scheduledAt;
    }
    _notify('student', 'Viewing ${next.label.toLowerCase()}.',
        item['id'] as String);
    await _commit();
  }

  int availableRooms(String propertyId) {
    final property = propertyById(propertyId);
    if (property == null) return 0;
    final active = activePropertyId == propertyId ? 1 : 0;
    return (property.capacity - active).clamp(0, property.capacity);
  }

  Future<String> submitRequest({
    required String studentName,
    required String studentId,
    required String toPropertyId,
    required String moveIn,
    required String moveOut,
    String reason = '',
    String comments = '',
  }) async {
    if (propertyById(toPropertyId) == null) {
      throw StateError('Select a property.');
    }
    if (activePropertyId == toPropertyId ||
        currentName == propertyById(toPropertyId)!.name) {
      throw StateError('You already live at this accommodation.');
    }
    if (studentName.trim().isEmpty || studentId.trim().isEmpty) {
      throw StateError('Your student name and ID are required.');
    }
    final inDate = DateTime.tryParse(moveIn);
    final outDate = DateTime.tryParse(moveOut);
    if (inDate == null || outDate == null || outDate.isAfter(inDate)) {
      throw StateError(
          'Choose valid dates; move-out must be on or before move-in.');
    }
    if (availableRooms(toPropertyId) <= 0) {
      throw StateError('There are no demo rooms available.');
    }
    if (requests.any((r) =>
        r['toPropertyId'] == toPropertyId &&
        TransferStatus.values.byName(r['status'] as String).active)) {
      throw StateError('You already have an active request for this place.');
    }
    if (requests.any((r) =>
        TransferStatus.values.byName(r['status'] as String) ==
        TransferStatus.scheduled)) {
      throw StateError('Complete or cancel your scheduled move first.');
    }
    final id = _id();
    final request = <String, dynamic>{
      'id': id,
      'studentName': studentName.trim(),
      'studentId': studentId.trim(),
      'fromName': currentName,
      'fromPropertyId': activePropertyId,
      'toPropertyId': toPropertyId,
      'moveIn': moveIn,
      'moveOut': moveOut,
      'reason': reason.trim(),
      'comments': comments.trim(),
      'status': TransferStatus.pending.name,
      'createdAt': _now(),
      'room': '',
      'rejectionReason': '',
      'infoRequest': '',
      'outgoingAcknowledged': false,
      'handoverConfirmed': false,
      'actualMoveOut': null,
      'outgoingIssue': '',
      'events': <Map<String, dynamic>>[],
    };
    _event(request, 'Request submitted', 'Student');
    _add('requests', request);
    _notify('student', 'Transfer request submitted.', id);
    _notify('admin:$toPropertyId', 'New transfer request.', id);
    await _commit();
    return id;
  }

  Map<String, dynamic> _request(String id) {
    for (final request in _state['requests'] as List) {
      if ((request as Map)['id'] == id) return request as Map<String, dynamic>;
    }
    throw StateError('Request not found.');
  }

  Future<void> cancelRequest(String id) async {
    final request = _request(id);
    if (request['status'] != TransferStatus.pending.name &&
        request['status'] != TransferStatus.moreInfo.name) {
      throw StateError('Only a pending request can be cancelled.');
    }
    request['status'] = TransferStatus.cancelled.name;
    _event(request, 'Request cancelled', 'Student');
    _notify(
        'admin:${request['toPropertyId']}', 'Transfer request cancelled.', id);
    await _commit();
  }

  Future<void> studentReply(String id, String reply) async {
    final request = _request(id);
    if (request['status'] != TransferStatus.moreInfo.name ||
        reply.trim().isEmpty) {
      throw StateError('Add a reply to the information request.');
    }
    request['comments'] =
        '${request['comments']}\nStudent update: ${reply.trim()}';
    request['status'] = TransferStatus.pending.name;
    _event(request, 'Additional information sent', 'Student');
    _notify('admin:${request['toPropertyId']}',
        'Student sent additional information.', id);
    await _commit();
  }

  Future<void> outgoingUpdate(String id, String propertyId, String action,
      {String detail = ''}) async {
    final request = _request(id);
    if (request['fromPropertyId'] != propertyId) {
      throw StateError('This student is not leaving your property.');
    }
    if (action == 'acknowledge') {
      request['outgoingAcknowledged'] = true;
    } else if (action == 'handover') {
      request['handoverConfirmed'] = true;
      request['actualMoveOut'] = _now();
    } else if (action == 'issue' && detail.trim().isNotEmpty) {
      request['outgoingIssue'] = detail.trim();
    } else {
      throw StateError('Choose a valid outgoing update.');
    }
    _event(request, 'Outgoing $action${detail.isEmpty ? '' : ': $detail'}',
        'Previous accommodation');
    _notify('admin:${request['toPropertyId']}',
        'Outgoing accommodation recorded $action.', id);
    await _commit();
  }

  Future<void> managerDecision(
      String id, String propertyId, TransferStatus decision,
      {String detail = ''}) async {
    final request = _request(id);
    if (request['toPropertyId'] != propertyId) {
      throw StateError('This request belongs to another property.');
    }
    if (request['status'] != TransferStatus.pending.name &&
        request['status'] != TransferStatus.moreInfo.name) {
      throw StateError('This request has already been reviewed.');
    }
    if (![
      TransferStatus.approved,
      TransferStatus.rejected,
      TransferStatus.moreInfo
    ].contains(decision)) {
      throw StateError('Invalid decision.');
    }
    if (decision != TransferStatus.approved && detail.trim().isEmpty) {
      throw StateError('Please add a reason or question.');
    }
    if (decision == TransferStatus.approved) {
      if (availableRooms(propertyId) <= 0) {
        throw StateError('No rooms are available.');
      }
      if (requests.any((r) =>
          r['id'] != id &&
          (r['status'] == TransferStatus.approved.name ||
              r['status'] == TransferStatus.scheduled.name))) {
        throw StateError('Another move is already approved for this student.');
      }
    }
    request['status'] = decision.name;
    if (decision == TransferStatus.rejected) {
      request['rejectionReason'] = detail.trim();
    }
    if (decision == TransferStatus.moreInfo) {
      request['infoRequest'] = detail.trim();
    }
    _event(request, '${decision.label}${detail.isEmpty ? '' : ': $detail'}',
        'Receiving accommodation');
    _notify('student', 'Transfer ${decision.label.toLowerCase()}.', id);
    if (decision == TransferStatus.approved) {
      _notify(
          'admin:$propertyId',
          'The transfer request has been approved. The student is scheduled to join your accommodation.',
          id);
      final from = request['fromPropertyId'] as String?;
      if (from != null) {
        _notify(
            'admin:$from',
            'An upcoming resident transfer has been confirmed. Please review the scheduled departure and prepare for room handover.',
            id);
      }
    }
    await _commit();
  }

  Future<void> scheduleMove(
      String id, String propertyId, String effectiveDate, String room) async {
    final request = _request(id);
    if (request['toPropertyId'] != propertyId ||
        request['status'] != TransferStatus.approved.name) {
      throw StateError('Approve this property’s request first.');
    }
    if (DateTime.tryParse(effectiveDate) == null) {
      throw StateError('Select a valid date.');
    }
    if (availableRooms(propertyId) <= 0) {
      throw StateError('No rooms are available.');
    }
    request['effectiveDate'] = effectiveDate;
    request['room'] = room.trim();
    request['status'] = TransferStatus.scheduled.name;
    _event(request, 'Move-in scheduled for $effectiveDate',
        'Receiving accommodation');
    _notify('student', 'Your move-in was scheduled.', id);
    await _commit();
  }

  Future<void> completeMove(String id, String propertyId) async {
    final request = _request(id);
    if (request['status'] == TransferStatus.completed.name) return;
    if (request['toPropertyId'] != propertyId ||
        request['status'] != TransferStatus.scheduled.name) {
      throw StateError('Schedule this property’s move-in first.');
    }
    final effective =
        DateTime.tryParse(request['effectiveDate'] as String? ?? '');
    if (effective == null || DateTime.now().isBefore(effective)) {
      throw StateError('The effective date has not arrived yet.');
    }
    if (activePropertyId != request['fromPropertyId'] ||
        currentName != request['fromName']) {
      throw StateError('Current accommodation changed. Review the request.');
    }
    if (availableRooms(propertyId) <= 0) {
      throw StateError('No rooms are available.');
    }
    final destination = propertyById(propertyId)!;
    if (currentName.isNotEmpty) {
      _add('history', {
        'name': currentName,
        'area': currentArea,
        'moveIn': moveInDate,
        'moveOut': _now(),
        'requestId': id,
      });
    }
    // A single local snapshot holds membership, history, request and notices.
    // This illustrates atomic intent but is not a database transaction.
    _state['activePropertyId'] = propertyId;
    _state['currentName'] = destination.name;
    _state['currentArea'] = destination.area;
    _state['currentRoom'] = request['room'];
    _state['currentContact'] = destination.contact;
    _state['moveInDate'] = _now();
    request['status'] = TransferStatus.completed.name;
    _event(request, 'Move-in confirmed and transfer completed',
        'Receiving accommodation');
    _notify('student', 'Welcome to your new accommodation!', id);
    _notify('admin:$propertyId', 'Transfer completed.', id);
    final from = request['fromPropertyId'] as String?;
    if (from != null) _notify('admin:$from', 'Transfer completed.', id);
    await _commit();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accommodation_current_name_v1', destination.name);
    await prefs.setString('accommodation_current_area_v1', destination.area);
    await prefs.setString(
        'accommodation_current_rent_v1', destination.rent.toString());
  }

  Future<void> addNotice(
      String propertyId, String category, String text) async {
    if (propertyById(propertyId) == null || text.trim().isEmpty) {
      throw StateError('Choose a property and write a notice.');
    }
    final id = _id();
    _add('notices', {
      'id': id,
      'propertyId': propertyId,
      'category': category,
      'text': text.trim(),
      'at': _now()
    });
    if (activePropertyId == propertyId) {
      _notify('student', 'New $category notice from your accommodation.', id);
    }
    await _commit();
  }

  Future<void> addMessage(String requestId, String propertyId, String text,
      {bool studentVisible = false}) async {
    final request = _request(requestId);
    if (propertyId != request['toPropertyId'] &&
        propertyId != request['fromPropertyId']) {
      throw StateError('This property is not part of the transfer.');
    }
    if (text.trim().isEmpty) throw StateError('Write a message first.');
    final id = _id();
    _add('messages', {
      'id': id,
      'requestId': requestId,
      'sender': propertyId,
      'text': text.trim(),
      'studentVisible': studentVisible,
      'at': _now()
    });
    if (studentVisible) _notify('student', 'New transfer update.', id);
    final other = propertyId == request['toPropertyId']
        ? request['fromPropertyId']
        : request['toPropertyId'];
    if (other != null) _notify('admin:$other', 'New transfer message.', id);
    await _commit();
  }

  @visibleForTesting
  Future<void> resetForTest() async {
    _state = {};
    loaded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await load();
  }
}
