import 'package:flutter_test/flutter_test.dart';
import 'package:tokenapp/main.dart';

void main() {
  testWidgets('TokenApp loads and shows token screen with required fields', (WidgetTester tester) async {
    await tester.pumpWidget(const TokenApp());
    expect(find.text('🏠 Home / Token Printer'), findsOneWidget);
    expect(find.text('Token Number *'), findsOneWidget);
    expect(find.text('Serial Number *'), findsOneWidget);
    expect(find.text('🖨 PRINT TOKEN'), findsOneWidget);
  });
}
