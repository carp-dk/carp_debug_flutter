import 'package:shared_preferences/shared_preferences.dart';

import '../config/debug_env.dart';

/// A generic, inspectable key/value store surfaced by the "Preferences" tool.
///
/// Implement this to expose any flat key/value storage to the toolkit. A
/// ready-made [SharedPreferencesKeyValueStore] is provided for the common case.
abstract class KeyValueStore {
  /// Display name shown as the section / page title.
  String get name;

  /// All keys currently present in the store.
  Future<List<String>> keys();

  /// Reads the value for [key]. Returns `null` if absent. The runtime type is
  /// one of `String`, `bool`, `int`, `double` or `List<String>`.
  Future<Object?> read(String key);

  /// Writes [value] for [key]. Supported runtime types are `String`, `bool`,
  /// `int`, `double` and `List<String>`.
  Future<void> write(String key, Object value);

  /// Removes [key] from the store.
  Future<void> delete(String key);

  /// Removes every key from the store.
  Future<void> clear();
}

/// A [KeyValueStore] backed by a [SharedPreferences] instance.
///
/// This is the store CARP apps use for user/session data (the authenticated
/// user, the active participant, the deployed study, locale, etc.), so editing
/// or deleting those keys here directly manipulates the app's persisted state.
class SharedPreferencesKeyValueStore implements KeyValueStore {
  /// Wraps an existing [SharedPreferences] instance.
  ///
  /// [hiddenPrefixes] keys are excluded from listing and bulk-clear. By default
  /// it hides the keys [DebugEnv] uses for its launch-argument overrides, since
  /// those are managed by the Environment tool — editing them here would not
  /// update DebugEnv's in-memory state.
  SharedPreferencesKeyValueStore(
    this._prefs, {
    this.name = 'Shared Preferences',
    List<String>? hiddenPrefixes,
  }) : _hiddenPrefixes = hiddenPrefixes ?? const [DebugEnv.storagePrefix];

  final SharedPreferences _prefs;
  final List<String> _hiddenPrefixes;

  @override
  final String name;

  bool _isHidden(String key) => _hiddenPrefixes.any(key.startsWith);

  List<String> get _visibleKeys =>
      _prefs.getKeys().where((k) => !_isHidden(k)).toList();

  @override
  Future<List<String>> keys() async => _visibleKeys..sort();

  @override
  Future<Object?> read(String key) async => _prefs.get(key);

  @override
  Future<void> write(String key, Object value) async {
    switch (value) {
      case final bool v:
        await _prefs.setBool(key, v);
      case final int v:
        await _prefs.setInt(key, v);
      case final double v:
        await _prefs.setDouble(key, v);
      case final String v:
        await _prefs.setString(key, v);
      case final List<String> v:
        await _prefs.setStringList(key, v);
      default:
        throw ArgumentError(
          'Unsupported SharedPreferences value type: ${value.runtimeType}',
        );
    }
  }

  @override
  Future<void> delete(String key) async => _prefs.remove(key);

  @override
  Future<void> clear() async {
    // Only clear visible keys so the toolkit's own override store is preserved.
    for (final key in _visibleKeys) {
      await _prefs.remove(key);
    }
  }
}
