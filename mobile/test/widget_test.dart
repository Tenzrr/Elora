import 'package:flutter_test/flutter_test.dart';
import 'package:garden_mobile/main.dart';

void main() {
  testWidgets('GardenApp initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GardenApp());

    // Verify app launches and displays top bar and nav items
    expect(find.text('My Garden'), findsOneWidget);
    expect(find.text('650 / 1000 XP • Lvl 2'), findsOneWidget);
    expect(find.text('Garden'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });
}
