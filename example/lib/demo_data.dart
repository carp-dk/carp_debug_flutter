import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Launch arguments the example exposes for runtime overriding.
///
/// These mirror what a real CARP app reads from `--dart-define`: the deployment
/// mode and server hosts (auth + app), the debug level, plus a couple of
/// network / feature-flag values to show the different editor types.
const demoEnvEntries = <EnvEntry>[
  EnvEntry(
    key: 'deployment-mode',
    label: 'Deployment mode',
    group: 'Server',
    type: EnvValueType.enumeration,
    options: ['production', 'test', 'dev'],
    fallback: 'production',
    description: 'Selects which CAWS environment the app talks to.',
  ),
  EnvEntry(
    key: 'app-server-host',
    label: 'App server host',
    group: 'Server',
    fallback: 'carp.computerome.dk',
    description: 'Overrides the data/app server host.',
  ),
  EnvEntry(
    key: 'auth-server-host',
    label: 'Auth server host',
    group: 'Server',
    fallback: 'carp.computerome.dk',
    description: 'Overrides the authentication (Keycloak) server host.',
  ),
  EnvEntry(
    key: 'debug-level',
    label: 'Debug level',
    group: 'Logging',
    type: EnvValueType.enumeration,
    options: ['none', 'info', 'warning', 'debug'],
    fallback: 'info',
  ),
  EnvEntry(
    key: 'api-timeout',
    label: 'API timeout (seconds)',
    group: 'Network',
    type: EnvValueType.integer,
    fallback: '30',
  ),
  EnvEntry(
    key: 'analytics-enabled',
    label: 'Analytics enabled',
    group: 'Feature flags',
    type: EnvValueType.toggle,
    fallback: 'false',
  ),
];

final _settingsStore = StoreRef<String, Object?>.main();
final _resultsStore = intMapStoreFactory.store('results');

/// The sembast stores exposed to the Database tool.
final demoStores = <SembastStoreDescriptor>[
  SembastStoreDescriptor('settings (main store)', _settingsStore),
  SembastStoreDescriptor('results', _resultsStore),
];

/// Opens the example's sembast database in the app documents directory.
Future<Database> openDemoDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return databaseFactoryIo.openDatabase('${dir.path}/example_debug.db');
}

/// Seeds representative preference and database data on first launch so the
/// Preferences and Database tools have real content to show.
Future<void> seedDemoData(SharedPreferences prefs, Database db) async {
  if (!prefs.containsKey('seeded')) {
    await prefs.setBool('seeded', true);
    await prefs.setString(
      'user',
      '{"id":"u-123","username":"tester@dtu.dk","firstName":"Test"}',
    );
    await prefs.setBool('isAnonymous', false);
    await prefs.setInt('session_count', 3);
    await prefs.setStringList('recent_studies', ['neuropathy', 'demo']);
  }
  if (await _resultsStore.count(db) == 0) {
    await _settingsStore.record('patient').put(db, {'age': 42, 'sex': 'F'});
    await _settingsStore.record('vibrationDuration').put(db, 30);
    await _resultsStore.add(db, {'score': 12, 'task': 'vibration'});
    await _resultsStore.add(db, {'score': 7, 'task': 'pain'});
  }
}
