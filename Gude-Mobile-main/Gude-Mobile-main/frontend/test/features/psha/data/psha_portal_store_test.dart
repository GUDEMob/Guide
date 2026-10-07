import 'package:flutter_test/flutter_test.dart';
import 'package:gude_app/features/psha/data/psha_portal_store.dart';

void main() {
  final store = PshaPortalStore.instance;

  test('bed totals reconcile with occupied and available records', () {
    expect(store.totalBedCount, greaterThan(0));
    expect(
      store.occupiedBedCount + store.availableBedCount,
      store.totalBedCount,
    );
    expect(store.studentCount, store.occupiedBedCount);
    expect(
      store.availableBedsByLocation.values.fold<int>(
        0,
        (total, value) => total + value,
      ),
      store.availableBedCount,
    );
  });

  test('occupied beds include student, institution and funding information',
      () {
    expect(store.occupiedBeds, isNotEmpty);
    for (final record in store.occupiedBeds.take(100)) {
      expect(record.student, isNotNull);
      expect(record.student!.name, isNotEmpty);
      expect(record.student!.studentNumber, isNotEmpty);
      expect(record.student!.institution, isNotEmpty);
      expect(PshaFundingType.values, contains(record.student!.fundingType));
      expect(record.buildingName, isNotEmpty);
      expect(record.city, isNotEmpty);
    }

    final fundingTotal = store.fundingBreakdown.values.fold<int>(
      0,
      (total, value) => total + value,
    );
    expect(fundingTotal, store.occupiedBedCount);
    for (final type in PshaFundingType.values) {
      expect(store.fundingBreakdown[type], greaterThan(0));
    }
  });

  test('a student can be assigned to and removed from an available bed', () {
    final record = store.availableBeds.first;
    final occupiedBefore = store.occupiedBedCount;

    store.assignStudentToBed(
      bedId: record.id,
      name: 'Test Student',
      studentNumber: 'TEST-001',
      institution: 'Test University',
      fundingType: PshaFundingType.bursary,
    );

    expect(store.occupiedBedCount, occupiedBefore + 1);
    expect(
      store.bedRecords.firstWhere((item) => item.id == record.id).student?.name,
      'Test Student',
    );

    store.vacateBed(record.id);
    expect(store.occupiedBedCount, occupiedBefore);
    expect(
      store.bedRecords.firstWhere((item) => item.id == record.id).student,
      isNull,
    );
  });
}
