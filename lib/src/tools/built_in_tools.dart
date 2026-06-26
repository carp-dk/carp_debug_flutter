import '../config/debug_env.dart';
import '../config/debug_toolkit_config.dart';
import '../model/debug_tool.dart';
import '../platform/native_bridge.dart';
import 'database/database_tool.dart';
import 'device/device_tool.dart';
import 'environment/environment_tool.dart';
import 'logs/logs_tool.dart';
import 'preferences/preferences_tool.dart';

/// Assembles the ordered list of tools shown in the debug menu from [config].
///
/// Tools are included only when they have something to show: the Environment
/// tool appears only when launch arguments are registered, and one Preferences
/// / Database tool is added per configured data source. Any [config.extraTools]
/// supplied by the app are appended at the end.
List<DebugTool> buildDefaultTools(
  DebugToolkitConfig config,
  NativeBridge bridge,
) {
  return [
    if (DebugEnv().entries.isNotEmpty) const EnvironmentTool(),
    for (final store in config.keyValueStores) PreferencesTool(store),
    for (final database in config.databases) DatabaseTool(database),
    if (config.showDeviceInfo) DeviceTool(bridge),
    if (config.captureLogs) const LogsTool(),
    ...config.extraTools,
  ];
}
