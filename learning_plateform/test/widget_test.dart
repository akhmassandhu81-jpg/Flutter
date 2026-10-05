
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_plateform/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LMSArenaApp(),
      ),
    );

    // Verify that LMSArenaApp is present in the widget tree.
    expect(find.byType(LMSArenaApp), findsOneWidget);

    // Drain pending timers from SplashScreen animation
    await tester.pumpAndSettle();
  });
}
