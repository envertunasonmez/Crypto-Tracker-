import 'package:flutter_test/flutter_test.dart';

import 'package:trade_app/main.dart';

void main() {
  testWidgets('App loads and shows market list screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CryptoTrackerApp());

    expect(find.text('Cryto Markets'), findsOneWidget);
  });
}
