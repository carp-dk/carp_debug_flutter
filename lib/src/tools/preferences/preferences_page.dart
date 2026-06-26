import 'package:flutter/material.dart';

import '../../data/key_value_store.dart';
import '../../ui/widgets/confirm.dart';
import '../../ui/widgets/debug_scaffold.dart';
import '../../ui/widgets/empty_state.dart';
import 'value_editor.dart';

/// Page that lists, searches, edits, adds and deletes entries in a
/// [KeyValueStore] (e.g. the app's shared preferences / user session data).
class PreferencesPage extends StatefulWidget {
  /// Creates a preferences page for [store].
  const PreferencesPage({super.key, required this.store});

  /// The key/value store being inspected.
  final KeyValueStore store;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  Map<String, Object?> _entries = {};
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final keys = await widget.store.keys();
    final entries = <String, Object?>{};
    for (final key in keys) {
      entries[key] = await widget.store.read(key);
    }
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _edit(String key, Object? value) async {
    final result = await showPrefEditor(
      context,
      initialKey: key,
      initialValue: value,
    );
    if (result != null) {
      await widget.store.write(result.key, result.value);
      await _load();
    }
  }

  Future<void> _add() async {
    final result = await showPrefEditor(context);
    if (result != null) {
      await widget.store.write(result.key, result.value);
      await _load();
    }
  }

  Future<void> _delete(String key) async {
    final ok = await showDebugConfirm(
      context,
      title: 'Delete key',
      message: 'Permanently delete "$key"?',
    );
    if (ok) {
      await widget.store.delete(key);
      await _load();
    }
  }

  Future<void> _clear() async {
    final ok = await showDebugConfirm(
      context,
      title: 'Clear all',
      message:
          'Delete every entry in ${widget.store.name}? This cannot be undone.',
      confirmLabel: 'Clear all',
    );
    if (ok) {
      await widget.store.clear();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys =
        _entries.keys
            .where((k) => k.toLowerCase().contains(_query.toLowerCase()))
            .toList()
          ..sort();
    return DebugScaffold(
      title: widget.store.name,
      actions: [
        IconButton(
          tooltip: 'Add',
          icon: const Icon(Icons.add),
          onPressed: _add,
        ),
        IconButton(
          tooltip: 'Clear all',
          icon: const Icon(Icons.delete_sweep),
          onPressed: _entries.isEmpty ? null : _clear,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search keys',
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: keys.isEmpty
                      ? const EmptyState(
                          icon: Icons.tune,
                          message: 'No matching preferences.',
                        )
                      : ListView.builder(
                          itemCount: keys.length,
                          itemBuilder: (context, i) => _tile(keys[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _tile(String key) {
    final value = _entries[key];
    final type = value?.runtimeType.toString() ?? 'null';
    return ListTile(
      dense: true,
      title: Text(key),
      subtitle: Text(
        '$type · $value',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () => _delete(key),
      ),
      onTap: () => _edit(key, value),
    );
  }
}
