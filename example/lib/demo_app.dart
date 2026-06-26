import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter/material.dart';

import 'demo_data.dart';

/// Notifies the home page to re-read the effective launch-argument values when
/// the user applies a change from the Environment tool.
class DemoConfigNotifier extends ChangeNotifier {
  /// Triggers a rebuild of any listening widgets.
  void reload() => notifyListeners();
}

/// Global notifier wired to the toolkit's `onApply` / `onReinitialize` hooks.
final demoConfig = DemoConfigNotifier();

/// The example host application.
class DemoApp extends StatelessWidget {
  /// Creates the demo app.
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Toolkit Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DemoHomePage(),
    );
  }
}

/// Home page that shows the current effective configuration so the effect of
/// switching servers / overriding launch arguments is visible immediately.
class DemoHomePage extends StatelessWidget {
  /// Creates the demo home page.
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CARP Debug Toolkit')),
      body: AnimatedBuilder(
        animation: demoConfig,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Tap the floating bug button → "Environment & Servers" to change '
              'these values, then press Apply (live) or Restart.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            for (final entry in demoEnvEntries)
              Card(
                child: ListTile(
                  dense: true,
                  title: Text(entry.label),
                  trailing: Text(
                    DebugEnv().string(entry.key, fallback: entry.fallback),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.warning_amber),
              label: const Text('Trigger uncaught error'),
              onPressed: () => throw StateError('Demo error from the host app'),
            ),
            const SizedBox(height: 8),
            const Text(
              'The toolkit stays usable after the error above — proving it is '
              'independent of the app UI.',
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
