import 'package:flutter/material.dart';

import '../../model/debug_tool.dart';
import '../../platform/native_bridge.dart';
import 'device_page.dart';

/// Tool that shows native device and application metadata (read-only).
class DeviceTool implements DebugTool {
  /// Creates the device tool backed by [bridge].
  const DeviceTool(this.bridge);

  /// Native bridge used to fetch device info.
  final NativeBridge bridge;

  @override
  String get id => 'device';

  @override
  String get title => 'Device & App';

  @override
  String? get subtitle => 'Hardware, OS, version and screen metrics';

  @override
  IconData get icon => Icons.phone_iphone;

  @override
  Widget buildPage(BuildContext context) => DevicePage(bridge: bridge);
}
