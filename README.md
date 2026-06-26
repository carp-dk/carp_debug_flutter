# CARP Debug

An in-app **debug toolkit** for CARP Flutter apps (Android + iOS). It adds a
draggable, always-on-top floating button that opens a self-contained debug menu
— independent of the host app's widget tree, so it keeps working even when a
screen crashes.

Inspired by [framna-dk/spices](https://github.com/framna-dk/spices) (Flutter
overlay) and [DebugSwift](https://github.com/DebugSwift/DebugSwift) (native
toolkit).

## Features

| Tool | What it does |
|------|--------------|
| **Environment & Servers** | Switch the authentication / app server and override any launch argument (`--dart-define`) at runtime, then **Apply** (live reconfigure) or **Restart**. |
| **Shared Preferences** | Inspect, search, edit, add and delete any key in a `SharedPreferences`-backed store (the CARP user/session data). |
| **Database** | Browse the local **sembast** database: stores, records (pretty-printed JSON), delete records / clear stores. |
| **Device & App** | Native device + app metadata (model, OS, version, build) plus screen metrics. |
| **Logs & Errors** | Captured `debugPrint` output, framework errors and uncaught async errors — visible even after a crash. |

Everything is extensible: register your own screens via `DebugTool` and add
extra `KeyValueStore` / `DebugDatabase` data sources.

## How it stays independent of the app

`CarpDebugToolkit` wraps the **whole** app in a root `Stack` and renders its UI
in its own scope (`MediaQuery`, `Theme`, `Localizations`, `ScaffoldMessenger`
and a dedicated `Navigator`). Because the overlay sits *above* the host
`MaterialApp` and never uses the host's router, a crashing screen or broken
navigation does not remove the button or the menu.

> Note: a *synchronous* infinite loop on the UI isolate blocks all Dart
> rendering (the toolkit included) — no Flutter overlay can survive that. The
> toolkit is resilient to crashes, exceptions and broken navigation; for a
> truly wedged isolate use the native **Restart** action (Android relaunches
> the process; iOS performs an in-process Phoenix restart).

## Runtime launch-argument overrides (`DebugEnv`)

CARP apps read config such as the deployment mode with `String.fromEnvironment`,
which is fixed at build time. `DebugEnv` adds a runtime override layer that is
persisted across restarts.

```dart
// 1. Load persisted overrides before anything reads configuration.
await DebugEnv().initialize();
DebugEnv().registerAll(const [
  EnvEntry(
    key: 'deployment-mode',
    label: 'Deployment mode',
    type: EnvValueType.enumeration,
    options: ['production', 'test', 'dev'],
    fallback: String.fromEnvironment('deployment-mode', defaultValue: 'production'),
  ),
]);

// 2. Read config through DebugEnv instead of String.fromEnvironment.
final mode = DebugEnv().string('deployment-mode',
    fallback: const String.fromEnvironment('deployment-mode', defaultValue: 'production'));
```

## Usage

```dart
import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await DebugEnv().initialize(preferences: prefs);

  final db = await openMySembastDatabase();

  runApp(CarpDebugToolkit(
    enabled: kDebugMode, // or bool.fromEnvironment('debug-toolkit', defaultValue: kDebugMode)
    config: DebugToolkitConfig(
      title: 'My App Debug',
      envEntries: myEnvEntries,
      keyValueStores: [SharedPreferencesKeyValueStore(prefs)],
      databases: [SembastDebugDatabase(db, [
        SembastStoreDescriptor('settings', StoreRef<String, Object?>.main()),
        SembastStoreDescriptor('results', intMapStoreFactory.store('results')),
      ])],
      onApply: () => myBackend.reconfigure(),        // live reconfigure
      onReinitialize: () => myBackend.reconfigure(), // before in-process restart
    ),
    child: const MyApp(),
  ));
}
```

See [`example/`](example/) for a complete, runnable demo with real
`SharedPreferences` + sembast data and a custom server field.

## Custom tools

```dart
class MyTool implements DebugTool {
  @override String get id => 'my-tool';
  @override String get title => 'My Tool';
  @override String? get subtitle => 'Does something useful';
  @override IconData get icon => Icons.science;
  @override Widget buildPage(BuildContext context) =>
      const DebugScaffold(title: 'My Tool', body: Center(child: Text('Hi')));
}
// DebugToolkitConfig(extraTools: [MyTool()])
```

## Platform notes

- **iOS** uses **CocoaPods** (no Swift Package Manager manifest). This is
  intentional: the repository folder name (`carp_debug_flutter`) differs from
  the Dart package name (`carp_debug_flutter`), which breaks SPM's local-path
  identity check. CocoaPods is unaffected. Minimum iOS **15.0**.
- **Android** `minSdk 24`. Native code is type-safe via **Pigeon**
  (`pigeons/messages.dart`; regenerate with
  `dart run pigeon --input pigeons/messages.dart`).

## License

See [LICENSE](LICENSE).
