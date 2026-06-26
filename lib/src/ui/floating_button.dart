import 'package:flutter/material.dart';

import '../controller/debug_controller.dart';
import 'debug_theme.dart';

/// The draggable, always-on-top button that opens the debug menu.
///
/// It floats above the entire app inside the toolkit overlay, so it remains
/// reachable regardless of which screen (or error screen) the host app is
/// showing. The user can drag it anywhere on screen; the position is remembered
/// for the session via [DebugController.setButtonPosition].
class DebugFloatingButton extends StatefulWidget {
  /// Creates the floating button.
  const DebugFloatingButton({super.key});

  @override
  State<DebugFloatingButton> createState() => _DebugFloatingButtonState();
}

class _DebugFloatingButtonState extends State<DebugFloatingButton> {
  static const double _size = 52;
  static const double _margin = 8;
  Offset? _position;

  Offset _clamp(Offset value, Size screen, EdgeInsets pad) {
    final maxX = screen.width - _size - _margin;
    final maxY = screen.height - _size - pad.bottom - _margin;
    final minY = pad.top + _margin;
    return Offset(
      value.dx.clamp(_margin, maxX < _margin ? _margin : maxX),
      value.dy.clamp(minY, maxY < minY ? minY : maxY),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screen = media.size;
    final pad = media.padding;
    final fallback = Offset(
      screen.width - _size - _margin,
      screen.height - _size - pad.bottom - 96,
    );
    final position = _clamp(
      _position ?? DebugController.instance.buttonPosition ?? fallback,
      screen,
      pad,
    );

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: DebugController.instance.open,
        // Accumulate from the latest `_position` (not the stale build-time
        // `position`) so rapid drag events before a rebuild are not lost.
        onPanUpdate: (details) => setState(() {
          final current = _position ?? position;
          _position = _clamp(current + details.delta, screen, pad);
        }),
        onPanEnd: (_) =>
            DebugController.instance.setButtonPosition(_position ?? position),
        child: Material(
          color: DebugTheme.accent,
          elevation: 6,
          shape: const CircleBorder(),
          child: const SizedBox(
            width: _size,
            height: _size,
            child: Icon(Icons.bug_report, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
