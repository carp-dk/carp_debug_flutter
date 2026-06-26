import 'package:flutter/material.dart';

import '../../platform/messages.g.dart';
import '../../platform/native_bridge.dart';
import '../../ui/widgets/debug_scaffold.dart';

/// Page that displays native device/app metadata plus Flutter-side rendering
/// metrics. Native info is loaded asynchronously via the [NativeBridge].
class DevicePage extends StatefulWidget {
  /// Creates the device info page.
  const DevicePage({super.key, required this.bridge});

  /// Bridge used to query native device info.
  final NativeBridge bridge;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  NativeDeviceInfo? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await widget.bridge.deviceInfo();
    if (!mounted) return;
    setState(() {
      _info = info;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      title: 'Device & App',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: _load,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(children: _rows(context)),
    );
  }

  List<Widget> _rows(BuildContext context) {
    final media = MediaQuery.of(context);
    final info = _info;
    return [
      const _SectionHeader('Application'),
      _Row('Name', info?.appName),
      _Row('Package', info?.packageName),
      _Row('Version', info?.appVersion),
      _Row('Build', info?.buildNumber),
      const _SectionHeader('Device'),
      _Row('Platform', info?.platform),
      _Row('OS version', info?.osVersion),
      _Row('Model', info?.deviceModel),
      _Row('Device name', info?.deviceName),
      _Row('Physical device', info?.isPhysicalDevice?.toString()),
      const _SectionHeader('Display'),
      _Row('Screen size', '${media.size.width} x ${media.size.height}'),
      _Row('Pixel ratio', media.devicePixelRatio.toString()),
      _Row('Text scale', media.textScaler.scale(1).toStringAsFixed(2)),
      _Row('Brightness', media.platformBrightness.name),
    ];
  }
}

/// A bold section divider within the info list.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}

/// A label/value row; shows a muted dash when the value is unavailable.
class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    title: Text(label),
    trailing: Text(
      value ?? '—',
      style: const TextStyle(
        color: Colors.white70,
        fontFamily: 'monospace',
        fontSize: 12,
      ),
    ),
  );
}
