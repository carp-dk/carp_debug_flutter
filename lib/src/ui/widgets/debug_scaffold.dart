import 'package:flutter/material.dart';

/// A consistent [Scaffold] for tool pages pushed onto the toolkit navigator.
///
/// Provides the app bar with [title], an automatic back button when the tool
/// navigator can pop, and optional [actions]. Tool implementations should wrap
/// their content in this so every page looks the same.
class DebugScaffold extends StatelessWidget {
  /// Creates a debug page scaffold.
  const DebugScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.floatingActionButton,
  });

  /// App-bar title.
  final String title;

  /// Page content.
  final Widget body;

  /// Optional app-bar action buttons.
  final List<Widget> actions;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
