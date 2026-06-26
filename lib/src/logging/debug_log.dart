import 'package:flutter/foundation.dart';

/// Severity of a captured [DebugLogEntry].
enum DebugLogLevel {
  /// Verbose diagnostic output.
  debug,

  /// Informational message.
  info,

  /// A recoverable problem.
  warning,

  /// An error or uncaught exception.
  error,
}

/// A single captured log line.
@immutable
class DebugLogEntry {
  /// Creates a log entry stamped at [time].
  const DebugLogEntry(this.time, this.level, this.message, [this.stackTrace]);

  /// When the entry was recorded.
  final DateTime time;

  /// Severity of the entry.
  final DebugLogLevel level;

  /// The log message.
  final String message;

  /// Optional stack trace (for errors).
  final String? stackTrace;
}

/// An in-memory ring buffer that captures `debugPrint` output, framework
/// errors and uncaught async errors so they can be reviewed in the "Logs" tool
/// — even after a screen has crashed.
///
/// Call [attach] once during app start to begin capturing. Capture is
/// non-destructive: the previously installed handlers are always invoked, so
/// normal console logging and crash reporting keep working.
class DebugLog extends ChangeNotifier {
  DebugLog._();

  /// The shared singleton instance.
  static final DebugLog instance = DebugLog._();

  final List<DebugLogEntry> _entries = [];
  bool _attached = false;

  /// Maximum number of entries retained; oldest are dropped past this.
  int maxEntries = 1000;

  /// The captured entries, newest last.
  List<DebugLogEntry> get entries => List.unmodifiable(_entries);

  /// Records a log [message] at [level].
  void log(
    String message, {
    DebugLogLevel level = DebugLogLevel.debug,
    StackTrace? stackTrace,
  }) {
    _entries.add(
      DebugLogEntry(DateTime.now(), level, message, stackTrace?.toString()),
    );
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    notifyListeners();
  }

  /// Clears all captured entries.
  void clear() {
    _entries.clear();
    notifyListeners();
  }

  /// Installs capture hooks for `debugPrint`, [FlutterError.onError] and
  /// [PlatformDispatcher.onError]. Idempotent.
  void attach() {
    if (_attached) return;
    _attached = true;

    final previousDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) log(message, level: DebugLogLevel.info);
      previousDebugPrint(message, wrapWidth: wrapWidth);
    };

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      log(
        details.exceptionAsString(),
        level: DebugLogLevel.error,
        stackTrace: details.stack,
      );
      previousOnError?.call(details);
    };

    final previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      log('$error', level: DebugLogLevel.error, stackTrace: stack);
      return previousPlatformOnError?.call(error, stack) ?? false;
    };
  }
}
