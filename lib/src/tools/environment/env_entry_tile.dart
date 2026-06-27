import 'package:flutter/material.dart';

import '../../config/debug_env.dart';
import '../../config/env_entry.dart';
import 'env_text_dialog.dart';

/// A single editable launch-argument row in the Environment tool.
///
/// Shows the argument's label, its effective value (with the underlying key)
/// and an "overridden" badge when a runtime override differs from the
/// compile-time default. The trailing control matches the entry's
/// [EnvValueType]; a revert button clears the override.
class EnvEntryTile extends StatelessWidget {
  /// Creates a tile for [entry]. [onChanged] is called after any edit so the
  /// parent can rebuild.
  const EnvEntryTile({super.key, required this.entry, required this.onChanged});

  /// The launch argument described by this tile.
  final EnvEntry entry;

  /// Invoked after the override is changed or cleared.
  final VoidCallback onChanged;

  DebugEnv get _env => DebugEnv();

  Future<void> _set(String value) async {
    await _env.setOverride(entry.key, value);
    onChanged();
  }

  Future<void> _revert() async {
    await _env.clearOverride(entry.key);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final value = _env.string(entry.key, fallback: entry.fallback);
    final overridden = _env.hasOverride(entry.key);
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Flexible(child: Text(entry.label)),
            if (overridden) const _OverriddenBadge(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key} = $value',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            if (entry.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  entry.description!,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (overridden)
              IconButton(
                tooltip: 'Revert to default (${entry.fallback})',
                icon: const Icon(Icons.settings_backup_restore, size: 20),
                onPressed: _revert,
              ),
            _control(context, value),
          ],
        ),
        isThreeLine: entry.description != null,
      ),
    );
  }

  Widget _control(BuildContext context, String value) {
    switch (entry.type) {
      case EnvValueType.toggle:
        return Switch(
          value: value.toLowerCase() == 'true' || value == '1',
          onChanged: (v) => _set(v.toString()),
        );
      case EnvValueType.enumeration:
        // If the current value is not one of the declared options (e.g. a
        // misconfigured fallback or a stale override after options changed),
        // include it as a "(custom)" item so it is shown rather than silently
        // blanked.
        final isKnown = value.isEmpty || entry.options.contains(value);
        final items = [
          for (final option in entry.options)
            DropdownMenuItem(value: option, child: Text(option)),
          if (!isKnown)
            DropdownMenuItem(value: value, child: Text('$value (custom)')),
        ];
        return DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: const Text('select'),
          underline: const SizedBox.shrink(),
          items: items,
          onChanged: (v) => v == null ? null : _set(v),
        );
      case EnvValueType.text:
      case EnvValueType.integer:
        return IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _editText(context, value),
        );
    }
  }

  Future<void> _editText(BuildContext context, String current) async {
    final result = await showEnvTextEditor(
      context,
      entry: entry,
      current: current,
    );
    if (result == null) return;
    // Reject a non-integer value rather than persisting something the app
    // cannot parse back.
    if (entry.type == EnvValueType.integer &&
        int.tryParse(result.trim()) == null) {
      return;
    }
    await _set(result);
  }
}

/// Small amber badge indicating a value differs from its compile-time default.
class _OverriddenBadge extends StatelessWidget {
  const _OverriddenBadge();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: Colors.amber.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'overridden',
      style: TextStyle(color: Colors.amber, fontSize: 10),
    ),
  );
}
