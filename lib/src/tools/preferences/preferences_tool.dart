import 'package:flutter/material.dart';

import '../../data/key_value_store.dart';
import '../../model/debug_tool.dart';
import 'preferences_page.dart';

/// Tool that exposes a [KeyValueStore] (typically shared preferences holding
/// the app's user / session data) for inspection and editing.
class PreferencesTool implements DebugTool {
  /// Creates a preferences tool for [store].
  const PreferencesTool(this.store);

  /// The store this tool inspects.
  final KeyValueStore store;

  @override
  String get id => 'preferences:${store.name}';

  @override
  String get title => store.name;

  @override
  String? get subtitle => 'Inspect, edit and delete stored values';

  @override
  IconData get icon => Icons.tune;

  @override
  Widget buildPage(BuildContext context) => PreferencesPage(store: store);
}
