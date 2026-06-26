import 'package:flutter/material.dart';

import '../controller/debug_controller.dart';
import 'debug_home_page.dart';
import 'debug_scope.dart';
import 'floating_button.dart';

/// The interactive layer of the toolkit overlay.
///
/// Rebuilds itself whenever the [DebugController] toggles open/closed and shows
/// either the draggable floating button (closed) or the full debug panel
/// (open). Everything is wrapped in a [DebugScope] so it renders with its own
/// theme and localization, independent of the host app.
class DebugSurface extends StatelessWidget {
  /// Creates the debug surface.
  const DebugSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugScope(
      child: AnimatedBuilder(
        animation: DebugController.instance,
        builder: (context, _) {
          final isOpen = DebugController.instance.isOpen;
          return Stack(
            children: [
              if (isOpen) const Positioned.fill(child: _DebugPanel()),
              if (!isOpen) const DebugFloatingButton(),
            ],
          );
        },
      ),
    );
  }
}

/// Hosts the toolkit's own [Navigator], rooted at [DebugHomePage].
///
/// Using a dedicated navigator means tool pages are pushed and popped entirely
/// within the toolkit, never touching the host app's router — so the menu works
/// even if the app's navigation is broken.
class _DebugPanel extends StatelessWidget {
  const _DebugPanel();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (context) => const DebugHomePage(),
      ),
    );
  }
}
