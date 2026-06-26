import 'package:flutter/foundation.dart';

import 'messages.g.dart';

/// Thin, failure-tolerant Dart wrapper around the Pigeon-generated
/// [CarpDebugHostApi].
///
/// The debug toolkit must never crash the host app, so every native call is
/// guarded: errors are swallowed (and logged in debug mode) and a safe default
/// is returned instead of propagating the exception.
class NativeBridge {
  NativeBridge({CarpDebugHostApi? api}) : _api = api ?? CarpDebugHostApi();

  final CarpDebugHostApi _api;

  /// Returns native device / app metadata, or `null` if the platform call
  /// fails (e.g. on an unsupported platform such as web or desktop).
  Future<NativeDeviceInfo?> deviceInfo() async {
    try {
      return await _api.getDeviceInfo();
    } catch (error, stack) {
      _report('getDeviceInfo', error, stack);
      return null;
    }
  }

  /// Attempts a native process relaunch.
  ///
  /// Returns `true` only when the platform actually initiated a relaunch.
  /// iOS does not support this and returns `false`, signalling the caller to
  /// fall back to an in-process Dart restart.
  Future<bool> restartApp() async {
    try {
      return await _api.restartApp();
    } catch (error, stack) {
      _report('restartApp', error, stack);
      return false;
    }
  }

  void _report(String method, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('[carp_debug_flutter] native "$method" failed: $error');
    }
  }
}
