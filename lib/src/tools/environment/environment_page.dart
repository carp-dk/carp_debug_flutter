import 'package:flutter/material.dart';

import '../../config/debug_env.dart';
import '../../config/env_entry.dart';
import '../../controller/debug_controller.dart';
import '../../ui/debug_restarter.dart';
import '../../ui/widgets/confirm.dart';
import '../../ui/widgets/debug_scaffold.dart';
import '../../ui/widgets/empty_state.dart';
import 'env_entry_tile.dart';

/// The Environment tool page: edit launch-argument overrides (including the
/// authentication / app server) and apply them live or via a restart.
class EnvironmentPage extends StatefulWidget {
  /// Creates the environment page.
  const EnvironmentPage({super.key});

  @override
  State<EnvironmentPage> createState() => _EnvironmentPageState();
}

class _EnvironmentPageState extends State<EnvironmentPage> {
  bool _applying = false;

  Map<String, List<EnvEntry>> get _grouped {
    final grouped = <String, List<EnvEntry>>{};
    for (final entry in DebugEnv().entries) {
      grouped.putIfAbsent(entry.group ?? 'General', () => []).add(entry);
    }
    return grouped;
  }

  Future<void> _apply() async {
    final onApply = DebugController.instance.config.onApply;
    if (onApply == null) return;
    setState(() => _applying = true);
    try {
      await onApply();
      _toast('Configuration applied');
    } catch (error) {
      _toast('Apply failed: $error');
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<void> _resetAll() async {
    final ok = await showDebugConfirm(
      context,
      title: 'Reset overrides',
      message: 'Clear all launch-argument overrides and use the defaults?',
      confirmLabel: 'Reset',
    );
    if (ok) {
      await DebugEnv().clearAll();
      setState(() {});
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    return DebugScaffold(
      title: 'Environment & Servers',
      actions: [
        IconButton(
          tooltip: 'Reset all',
          icon: const Icon(Icons.restart_alt),
          onPressed: grouped.isEmpty ? null : _resetAll,
        ),
      ],
      body: grouped.isEmpty
          ? const EmptyState(
              icon: Icons.dns,
              message: 'No launch arguments registered.',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      for (final group in grouped.entries) ...[
                        _GroupHeader(group.key),
                        for (final entry in group.value)
                          EnvEntryTile(
                            entry: entry,
                            onChanged: () => setState(() {}),
                          ),
                      ],
                    ],
                  ),
                ),
                _ActionBar(applying: _applying, onApply: _apply),
              ],
            ),
    );
  }
}

/// A group title (e.g. "Server", "Logging") above a set of entries.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}

/// Bottom bar with the "Apply" (live reconfigure) and "Restart" actions.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.applying, required this.onApply});

  final bool applying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final canApply = DebugController.instance.config.onApply != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: (!canApply || applying) ? null : onApply,
                icon: applying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Apply'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => DebugRestarter.restart(context),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Restart app'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
