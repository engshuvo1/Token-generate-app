import 'package:flutter_test/flutter_test.dart';
import 'package:tokenapp/main.dart';

void main() {
  testWidgets('TokenApp loads and shows token screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TokenApp());
    expect(find.text('Token Generator'), findsOneWidget);
    expect(find.text('TOKEN NUMBER'), findsOneWidget);
    expect(find.text('A-001'), findsOneWidget);
  });
}
