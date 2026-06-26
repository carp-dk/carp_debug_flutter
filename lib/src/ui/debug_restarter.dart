import 'package:flutter/widgets.dart';

import '../controller/debug_controller.dart';

/// Restarts the host application to apply configuration changes.
///
/// Strategy:
///  1. Attempt a true native process relaunch (works on Android).
///  2. If that is unavailable (iOS), run the app-provided
///     [DebugToolkitConfig.onReinitialize] hook and rebuild the widget tree
///     in-process via [DebugAppRestarter].
abstract final class DebugRestarter {
  /// Performs the restart, choosing the best available strategy.
  static Future<void> restart(BuildContext context) async {
    final controller = DebugController.instance;

    final relaunched = await controller.bridge.restartApp();
    if (relaunched) return; // process is being torn down and relaunched

    await controller.config.onReinitialize?.call();
    controller.close();
    controller.restarterKey?.currentState?.restart();
  }
}
