import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/app.dart';

void main() {
  testWidgets('App smoke test - mounts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HermanosLedgrApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify brand title exists
    expect(find.text('HERMANOS LEDGR'), findsOneWidget);
  });
}
