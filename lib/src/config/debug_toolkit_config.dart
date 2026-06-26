import '../data/debug_database.dart';
import '../data/key_value_store.dart';
import '../model/debug_tool.dart';
import 'env_entry.dart';

/// Immutable configuration describing what the debug toolkit can do for a
/// particular app.
///
/// Pass an instance to `CarpDebugToolkit`. Everything is optional: an empty
/// config still gives you the floating button, the device-info tool and the
/// log console.
class DebugToolkitConfig {
  /// Creates a toolkit configuration.
  const DebugToolkitConfig({
    this.title = 'Debug Toolkit',
    this.envEntries = const [],
    this.keyValueStores = const [],
    this.databases = const [],
    this.extraTools = const [],
    this.onApply,
    this.onReinitialize,
    this.captureLogs = true,
    this.showDeviceInfo = true,
  });

  /// Title shown at the top of the debug home page.
  final String title;

  /// Launch arguments to register with `DebugEnv` and expose in the
  /// Environment tool. If empty, the Environment tool is hidden.
  final List<EnvEntry> envEntries;

  /// Key/value stores to expose in the Preferences tool (one page each).
  final List<KeyValueStore> keyValueStores;

  /// Structured databases to expose in the Database tool (one page each).
  final List<DebugDatabase> databases;

  /// Additional custom tools appended to the built-in ones.
  final List<DebugTool> extraTools;

  /// Invoked when the user taps "Apply" in the Environment tool. Use it to
  /// reconfigure services live (e.g. re-point the CARP backend at a new server)
  /// without restarting. May be `null` if a restart is always required.
  final Future<void> Function()? onApply;

  /// Invoked just before an in-process restart (the iOS fallback path, since
  /// iOS cannot relaunch the process). Use it to re-run async initialization
  /// such as re-authenticating against the newly selected server.
  final Future<void> Function()? onReinitialize;

  /// Whether to capture logs/errors and show the Logs tool.
  final bool captureLogs;

  /// Whether to show the native Device & App info tool.
  final bool showDeviceInfo;
}
