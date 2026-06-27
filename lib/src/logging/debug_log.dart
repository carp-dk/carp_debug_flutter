import 'dart:async';

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

  /// The log message (ANSI colour codes already stripped).
  final String message;

  /// Optional stack trace (for errors).
  final String? stackTrace;
}

/// An in-memory ring buffer that captures `debugPrint` output, framework
/// errors and uncaught async errors so they can be reviewed in the "Logs" tool
/// — even after a screen has crashed.
///
/// Call [attach] once during app start to begin capturing. Capture is
/// non-destructive: the previously installed handlers are always invoked.
///
/// Listener notifications are **coalesced** to one per microtask so a burst of
/// log lines cannot saturate the UI thread (which previously froze/crashed the
/// app), and the buffer is trimmed in amortized batches.
class DebugLog extends ChangeNotifier {
  DebugLog._();

  /// The shared singleton instance.
  static final DebugLog instance = DebugLog._();

  // Matches ANSI/VT100 escape sequences such as `\x1B[32m` used by CAMS logging.
  static final RegExp _ansi = RegExp(r'\x1B\[[0-9;]*[A-Za-z]');
  static final RegExp _camsLevel = RegExp(
    r'\[CAMS (DEBUG|INFO|WARNING|ERROR)\]',
  );

  final List<DebugLogEntry> _entries = [];
  bool _attached = false;
  bool _notifyScheduled = false;

  /// Maximum number of entries retained; oldest are dropped past this.
  int maxEntries = 1000;

  /// The captured entries, newest last.
  List<DebugLogEntry> get entries => List.unmodifiable(_entries);

  /// Records a log [message] at [level].
  ///
  /// ANSI colour codes are stripped, and a leading `[CAMS <LEVEL>]` marker (if
  /// present) overrides [level] so CAMS output is coloured correctly.
  void log(
    String message, {
    DebugLogLevel level = DebugLogLevel.debug,
    StackTrace? stackTrace,
  }) {
    final clean = message.replaceAll(_ansi, '');
    _entries.add(
      DebugLogEntry(
        DateTime.now(),
        _levelFor(clean, level),
        clean,
        stackTrace?.toString(),
      ),
    );
    // Trim in batches so a fast burst doesn't repeatedly shift the whole list.
    if (_entries.length > maxEntries + 256) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    _scheduleNotify();
  }

  /// Clears all captured entries.
  void clear() {
    _entries.clear();
    notifyListeners();
  }

  DebugLogLevel _levelFor(String clean, DebugLogLevel fallback) {
    final match = _camsLevel.firstMatch(clean);
    return switch (match?.group(1)) {
      'ERROR' => DebugLogLevel.error,
      'WARNING' => DebugLogLevel.warning,
      'INFO' => DebugLogLevel.info,
      'DEBUG' => DebugLogLevel.debug,
      _ => fallback,
    };
  }

  /// Coalesces notifications: at most one [notifyListeners] per microtask, so a
  /// synchronous burst of log lines triggers a single rebuild, and the call
  /// never runs synchronously inside a widget build.
  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
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
