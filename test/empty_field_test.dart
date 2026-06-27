// Reproduction: opening and closing the editor for an (empty) text launch
// argument must not throw (e.g. "TextEditingController used after dispose").

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => DebugController.instance.close());

  Future<void> pumpEnv(WidgetTester tester) async {
    late SharedPreferences prefs;
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      DebugEnv().resetForTest();
      await DebugEnv().initialize(preferences: prefs);
    });
    await tester.pumpWidget(
      CarpDebugToolkit(
        config: DebugToolkitConfig(
          captureLogs: false,
          envEntries: const [
            EnvEntry(key: 'server-host', label: 'App server host'), // empty text
          ],
        ),
        child: const MaterialApp(home: Scaffold(body: Text('host'))),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Environment & Servers'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel empty text editor does not throw', (tester) async {
    await pumpEnv(tester);
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle(); // runs the dialog dismiss animation
    expect(tester.takeException(), isNull);
  });

  testWidgets('save empty text editor does not throw', (tester) async {
    await pumpEnv(tester);
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
