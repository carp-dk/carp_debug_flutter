/// An in-app debugging toolkit for CARP Flutter apps.
///
/// Wrap the app's root widget in [CarpDebugToolkit] to get a draggable floating
/// button that opens a self-contained debug menu. The menu is independent of
/// the host app's widget tree, so it keeps working even when a screen crashes.
///
/// Included tools:
///  * switch the deployment server and override any launch argument
///    (`--dart-define`) at runtime — see [DebugEnv] and [EnvEntry];
///  * inspect, edit and delete shared-preferences / user-session data — see
///    [KeyValueStore];
///  * browse and delete records in the local (sembast) database — see
///    [DebugDatabase];
///  * view device / app metadata and captured logs & errors.
///
/// Register your own screens by implementing [DebugTool] and passing them via
/// [DebugToolkitConfig.extraTools].
library;

export 'src/config/debug_env.dart';
export 'src/config/debug_toolkit_config.dart';
export 'src/config/env_entry.dart';
export 'src/controller/debug_controller.dart' show DebugController;
export 'src/data/debug_database.dart';
export 'src/data/key_value_store.dart';
export 'src/logging/debug_log.dart';
export 'src/model/debug_tool.dart';
export 'src/platform/messages.g.dart' show NativeDeviceInfo;
export 'src/platform/native_bridge.dart' show NativeBridge;
export 'src/ui/debug_toolkit.dart' show CarpDebugToolkit;
export 'src/ui/widgets/debug_scaffold.dart' show DebugScaffold;
