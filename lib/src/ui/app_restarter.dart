import 'package:flutter/widgets.dart';

/// Wraps the host application so its entire widget subtree can be rebuilt from
/// scratch ("Phoenix"-style restart).
///
/// This is the cross-platform fallback used when a true native process restart
/// is unavailable (notably on iOS). Re-keying the subtree disposes and
/// recreates every widget below it, which — combined with re-reading
/// `DebugEnv` overrides — applies a newly selected server/configuration.
class DebugAppRestarter extends StatefulWidget {
  /// Wraps [child] (typically the host app's root widget).
  const DebugAppRestarter({super.key, required this.child});

  /// The subtree to rebuild on restart.
  final Widget child;

  @override
  State<DebugAppRestarter> createState() => DebugAppRestarterState();
}

/// State for [DebugAppRestarter]; exposes [restart].
class DebugAppRestarterState extends State<DebugAppRestarter> {
  Key _key = UniqueKey();

  /// Rebuilds the wrapped subtree from scratch.
  void restart() => setState(() => _key = UniqueKey());

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}
