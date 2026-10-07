import 'package:flutter_test/flutter_test.dart';
import 'package:gude_app/features/accommodation/data/accommodation_portal_store.dart';

void main() {
  final store = AccommodationPortalStore.instance;

  test('bed totals and residence availability reconcile', () {
    expect(store.totalBedCount, greaterThan(0));
    expect(
      store.occupiedBedCount + store.availableBedCount,
      store.totalBedCount,
    );
    expect(store.residentCount, store.occupiedBedCount);
    expect(
      store.availableBedsByResidence.values.fold<int>(
        0,
        (total, value) => total + value,
      ),
      store.availableBedCount,
    );
  });

  test('occupied beds contain complete placement and funding information', () {
    expect(store.occupiedBeds, isNotEmpty);
    for (final bed in store.occupiedBeds.take(100)) {
      expect(bed.student, isNotNull);
      expect(bed.student!.name, isNotEmpty);
      expect(bed.student!.studentNumber, isNotEmpty);
      expect(bed.student!.institution, isNotEmpty);
      expect(
        AccommodationFundingType.values,
        contains(bed.student!.fundingType),
      );
      expect(bed.residence, isNotEmpty);
      expect(bed.city, isNotEmpty);
      expect(bed.bedNumber, isNotEmpty);
    }

    final fundingTotal = store.fundingBreakdown.values.fold<int>(
      0,
      (total, value) => total + value,
    );
    expect(fundingTotal, store.occupiedBedCount);
    for (final type in AccommodationFundingType.values) {
      expect(store.fundingBreakdown[type], greaterThan(0));
    }
  });

  test('an available bed can be assigned and vacated', () {
    final bed = store.availableBeds.first;
    final occupiedBefore = store.occupiedBedCount;

    store.assignStudentToBed(
      bedId: bed.id,
      name: 'Accommodation Test Student',
      studentNumber: 'ACC-TEST-001',
      institution: 'Test Institution',
      fundingType: AccommodationFundingType.bursary,
    );

    expect(store.occupiedBedCount, occupiedBefore + 1);
    expect(
      store.beds.firstWhere((item) => item.id == bed.id).student?.name,
      'Accommodation Test Student',
    );

    store.vacateBed(bed.id);
    expect(store.occupiedBedCount, occupiedBefore);
    expect(
      store.beds.firstWhere((item) => item.id == bed.id).student,
      isNull,
    );
  });

  test('complaints can be resolved and reopened', () {
    final request = store.requests.first;
    store.resolveRequest(request.id);
    expect(
      store.requests.firstWhere((item) => item.id == request.id).resolved,
      isTrue,
    );

    store.reopenRequest(request.id);
    expect(
      store.requests.firstWhere((item) => item.id == request.id).resolved,
      isFalse,
    );
  });
}
