import 'package:flutter/material.dart';

import '../config/debug_env.dart';
import '../config/debug_toolkit_config.dart';
import '../controller/debug_controller.dart';
import '../logging/debug_log.dart';
import '../platform/native_bridge.dart';
import '../tools/built_in_tools.dart';
import 'app_restarter.dart';
import 'debug_surface.dart';

/// Wraps the host application and overlays the debug toolkit on top of it.
///
/// Place it at the very root, wrapping the app's root widget:
/// ```dart
/// runApp(CarpDebugToolkit(
///   enabled: kDebugMode,
///   config: DebugToolkitConfig(...),
///   child: const MyApp(),
/// ));
/// ```
///
/// Because the toolkit lives in an overlay layered above the host app (and
/// renders in its own scope), the floating button and debug menu keep working
/// even when a host screen throws or the app's navigation is broken. When
/// [enabled] is `false` (e.g. release builds) the child is returned untouched
/// with zero overhead.
class CarpDebugToolkit extends StatefulWidget {
  /// Creates the toolkit wrapper around [child].
  const CarpDebugToolkit({
    super.key,
    required this.child,
    this.config = const DebugToolkitConfig(),
    this.enabled = true,
    this.bridge,
  });

  /// The host application's root widget.
  final Widget child;

  /// Declares the tools, data sources and launch arguments to expose.
  final DebugToolkitConfig config;

  /// Whether the toolkit is active. Set to `false` in release builds.
  final bool enabled;

  /// Optional injected native bridge (primarily for testing).
  final NativeBridge? bridge;

  @override
  State<CarpDebugToolkit> createState() => _CarpDebugToolkitState();
}

class _CarpDebugToolkitState extends State<CarpDebugToolkit> {
  final GlobalKey<DebugAppRestarterState> _restarterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) return;
    final bridge = widget.bridge ?? NativeBridge();
    DebugEnv().registerAll(widget.config.envEntries);
    if (widget.config.captureLogs) DebugLog.instance.attach();
    DebugController.instance.attach(
      config: widget.config,
      tools: buildDefaultTools(widget.config, bridge),
      bridge: bridge,
      restarterKey: _restarterKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return DebugAppRestarter(
      key: _restarterKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          textDirection: TextDirection.ltr,
          children: [
            widget.child,
            const Positioned.fill(child: DebugSurface()),
          ],
        ),
      ),
    );
  }
}
