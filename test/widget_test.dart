import 'package:flutter_test/flutter_test.dart';

import 'package:photo_booth/main.dart';

void main() {
  testWidgets('Photo Booth shell renders core areas', (WidgetTester tester) async {
    await tester.pumpWidget(const PhotoBoothApp());
    await tester.pumpAndSettle();

    expect(find.text('Photo Booth MVP'), findsOneWidget);
    expect(find.text('Target slot:'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });
}
