// Widget test for the core toolkit overlay: the floating button must appear
// above the host app and open the self-contained debug menu when tapped.

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('floating button opens the debug menu', (tester) async {
    await tester.pumpWidget(
      const CarpDebugToolkit(
        config: DebugToolkitConfig(captureLogs: false),
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('host app'))),
        ),
      ),
    );

    // Host app and the floating button coexist.
    expect(find.text('host app'), findsOneWidget);
    expect(find.byIcon(Icons.bug_report), findsOneWidget);

    // Tapping the button opens the menu (rendered in the toolkit's own scope).
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();

    expect(find.text('Debug Toolkit'), findsOneWidget);
    expect(find.text('Device & App'), findsOneWidget);

    // Closing returns to the floating button.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bug_report), findsOneWidget);
  });
}
