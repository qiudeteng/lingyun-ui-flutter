import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('demo boots', (tester) async {
    await tester.pumpWidget(const LingyunGlassDemoApp());
    expect(find.textContaining('lingyun'), findsWidgets);
  });
}
