// Unit tests for the DebugEnv runtime launch-argument override layer.

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => DebugEnv().resetForTest());

  Future<void> init([Map<String, Object> seed = const {}]) async {
    SharedPreferences.setMockInitialValues(seed);
    final prefs = await SharedPreferences.getInstance();
    await DebugEnv().initialize(preferences: prefs);
  }

  test('falls back to the provided fallback when no override/entry', () async {
    await init();
    expect(DebugEnv().string('x', fallback: 'def'), 'def');
    expect(DebugEnv().hasOverride('x'), isFalse);
  });

  test(
    'registered entry fallback is used over the call-site fallback',
    () async {
      await init();
      DebugEnv().register(
        const EnvEntry(key: 'x', label: 'X', fallback: 'entry'),
      );
      expect(DebugEnv().string('x', fallback: 'call'), 'entry');
    },
  );

  test('override takes precedence and persists', () async {
    await init();
    await DebugEnv().setOverride('deployment-mode', 'test');
    expect(
      DebugEnv().string('deployment-mode', fallback: 'production'),
      'test',
    );
    expect(DebugEnv().hasOverride('deployment-mode'), isTrue);
    expect(DebugEnv().overrideOf('deployment-mode'), 'test');
  });

  test('persisted overrides are reloaded on a fresh initialize', () async {
    await init();
    await DebugEnv().setOverride('server-host', 'dev.example.org');
    // Simulate an app restart: reset the in-memory singleton, keep the store.
    DebugEnv().resetForTest();
    final prefs = await SharedPreferences.getInstance();
    await DebugEnv().initialize(preferences: prefs);
    expect(DebugEnv().string('server-host'), 'dev.example.org');
  });

  test(
    'clearOverride reverts to default, clearAll clears everything',
    () async {
      await init();
      await DebugEnv().setOverride('a', '1');
      await DebugEnv().setOverride('b', '2');
      await DebugEnv().clearOverride('a');
      expect(DebugEnv().hasOverride('a'), isFalse);
      expect(DebugEnv().hasOverride('b'), isTrue);
      await DebugEnv().clearAll();
      expect(DebugEnv().hasOverride('b'), isFalse);
    },
  );

  test('boolean and integer parsing', () async {
    await init();
    await DebugEnv().setOverride('flag', 'true');
    await DebugEnv().setOverride('n', '42');
    expect(DebugEnv().boolean('flag'), isTrue);
    expect(DebugEnv().integer('n', fallback: 0), 42);
    expect(DebugEnv().boolean('missing', fallback: true), isTrue);
    expect(DebugEnv().integer('bad', fallback: 7), 7);
  });
}
