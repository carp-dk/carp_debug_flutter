import 'package:flutter/widgets.dart';

import '../config/debug_toolkit_config.dart';
import '../model/debug_tool.dart';
import '../platform/native_bridge.dart';
import '../ui/app_restarter.dart';

/// Holds the live state of the debug toolkit: whether the menu is open, the
/// resolved list of tools, the floating-button position and shared services.
///
/// A single shared instance ([DebugController.instance]) is used so the
/// floating button, the panel and the tools all observe the same state. It is
/// a [ChangeNotifier] so the overlay rebuilds when the menu opens or closes.
class DebugController extends ChangeNotifier {
  DebugController._();

  /// The shared singleton instance.
  static final DebugController instance = DebugController._();

  DebugToolkitConfig _config = const DebugToolkitConfig();
  List<DebugTool> _tools = const [];
  NativeBridge _bridge = NativeBridge();
  GlobalKey<DebugAppRestarterState>? _restarterKey;
  bool _open = false;
  Offset? _buttonPosition;

  /// The active toolkit configuration.
  DebugToolkitConfig get config => _config;

  /// The resolved list of tools shown in the menu.
  List<DebugTool> get tools => _tools;

  /// The native bridge used for device info and process relaunch.
  NativeBridge get bridge => _bridge;

  /// Key to the [DebugAppRestarter] used for in-process restarts (iOS path).
  GlobalKey<DebugAppRestarterState>? get restarterKey => _restarterKey;

  /// Whether the debug menu is currently open.
  bool get isOpen => _open;

  /// Last persisted floating-button position (within the current frame), or
  /// `null` to use the default bottom-right placement.
  Offset? get buttonPosition => _buttonPosition;

  /// Wires the controller to the toolkit's configuration and services. Called
  /// by `CarpDebugToolkit` during initialization.
  void attach({
    required DebugToolkitConfig config,
    required List<DebugTool> tools,
    required NativeBridge bridge,
    required GlobalKey<DebugAppRestarterState> restarterKey,
  }) {
    _config = config;
    _tools = tools;
    _bridge = bridge;
    _restarterKey = restarterKey;
  }

  /// Remembers where the user dragged the floating button to.
  void setButtonPosition(Offset position) => _buttonPosition = position;

  /// Opens the debug menu.
  void open() {
    if (_open) return;
    _open = true;
    notifyListeners();
  }

  /// Closes the debug menu.
  void close() {
    if (!_open) return;
    _open = false;
    notifyListeners();
  }

  /// Toggles the debug menu open/closed.
  void toggle() => _open ? close() : open();
}
