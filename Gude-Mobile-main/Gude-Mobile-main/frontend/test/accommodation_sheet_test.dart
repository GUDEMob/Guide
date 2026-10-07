import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gude_app/features/accommodation/presentation/accommodation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('current home sheet closes safely without saving',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: AccommodationPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add current home'));
    await tester.pumpAndSettle();
    expect(find.text('My accommodation profile'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('My accommodation profile'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
