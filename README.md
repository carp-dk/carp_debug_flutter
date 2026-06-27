# CARP Debug

[![CI](https://github.com/carp-dk/carp_debug_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/carp-dk/carp_debug_flutter/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/carp_debug_flutter.svg)](https://pub.dev/packages/carp_debug_flutter)

An in-app **debug toolkit**. Adds a floating button with a
debug menu which is independent of the host app's widget tree.
This toolkit was designed to be used in CARP Flutter apps (Android + iOS)
but can be used in any Flutter app. See the [CARP Debug Flutter example](https://github.com/carp-dk/carp_debug_flutter/tree/main/example) and [CARP Debug Docs](https://docs.carp.dk)

## Features

| Tool | What it does |
|------|--------------|
| **Environment & Servers** | Switch the deployment server and override any launch argument (`--dart-define`) at runtime, then **Apply** (live reconfigure) or **Restart**. |
| **Shared Preferences** | Inspect, search, edit, add and delete any key in a `SharedPreferences` store (the CARP user/session data). |
| **Database** | Browse the local sembast database: stores, records (pretty-printed JSON), delete records / clear stores. |
| **Device & App** | Device + app metadata (model, OS, version, build) plus screen metrics. |
| **Logs & Errors** | Captured `debugPrint` output, framework errors and uncaught async errors. |

Everything is extensible: register your own screens via `DebugTool` and add
extra `KeyValueStore` / `DebugDatabase` data sources.

-----

`CarpDebugToolkit` wraps the **whole** app in a root `Stack` and renders its UI
in its own scope (`MediaQuery`, `Theme`, `Localizations`, `ScaffoldMessenger`
and a dedicated `Navigator`). Because the overlay sits *above* the host
`MaterialApp` and never uses the host's router, a crashing screen or broken
navigation does not remove the button or the menu.

> Note that however, a *synchronous* infinite loop on the UI isolate blocks all Dart
> rendering (the toolkit included). The toolkit can handle crashes, exceptions 
> and broken navigation.

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

See [`example/`](example/) for a complete, runnable demo with
`SharedPreferences` + sembast data and a custom server field.

## Production builds

It is good practice to not ship the toolkit to end users. 
To keep it out of production archives:

1. Install as **`dev_dependencies`**
2. Reference it only from `kDebugMode`-gated code so Dart tree-shaking
   removes it; production code reads launch arguments through an app-local
   hook (`String? Function(String)? debugLaunchOverride`) rather than importing
   the package.

```dart
// main.dart — folds to `runApp(app)` in release; the wrapper (and the whole
// package) is tree-shaken away, and the dev-dependency native is excluded.
if (kDebugMode) await debug.initializeDebugTools();
runApp(kDebugMode ? debug.wrapWithDebugToolkit(app, db) : app);
```

On **Android** the plugin is fully excluded from the release archive
(absent from the release `GeneratedPluginRegistrant`). On **iOS** the Dart is
excluded; the small native stub is still linked but inert (Dart never calls it)
due to [flutter#163874](https://github.com/flutter/flutter/issues/163874).

## Custom tools
You can add your own custom tools by implementing the `DebugTool` interface.

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

## Continuous integration & releasing

Every push and pull request runs [`.github/workflows/ci.yml`](.github/workflows/ci.yml):
formatting (`dart format`), static analysis (`flutter analyze`), a Pigeon
drift check, the unit/widget tests (against the minimum and latest stable
Flutter), a publish dry-run, and Android + iOS example builds.

Releases publish to pub.dev automatically via OIDC (no stored tokens) from
[`.github/workflows/publish.yml`](.github/workflows/publish.yml). One-time setup:

1. **pub.dev → package Admin → Automated publishing:** enable publishing from
   GitHub Actions, repository `carp-dk/carp_debug_flutter`, tag pattern
   `v{{version}}`.
2. **GitHub → Settings → Environments:** create an environment named `pub.dev`
   with *Required reviewers* so each release waits for human approval.

To cut a release: bump `version:` in `pubspec.yaml`, add a matching
`CHANGELOG.md` entry, then push the tag:

```sh
git tag v0.1.2 && git push origin v0.1.2
```

A guard job verifies the tag matches the pubspec version and the CHANGELOG
before the (irreversible) publish runs.

## License

See [LICENSE](LICENSE).
