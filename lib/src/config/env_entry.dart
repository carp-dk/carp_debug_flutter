import 'package:flutter/foundation.dart';

/// The kind of value a launch argument holds. Drives which editor widget the
/// Environment tool renders.
enum EnvValueType {
  /// Free-form text (e.g. a custom server host or client id).
  text,

  /// A fixed set of allowed string values, rendered as a dropdown.
  enumeration,

  /// A boolean flag, rendered as a switch (`'true'` / `'false'`).
  toggle,

  /// An integer, rendered as a numeric text field.
  integer,
}

/// Declarative description of a single overridable launch argument
/// (a `--dart-define` value) that the app normally reads via
/// `String.fromEnvironment`.
///
/// Registering an entry with [DebugEnv] lets the Environment tool render an
/// appropriate editor and show the value's current source (override vs.
/// compile-time default).
@immutable
class EnvEntry {
  /// Creates a launch-argument descriptor.
  ///
  /// [key] is the `--dart-define` name (e.g. `deployment-mode`). [fallback] is
  /// the compile-time default the app passes from `String.fromEnvironment`, so
  /// the toolkit can display it and detect when an override differs from it.
  const EnvEntry({
    required this.key,
    required this.label,
    this.fallback = '',
    this.type = EnvValueType.text,
    this.options = const [],
    this.description,
    this.group,
  });

  /// The `--dart-define` key, used both as the storage key and the lookup key.
  final String key;

  /// Human-readable label shown in the Environment tool.
  final String label;

  /// The compile-time default value (typically from `String.fromEnvironment`).
  final String fallback;

  /// How the value should be edited.
  final EnvValueType type;

  /// Allowed values when [type] is [EnvValueType.enumeration].
  final List<String> options;

  /// Optional longer explanation shown beneath the editor.
  final String? description;

  /// Optional grouping header (e.g. `Server`, `Logging`) for visual grouping.
  final String? group;
}
