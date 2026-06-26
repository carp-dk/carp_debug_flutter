import 'package:flutter/material.dart';

import '../../data/debug_database.dart';
import '../../ui/widgets/debug_scaffold.dart';
import '../../ui/widgets/empty_state.dart';
import 'store_records_page.dart';

/// Page that lists the stores in a [DebugDatabase], each with its record count.
/// Tapping a store opens its records.
///
/// Record counts are loaded once in [initState] (not via an inline
/// `FutureBuilder`, which would recreate its future on every rebuild and never
/// settle) and refreshed when returning from a store.
class DatabaseStoresPage extends StatefulWidget {
  /// Creates the stores list page.
  const DatabaseStoresPage({super.key, required this.database});

  /// The database whose stores are listed.
  final DebugDatabase database;

  @override
  State<DatabaseStoresPage> createState() => _DatabaseStoresPageState();
}

class _DatabaseStoresPageState extends State<DatabaseStoresPage> {
  Map<String, int> _counts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final counts = <String, int>{};
    for (final store in widget.database.storeNames) {
      counts[store] = (await widget.database.records(store)).length;
    }
    if (!mounted) return;
    setState(() {
      _counts = counts;
      _loading = false;
    });
  }

  Future<void> _open(String store) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            StoreRecordsPage(database: widget.database, store: store),
      ),
    );
    await _load(); // refresh counts after possible deletions
  }

  @override
  Widget build(BuildContext context) {
    final stores = widget.database.storeNames;
    return DebugScaffold(
      title: widget.database.name,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : stores.isEmpty
          ? const EmptyState(
              icon: Icons.storage,
              message: 'No stores configured for this database.',
            )
          : ListView(
              children: [
                for (final store in stores)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder_open),
                      title: Text(store),
                      subtitle: Text('${_counts[store] ?? 0} record(s)'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white38,
                      ),
                      onTap: () => _open(store),
                    ),
                  ),
              ],
            ),
    );
  }
}
