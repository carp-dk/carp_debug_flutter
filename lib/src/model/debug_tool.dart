import 'package:flutter/widgets.dart';

/// A single entry in the debug menu.
///
/// Each tool contributes a row on the debug home page and a full page that is
/// pushed onto the toolkit's own navigator when the row is tapped. Implement
/// this to add custom, app-specific debugging screens alongside the built-in
/// ones.
abstract class DebugTool {
  /// Stable identifier, unique within a toolkit configuration.
  String get id;

  /// Title shown in the menu row and as the page title.
  String get title;

  /// Optional one-line description shown beneath the [title] in the menu.
  String? get subtitle => null;

  /// Leading icon shown in the menu row.
  IconData get icon;

  /// Builds the tool's page. The returned widget is pushed onto the toolkit's
  /// independent navigator, so it must provide its own scaffold/app bar (use
  /// [DebugScaffold] for a consistent look).
  Widget buildPage(BuildContext context);
}
