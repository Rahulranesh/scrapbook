import 'package:flutter_test/flutter_test.dart';

import 'package:scrapbook_memories/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScrapbookMemoriesApp());

    // Verify that the app title is present
    expect(find.text('My Scrapbooks'), findsOneWidget);
  });
}
