import 'package:flutter/material.dart';

import '../../data/debug_database.dart';
import '../../ui/widgets/confirm.dart';
import '../../ui/widgets/debug_scaffold.dart';
import '../../ui/widgets/json_view.dart';

/// Page that shows a single record's value as pretty-printed JSON and offers
/// deletion. Pops with `true` when the record was deleted so the caller can
/// refresh.
class RecordDetailPage extends StatelessWidget {
  /// Creates a detail page for [record] in [store] of [database].
  const RecordDetailPage({
    super.key,
    required this.database,
    required this.store,
    required this.record,
  });

  /// The owning database.
  final DebugDatabase database;

  /// The store the record belongs to.
  final String store;

  /// The record being viewed.
  final DebugRecord record;

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      title: 'Record ${record.key}',
      actions: [
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _delete(context),
        ),
      ],
      body: JsonView(value: record.value),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDebugConfirm(
      context,
      title: 'Delete record',
      message: 'Delete record "${record.key}"?',
    );
    if (ok) {
      await database.deleteRecord(store, record.key);
      if (context.mounted) Navigator.of(context).pop(true);
    }
  }
}
