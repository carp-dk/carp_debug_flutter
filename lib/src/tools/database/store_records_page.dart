import 'package:flutter/material.dart';

import '../../data/debug_database.dart';
import '../../ui/widgets/confirm.dart';
import '../../ui/widgets/debug_scaffold.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/json_view.dart';
import 'record_detail_page.dart';

/// Page that lists the records of a single store, with per-record deletion and
/// a "clear store" action.
class StoreRecordsPage extends StatefulWidget {
  /// Creates a records page for [store] within [database].
  const StoreRecordsPage({
    super.key,
    required this.database,
    required this.store,
  });

  /// The owning database.
  final DebugDatabase database;

  /// The store whose records are listed.
  final String store;

  @override
  State<StoreRecordsPage> createState() => _StoreRecordsPageState();
}

class _StoreRecordsPageState extends State<StoreRecordsPage> {
  List<DebugRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await widget.database.records(widget.store);
    if (!mounted) return;
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  Future<void> _delete(DebugRecord record) async {
    final ok = await showDebugConfirm(
      context,
      title: 'Delete record',
      message: 'Delete record "${record.key}"?',
    );
    if (ok) {
      await widget.database.deleteRecord(widget.store, record.key);
      await _load();
    }
  }

  Future<void> _clear() async {
    final ok = await showDebugConfirm(
      context,
      title: 'Clear store',
      message: 'Delete all records in "${widget.store}"?',
      confirmLabel: 'Clear store',
    );
    if (ok) {
      await widget.database.clearStore(widget.store);
      await _load();
    }
  }

  Future<void> _open(DebugRecord record) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecordDetailPage(
          database: widget.database,
          store: widget.store,
          record: record,
        ),
      ),
    );
    if (changed == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      title: widget.store,
      actions: [
        IconButton(
          tooltip: 'Clear store',
          icon: const Icon(Icons.delete_sweep),
          onPressed: _records.isEmpty ? null : _clear,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? const EmptyState(icon: Icons.inbox, message: 'Store is empty.')
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, i) => _tile(_records[i]),
            ),
    );
  }

  Widget _tile(DebugRecord record) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.description_outlined),
      title: Text('${record.key}'),
      subtitle: Text(
        JsonView.format(record.value),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () => _delete(record),
      ),
      onTap: () => _open(record),
    );
  }
}
