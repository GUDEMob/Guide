import 'package:flutter_test/flutter_test.dart';

import 'package:gude_app/app.dart';

void main() {
  testWidgets('Gude app starts on the splash screen', (tester) async {
    await tester.pumpWidget(const GudeApp());

    expect(find.text('GUDE'), findsOneWidget);
    expect(find.text('Student life, unlocked.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
  });
}
