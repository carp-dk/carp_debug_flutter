// On-device verification of the three reported fixes:
//  1. opening/closing an empty field editor must not throw,
//  2. captured logs are ANSI-stripped and coloured by inferred level,
//  3. a burst of logs does not crash / stays bounded.

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => DebugController.instance.close());

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    DebugEnv().resetForTest();
    await DebugEnv().initialize(preferences: prefs);
    await tester.pumpWidget(
      CarpDebugToolkit(
        config: const DebugToolkitConfig(
          envEntries: [EnvEntry(key: 'server-host', label: 'Server host')],
        ),
        child: const MaterialApp(home: Scaffold(body: Text('host'))),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();
  }

  testWidgets('empty field editor opens and closes cleanly', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Environment & Servers'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('logs are ANSI-stripped and burst-safe', (tester) async {
    DebugLog.instance.clear();
    for (var i = 0; i < 2000; i++) {
      DebugLog.instance.log('\x1B[33m[CAMS WARNING]\x1B[0m fast $i');
    }
    expect(DebugLog.instance.entries.length, lessThanOrEqualTo(1000 + 256));
    final last = DebugLog.instance.entries.last;
    expect(last.message.contains('\x1B'), isFalse);
    expect(last.level, DebugLogLevel.warning);

    await pump(tester);
    await tester.tap(find.text('Logs & Errors'));
    await tester.pumpAndSettle();
    // The rendered text must not contain raw escape codes.
    expect(find.textContaining('\x1B'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
