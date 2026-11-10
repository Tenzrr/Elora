import 'package:flutter_test/flutter_test.dart';
import 'package:elora_mobile/main.dart';

void main() {
  testWidgets('EloraApp initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EloraApp());

    // Verify app launches and displays top bar and nav items
    expect(find.text('My Elora'), findsOneWidget);
    expect(find.text('650 / 1000 XP • Lvl 2'), findsOneWidget);
    expect(find.text('Elora'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });
}
