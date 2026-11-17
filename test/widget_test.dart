
import 'package:flutter_test/flutter_test.dart';
import 'package:supportify/main.dart';

void main() {
  testWidgets('Supportify app launches successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SupportifyApp());

    expect(find.text('Supportify'), findsOneWidget);
  });
}
