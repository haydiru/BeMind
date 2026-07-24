import 'package:flutter_test/flutter_test.dart';
import 'package:bemind/main.dart';

void main() {
  testWidgets('BeMind App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BeMindApp());
    expect(find.byType(BeMindApp), findsOneWidget);
  });
}
