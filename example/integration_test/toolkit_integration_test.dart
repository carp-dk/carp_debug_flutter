// End-to-end test that drives the full toolkit UI on a real device/emulator:
// opening the menu, switching a server via the Environment tool, and inspecting
// the shared-preferences and sembast data sources. Uses real stores (no mocks).

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full toolkit flow: open, switch server, inspect data', (
    tester,
  ) async {
    // Real backing stores.
    SharedPreferences.setMockInitialValues({'demo_key': 'demo_value'});
    final prefs = await SharedPreferences.getInstance();
    DebugEnv().resetForTest();
    await DebugEnv().initialize(preferences: prefs);

    final db = await newDatabaseFactoryMemory().openDatabase('mem.db');
    final store = StoreRef<String, Object?>.main();
    await store.record('alpha').put(db, {'value': 1});

    await tester.pumpWidget(
      CarpDebugToolkit(
        config: DebugToolkitConfig(
          captureLogs: false,
          envEntries: const [
            EnvEntry(
              key: 'deployment-mode',
              label: 'Deployment mode',
              type: EnvValueType.enumeration,
              options: ['production', 'test', 'dev'],
              fallback: 'production',
            ),
          ],
          keyValueStores: [SharedPreferencesKeyValueStore(prefs)],
          databases: [
            SembastDebugDatabase(db, [SembastStoreDescriptor('main', store)]),
          ],
        ),
        child: const MaterialApp(home: Scaffold(body: Text('host'))),
      ),
    );
    await tester.pumpAndSettle();

    // Open the menu.
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();
    expect(find.text('Environment & Servers'), findsOneWidget);

    // Switch the deployment mode via the Environment tool.
    await tester.tap(find.text('Environment & Servers'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('test').last);
    await tester.pumpAndSettle();
    expect(DebugEnv().overrideOf('deployment-mode'), 'test');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Inspect shared preferences.
    await tester.tap(find.text('Shared Preferences'));
    await tester.pumpAndSettle();
    expect(find.text('demo_key'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Inspect the database.
    await tester.tap(find.text('Database'));
    await tester.pumpAndSettle();
    expect(find.text('main'), findsOneWidget);
    await tester.tap(find.text('main'));
    await tester.pumpAndSettle();
    expect(find.text('alpha'), findsOneWidget);
  });
}
