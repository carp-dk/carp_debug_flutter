import 'package:flutter/material.dart';

import '../controller/debug_controller.dart';
import '../model/debug_tool.dart';
import 'widgets/debug_scaffold.dart';
import 'widgets/empty_state.dart';

/// The root page of the debug menu: a list of the available [DebugTool]s.
///
/// Tapping a row pushes that tool's page onto the toolkit's own navigator. The
/// app-bar close button dismisses the whole menu (back to the floating button).
class DebugHomePage extends StatelessWidget {
  /// Creates the debug home page.
  const DebugHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DebugController.instance;
    final tools = controller.tools;
    return DebugScaffold(
      title: controller.config.title,
      actions: [
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: controller.close,
        ),
      ],
      body: tools.isEmpty
          ? const EmptyState(
              icon: Icons.build_circle_outlined,
              message: 'No debug tools are configured.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tools.length,
              itemBuilder: (context, index) => _ToolTile(tool: tools[index]),
            ),
    );
  }
}

/// A single tappable row representing one [DebugTool].
class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool});

  final DebugTool tool;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(tool.icon),
        title: Text(tool.title),
        subtitle: tool.subtitle == null ? null : Text(tool.subtitle!),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => tool.buildPage(context)),
        ),
      ),
    );
  }
}
