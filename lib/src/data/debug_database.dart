import 'package:sembast/sembast.dart';

/// A single record (key + value) read from a [DebugDatabase] store.
class DebugRecord {
  /// Creates a record snapshot.
  const DebugRecord(this.key, this.value);

  /// The record's primary key (e.g. an `int` auto-id or a `String` key).
  final Object key;

  /// The record's value (typically a JSON-like `Map`, `List` or scalar).
  final Object? value;
}

/// An inspectable, structured database surfaced by the "Database" tool.
///
/// A database exposes one or more named *stores*; each store contains records.
abstract class DebugDatabase {
  /// Display name shown as the page title.
  String get name;

  /// The names of the stores that can be inspected.
  List<String> get storeNames;

  /// All records in the store named [store].
  Future<List<DebugRecord>> records(String store);

  /// Deletes the record identified by [key] from [store].
  Future<void> deleteRecord(String store, Object key);

  /// Removes every record from [store].
  Future<void> clearStore(String store);
}

/// Couples a human-readable label with a sembast [StoreRef] so the toolkit can
/// inspect it. The app provides these because sembast does not enumerate its
/// stores at runtime.
class SembastStoreDescriptor {
  /// Creates a descriptor for a sembast store.
  const SembastStoreDescriptor(this.label, this.store);

  /// The store name shown in the UI.
  final String label;

  /// The sembast store reference (any key/value types are accepted).
  final StoreRef<dynamic, dynamic> store;
}

/// A [DebugDatabase] backed by a sembast [Database].
///
/// CARP apps persist results and settings in a sembast database; pointing the
/// toolkit at that database (and listing its stores) makes every persisted
/// record viewable and deletable from the debug menu.
class SembastDebugDatabase implements DebugDatabase {
  /// Wraps an open sembast [database] and the [stores] to expose.
  SembastDebugDatabase(
    this.database,
    List<SembastStoreDescriptor> stores, {
    this.name = 'Database',
  }) : _stores = {for (final s in stores) s.label: s.store};

  /// The open sembast database.
  final Database database;

  @override
  final String name;

  final Map<String, StoreRef<dynamic, dynamic>> _stores;

  @override
  List<String> get storeNames => _stores.keys.toList(growable: false);

  StoreRef<dynamic, dynamic> _store(String name) {
    final store = _stores[name];
    if (store == null) throw ArgumentError('Unknown store: $name');
    return store;
  }

  @override
  Future<List<DebugRecord>> records(String store) async {
    final snapshots = await _store(store).find(database);
    return [
      for (final snapshot in snapshots)
        DebugRecord(snapshot.key as Object, snapshot.value),
    ];
  }

  @override
  Future<void> deleteRecord(String store, Object key) async {
    await _store(store).record(key).delete(database);
  }

  @override
  Future<void> clearStore(String store) async {
    await _store(store).delete(database);
  }
}
