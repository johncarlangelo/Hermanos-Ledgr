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

    // Initial pump with splash screen mounted
    await tester.pump();
    expect(find.text('HERMANOS LEDGR'), findsOneWidget);

    // Settle through splash animation into main shell
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Verify app shell title exists
    expect(find.text('Hermanos Ledgr'), findsOneWidget);
  });
}
