import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gude_app/features/accommodation/data/accommodation_demo_store.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_portal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const [Size(360, 640), Size(1024, 768)]) {
    testWidgets('student portal renders at ${size.width} px', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await DemoAccommodationStore.instance.resetForTest();
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: AccommodationPortalPage()));
      await tester.pumpAndSettle();
      expect(find.text('Find a place that fits'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
