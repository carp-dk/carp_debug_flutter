import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';

import 'debug_theme.dart';

/// Provides the inherited widgets the toolkit's Material UI needs, completely
/// independent of the host application's `MaterialApp`.
///
/// This is what makes the toolkit usable "even when the app is crashing": the
/// debug menu renders inside its own [MediaQuery], [Theme], [Localizations] and
/// [ScaffoldMessenger] scope, so a broken or missing host `MaterialApp`/router
/// does not prevent the toolkit from working.
class DebugScope extends StatelessWidget {
  /// Wraps [child] in the toolkit's self-contained Material scope.
  const DebugScope({super.key, required this.child});

  /// The toolkit UI (floating button and/or panel).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = DebugTheme.themeData;
    return MediaQuery.fromView(
      view: View.of(context),
      child: Theme(
        data: theme,
        child: Localizations(
          locale: const Locale('en', 'US'),
          delegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: ScaffoldMessenger(
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!,
              child: IconTheme(data: theme.iconTheme, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
