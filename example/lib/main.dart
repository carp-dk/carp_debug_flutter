import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_app.dart';
import 'demo_data.dart';

/// Entry point for the example app.
///
/// Demonstrates the full wiring of [CarpDebugToolkit]:
///  1. initialize [DebugEnv] (loads persisted launch-argument overrides) before
///     anything reads configuration;
///  2. open the real data stores (shared preferences + sembast) and seed them;
///  3. wrap the host app in [CarpDebugToolkit] with the data sources, launch
///     arguments and apply/restart hooks.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await DebugEnv().initialize(preferences: prefs);

  final db = await openDemoDatabase();
  await seedDemoData(prefs, db);

  runApp(
    CarpDebugToolkit(
      enabled: true,
      config: DebugToolkitConfig(
        title: 'Example Debug Toolkit',
        envEntries: demoEnvEntries,
        keyValueStores: [SharedPreferencesKeyValueStore(prefs)],
        databases: [SembastDebugDatabase(db, demoStores)],
        // Live-apply: re-read the new configuration without a restart.
        onApply: () async => demoConfig.reload(),
        // Re-run on the in-process restart path (iOS).
        onReinitialize: () async => demoConfig.reload(),
      ),
      child: const DemoApp(),
    ),
  );
}
