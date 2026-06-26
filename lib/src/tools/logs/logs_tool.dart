import 'package:flutter/material.dart';

import '../../model/debug_tool.dart';
import 'logs_page.dart';

/// Tool that shows captured console output, framework errors and uncaught
/// async errors collected by [DebugLog].
class LogsTool implements DebugTool {
  /// Creates the logs tool.
  const LogsTool();

  @override
  String get id => 'logs';

  @override
  String get title => 'Logs & Errors';

  @override
  String? get subtitle => 'Captured prints, errors and crashes';

  @override
  IconData get icon => Icons.receipt_long;

  @override
  Widget buildPage(BuildContext context) => const LogsPage();
}
