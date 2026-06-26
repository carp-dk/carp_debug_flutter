import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'env_entry.dart';

/// Runtime override layer for compile-time launch arguments (`--dart-define`).
///
/// CARP apps normally read configuration such as the deployment mode or the
/// server host with `String.fromEnvironment`, which is fixed at build time.
/// [DebugEnv] lets the app read those same values through a layer that can be
/// overridden at runtime from the debug menu and persisted across restarts.
///
/// ### Usage in the host app
/// ```dart
/// // 1. Load persisted overrides before anything reads configuration.
/// await DebugEnv().initialize();
/// DebugEnv().register(const EnvEntry(
///   key: 'deployment-mode', label: 'Deployment mode',
///   type: EnvValueType.enumeration, options: ['production', 'test', 'dev'],
///   fallback: String.fromEnvironment('deployment-mode', defaultValue: 'production'),
/// ));
///
/// // 2. Read configuration through DebugEnv instead of String.fromEnvironment.
/// final mode = DebugEnv().string('deployment-mode',
///     fallback: const String.fromEnvironment('deployment-mode',
///         defaultValue: 'production'));
/// ```
///
/// Reads ([string], [boolean], [integer]) are synchronous so they can be used
/// inside constructors and other synchronous initialization code, provided
/// [initialize] has completed first.
class DebugEnv {
  DebugEnv._();
  static final DebugEnv _instance = DebugEnv._();

  /// The shared singleton instance.
  factory DebugEnv() => _instance;

  /// Prefix used for every override key stored in [SharedPreferences].
  static const String storagePrefix = 'carp_debug_env.';

  final Map<String, String> _overrides = {};
  final Map<String, EnvEntry> _entries = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Whether [initialize] has completed.
  bool get isInitialized => _initialized;

  /// Loads persisted overrides from [SharedPreferences]. Must be awaited early
  /// in `main()`, before the app reads any configuration. Safe to call twice.
  ///
  /// An existing [SharedPreferences] instance can be injected to share the
  /// store used elsewhere in the app (and in tests).
  Future<void> initialize({SharedPreferences? preferences}) async {
    if (_initialized) return;
    _prefs = preferences ?? await SharedPreferences.getInstance();
    for (final key in _prefs!.getKeys()) {
      if (key.startsWith(storagePrefix)) {
        final value = _prefs!.getString(key);
        if (value != null) {
          _overrides[key.substring(storagePrefix.length)] = value;
        }
      }
    }
    _initialized = true;
  }

  /// Registers a known launch argument so the Environment tool can render an
  /// editor for it. Re-registering the same [EnvEntry.key] replaces it.
  void register(EnvEntry entry) => _entries[entry.key] = entry;

  /// Registers several entries at once.
  void registerAll(Iterable<EnvEntry> entries) => entries.forEach(register);

  /// All registered entries, in registration order.
  List<EnvEntry> get entries => _entries.values.toList(growable: false);

  /// The effective string value for [key]: the runtime override if one exists,
  /// otherwise the registered entry's fallback, otherwise [fallback].
  String string(String key, {String fallback = ''}) =>
      _overrides[key] ?? _entries[key]?.fallback ?? fallback;

  /// The effective value for [key] parsed as a `bool` (`'true'` is true).
  bool boolean(String key, {bool fallback = false}) {
    final raw = _overrides[key] ?? _entries[key]?.fallback;
    if (raw == null || raw.isEmpty) return fallback;
    return raw.toLowerCase() == 'true' || raw == '1';
  }

  /// The effective value for [key] parsed as an `int`.
  int integer(String key, {int fallback = 0}) {
    final raw = _overrides[key] ?? _entries[key]?.fallback;
    return int.tryParse(raw ?? '') ?? fallback;
  }

  /// Whether [key] currently has a runtime override.
  bool hasOverride(String key) => _overrides.containsKey(key);

  /// The raw override value for [key], or `null` if none is set.
  String? overrideOf(String key) => _overrides[key];

  /// Sets and persists a runtime override for [key].
  Future<void> setOverride(String key, String value) async {
    _overrides[key] = value;
    await _prefs?.setString('$storagePrefix$key', value);
  }

  /// Removes the override for [key], reverting to the compile-time default.
  Future<void> clearOverride(String key) async {
    _overrides.remove(key);
    await _prefs?.remove('$storagePrefix$key');
  }

  /// Removes every override, reverting all values to their compile-time
  /// defaults.
  Future<void> clearAll() async {
    final keys = _overrides.keys.toList();
    _overrides.clear();
    for (final key in keys) {
      await _prefs?.remove('$storagePrefix$key');
    }
  }

  /// Resets the singleton. Intended for tests only.
  @visibleForTesting
  void resetForTest() {
    _overrides.clear();
    _entries.clear();
    _prefs = null;
    _initialized = false;
  }
}
