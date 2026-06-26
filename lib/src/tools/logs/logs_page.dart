import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../logging/debug_log.dart';
import '../../ui/widgets/debug_scaffold.dart';
import '../../ui/widgets/empty_state.dart';

/// Page that renders the [DebugLog] ring buffer, newest entries last, with
/// per-level colouring. Supports clearing and copying all captured output.
class LogsPage extends StatelessWidget {
  /// Creates the logs page.
  const LogsPage({super.key});

  static const Map<DebugLogLevel, Color> _colors = {
    DebugLogLevel.debug: Colors.white54,
    DebugLogLevel.info: Colors.white,
    DebugLogLevel.warning: Colors.orangeAccent,
    DebugLogLevel.error: Colors.redAccent,
  };

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}.${t.millisecond.toString().padLeft(3, '0')}';

  @override
  Widget build(BuildContext context) {
    final log = DebugLog.instance;
    return DebugScaffold(
      title: 'Logs & Errors',
      actions: [
        IconButton(
          tooltip: 'Copy all',
          icon: const Icon(Icons.copy_all),
          onPressed: () => _copyAll(context, log),
        ),
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.delete_sweep),
          onPressed: log.clear,
        ),
      ],
      body: AnimatedBuilder(
        animation: log,
        builder: (context, _) {
          final entries = log.entries;
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long,
              message: 'No logs captured yet.',
            );
          }
          return ListView.separated(
            reverse: true,
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[entries.length - 1 - index];
              return _LogTile(
                entry: entry,
                color: _colors[entry.level]!,
                time: _formatTime(entry.time),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _copyAll(BuildContext context, DebugLog log) async {
    final text = log.entries
        .map(
          (e) =>
              '${_formatTime(e.time)} [${e.level.name}] ${e.message}'
              '${e.stackTrace != null ? '\n${e.stackTrace}' : ''}',
        )
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logs copied')));
    }
  }
}

/// A single log line: timestamp, level-coloured message and optional stack.
class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.entry,
    required this.color,
    required this.time,
  });

  final DebugLogEntry entry;
  final Color color;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          '$time  ${entry.message}',
          style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 12),
        ),
        if (entry.stackTrace != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SelectableText(
              entry.stackTrace!,
              style: const TextStyle(
                color: Colors.white30,
                fontFamily: 'monospace',
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
