import 'package:flutter_test/flutter_test.dart';
import 'package:cdc/main.dart';

void main() {
  testWidgets('CDC PNL App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PnlCdcApp());
    expect(find.byType(PnlCdcApp), findsOneWidget);
  });
}
