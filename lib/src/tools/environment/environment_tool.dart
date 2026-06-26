import 'package:flutter/material.dart';

import '../../model/debug_tool.dart';
import 'environment_page.dart';

/// Tool for switching servers and overriding launch arguments
/// (`--dart-define` values) at runtime.
///
/// This is the headline capability of the toolkit: it lets a tester repoint the
/// app's authentication and data servers, change the deployment mode / debug
/// level, etc., without rebuilding — then apply the change live or via a
/// restart.
class EnvironmentTool implements DebugTool {
  /// Creates the environment tool.
  const EnvironmentTool();

  @override
  String get id => 'environment';

  @override
  String get title => 'Environment & Servers';

  @override
  String? get subtitle => 'Switch servers and override launch arguments';

  @override
  IconData get icon => Icons.dns;

  @override
  Widget buildPage(BuildContext context) => const EnvironmentPage();
}
