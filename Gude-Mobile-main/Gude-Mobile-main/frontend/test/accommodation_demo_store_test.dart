import 'package:flutter_test/flutter_test.dart';
import 'package:gude_app/features/accommodation/data/accommodation_demo_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = DemoAccommodationStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.resetForTest();
  });

  test('profile visit is not a physical viewing', () async {
    await store.recordProfileVisit();
    expect(store.profileVisits, 1);
    expect(store.viewingStatus('studio'), ViewingStatus.notViewed);
    await store.requestViewing('studio');
    expect(store.viewingStatus('studio'), ViewingStatus.requested);
    await store.updateViewing('studio', ViewingStatus.scheduled,
        scheduledAt: DateTime.now().toIso8601String());
    await store.updateViewing('studio', ViewingStatus.awaitingConfirmation);
    expect(store.viewingStatus('studio'), isNot(ViewingStatus.viewed));
    await store.updateViewing('studio', ViewingStatus.viewed);
    expect(store.viewingStatus('studio'), ViewingStatus.viewed);
  });

  test('first accommodation approval does not activate membership', () async {
    final id = await store.submitRequest(
      studentName: 'Test Student',
      studentId: 'S001',
      toPropertyId: 'studio',
      moveOut: '2026-10-13',
      moveIn: '2026-10-14',
    );
    await store.managerDecision(id, 'studio', TransferStatus.approved);
    expect(store.activePropertyId, isNull);
    expect(store.requests.first['status'], TransferStatus.approved.name);
    await store.scheduleMove(id, 'studio', '2026-01-01', 'A1');
    expect(store.activePropertyId, isNull);
    await store.completeMove(id, 'studio');
    expect(store.activePropertyId, 'studio');
    expect(store.currentRoom, 'A1');
    await store.completeMove(id, 'studio');
    expect(store.history, isEmpty);
  });

  test('transfer preserves history and changes private board membership',
      () async {
    final first = await store.submitRequest(
      studentName: 'Test Student',
      studentId: 'S001',
      toPropertyId: 'studio',
      moveOut: '2026-01-01',
      moveIn: '2026-01-02',
    );
    await store.managerDecision(first, 'studio', TransferStatus.approved);
    await store.scheduleMove(first, 'studio', '2026-01-02', 'A1');
    await store.completeMove(first, 'studio');
    await expectLater(
        store.submitRequest(
          studentName: 'Test Student',
          studentId: 'S001',
          toPropertyId: 'studio',
          moveOut: '2026-01-04',
          moveIn: '2026-01-05',
        ),
        throwsStateError);
    final second = await store.submitRequest(
      studentName: 'Test Student',
      studentId: 'S001',
      toPropertyId: 'share',
      moveOut: '2026-01-04',
      moveIn: '2026-01-05',
    );
    await store.managerDecision(second, 'share', TransferStatus.approved);
    expect(store.activePropertyId, 'studio');
    expect(
        store.notifications.any((n) =>
            n['audience'] == 'admin:studio' &&
            (n['text'] as String).contains('upcoming resident transfer')),
        isTrue);
    await store.scheduleMove(second, 'share', '2026-01-05', 'B2');
    await store.completeMove(second, 'share');
    expect(store.activePropertyId, 'share');
    expect(store.history.single['name'], 'The Study Studio');
  });

  test('duplicate, self-transfer, unauthorised manager and cancellation',
      () async {
    final id = await store.submitRequest(
      studentName: 'Test Student',
      studentId: 'S001',
      toPropertyId: 'studio',
      moveOut: '2026-01-01',
      moveIn: '2026-01-02',
    );
    await expectLater(
        store.submitRequest(
          studentName: 'Test Student',
          studentId: 'S001',
          toPropertyId: 'studio',
          moveOut: '2026-01-01',
          moveIn: '2026-01-02',
        ),
        throwsStateError);
    await expectLater(
        store.managerDecision(id, 'share', TransferStatus.approved),
        throwsStateError);
    await store.cancelRequest(id);
    expect(store.requests.first['status'], TransferStatus.cancelled.name);
  });

  test('rejection retains no membership and records reason', () async {
    final id = await store.submitRequest(
      studentName: 'Test Student',
      studentId: 'S001',
      toPropertyId: 'room',
      moveOut: '2026-01-01',
      moveIn: '2026-01-02',
    );
    await store.managerDecision(id, 'room', TransferStatus.rejected,
        detail: 'No suitable room');
    expect(store.activePropertyId, isNull);
    expect(store.requests.first['rejectionReason'], 'No suitable room');
  });

  test('future move cannot complete; current membership stays active',
      () async {
    final id = await store.submitRequest(
      studentName: 'Test Student',
      studentId: 'S001',
      toPropertyId: 'studio',
      moveOut: '2099-01-01',
      moveIn: '2099-01-02',
    );
    await store.managerDecision(id, 'studio', TransferStatus.approved);
    await store.scheduleMove(id, 'studio', '2099-01-02', 'A1');
    await expectLater(store.completeMove(id, 'studio'), throwsStateError);
    expect(store.activePropertyId, isNull);
  });
}
