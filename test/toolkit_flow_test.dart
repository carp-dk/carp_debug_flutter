// Confirms the hang is the test harness's fake-async clock vs. real plugin I/O
// (do async setup in `runAsync`), and isolates sembast navigation.

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _env = [
  EnvEntry(
    key: 'deployment-mode',
    label: 'Deployment mode',
    type: EnvValueType.enumeration,
    options: ['production', 'test', 'dev'],
    fallback: 'production',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => DebugController.instance.close());

  testWidgets('env switch + prefs (no db nav)', (tester) async {
    late SharedPreferences prefs;
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({'user_id': 'abc'});
      prefs = await SharedPreferences.getInstance();
      DebugEnv().resetForTest();
      await DebugEnv().initialize(preferences: prefs);
    });

    await tester.pumpWidget(
      CarpDebugToolkit(
        config: DebugToolkitConfig(
          captureLogs: false,
          envEntries: _env,
          keyValueStores: [SharedPreferencesKeyValueStore(prefs)],
        ),
        child: const MaterialApp(home: Scaffold(body: Text('host'))),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Environment & Servers'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('test').last);
    await tester.pumpAndSettle();
    expect(DebugEnv().overrideOf('deployment-mode'), 'test');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shared Preferences'));
    await tester.pumpAndSettle();
    expect(find.text('user_id'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 25)));

  testWidgets('database nav (sembast)', (tester) async {
    late Database db;
    await tester.runAsync(() async {
      db = await newDatabaseFactoryMemory().openDatabase('t.db');
      await intMapStoreFactory.store('result_store').add(db, {'score': 9});
    });
    await tester.pumpWidget(
      CarpDebugToolkit(
        config: DebugToolkitConfig(
          captureLogs: false,
          databases: [
            SembastDebugDatabase(db, [
              SembastStoreDescriptor(
                'results',
                intMapStoreFactory.store('result_store'),
              ),
            ]),
          ],
        ),
        child: const MaterialApp(home: Scaffold(body: Text('host'))),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Database'));
    await tester.pumpAndSettle();
    expect(find.text('results'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 25)));
}
