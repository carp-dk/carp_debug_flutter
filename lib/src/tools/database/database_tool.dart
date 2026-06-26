import 'package:flutter/material.dart';

import '../../data/debug_database.dart';
import '../../model/debug_tool.dart';
import 'database_stores_page.dart';

/// Tool that exposes a structured [DebugDatabase] (e.g. the app's sembast
/// database) so its stores and records can be inspected and deleted.
class DatabaseTool implements DebugTool {
  /// Creates a database tool for [database].
  const DatabaseTool(this.database);

  /// The database this tool inspects.
  final DebugDatabase database;

  @override
  String get id => 'database:${database.name}';

  @override
  String get title => database.name;

  @override
  String? get subtitle => 'Browse stores and delete records';

  @override
  IconData get icon => Icons.storage;

  @override
  Widget buildPage(BuildContext context) =>
      DatabaseStoresPage(database: database);
}
