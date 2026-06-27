// Pigeon schema for the `carp_debug_flutter` native bridge.
//
// This file is the single source of truth for the type-safe platform-channel
// API. The Dart, Swift and Kotlin glue code is generated from it with:
//
//   fvm dart run pigeon --input pigeons/messages.dart
//
// Do NOT edit the generated files by hand — edit this schema and re-run pigeon.
//
// The native side only exposes capabilities that genuinely require platform
// code: reading device / app metadata and relaunching the process. Everything
// else in the toolkit (server switching, preference & database inspection,
// launch-argument overrides) is implemented in pure Dart.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/platform/messages.g.dart',
    dartOptions: DartOptions(),
    swiftOut:
        'ios/carp_debug_flutter/Sources/carp_debug_flutter/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_debug_flutter/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'dk.carp.carp_debug_flutter'),
    dartPackageName: 'carp_debug_flutter',
  ),
)
/// Read-only snapshot of device and application metadata, collected natively.
///
/// Surfaced by the "Device & App" tool so a tester can confirm exactly which
/// build, OS and hardware they are looking at.
class NativeDeviceInfo {
  NativeDeviceInfo({
    required this.platform,
    this.osVersion,
    this.deviceModel,
    this.deviceName,
    this.isPhysicalDevice,
    this.appName,
    this.packageName,
    this.appVersion,
    this.buildNumber,
  });

  /// `iOS` or `Android`.
  final String platform;

  /// Operating-system version string, e.g. `17.4` or `14`.
  final String? osVersion;

  /// Marketing / internal hardware model identifier.
  final String? deviceModel;

  /// User-visible device name (iOS) or product name (Android).
  final String? deviceName;

  /// `false` when running on a simulator / emulator, `true` on real hardware.
  final bool? isPhysicalDevice;

  /// Display name of the host application.
  final String? appName;

  /// Bundle identifier (iOS) / application id (Android).
  final String? packageName;

  /// Marketing version, e.g. `2.1.0`.
  final String? appVersion;

  /// Build number, e.g. `42`.
  final String? buildNumber;
}

/// Native capabilities invoked from Dart.
@HostApi()
abstract class CarpDebugHostApi {
  /// Collects [NativeDeviceInfo] from the platform.
  NativeDeviceInfo getDeviceInfo();

  /// Relaunches the host application from scratch.
  ///
  /// Returns `true` when a relaunch was initiated. Throws on platforms that do
  /// not support programmatic relaunch (notably iOS, where the toolkit falls
  /// back to an in-process Dart restart).
  bool restartApp();
}
