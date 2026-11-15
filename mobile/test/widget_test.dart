import 'package:flutter_test/flutter_test.dart';
import 'package:elora_mobile/main.dart';

void main() {
  testWidgets('starts the scaffold without offering prototype features',
      (tester) async {
    await tester.pumpWidget(const EloraApp());

    expect(find.text('Elora'), findsOneWidget);
    expect(
      find.text('Development scaffold. Features are not implemented.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
