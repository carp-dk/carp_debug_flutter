// Tests for the log capture buffer: ANSI stripping, CAMS level inference, and
// notification coalescing / boundedness under a fast burst.

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DebugLog.instance.clear();
    DebugLog.instance.maxEntries = 1000;
  });

  test('strips ANSI colour codes and infers CAMS level', () {
    DebugLog.instance.log('\x1B[32m[CAMS INFO]\x1B[0m server configured');
    final entry = DebugLog.instance.entries.last;
    expect(entry.message, '[CAMS INFO] server configured');
    expect(entry.message.contains('\x1B'), isFalse);
    expect(entry.level, DebugLogLevel.info);
  });

  test('CAMS warning/error markers map to levels', () {
    DebugLog.instance.log('\x1B[33m[CAMS WARNING]\x1B[0m heads up');
    DebugLog.instance.log('[CAMS ERROR] boom');
    final entries = DebugLog.instance.entries;
    expect(entries[entries.length - 2].level, DebugLogLevel.warning);
    expect(entries.last.level, DebugLogLevel.error);
  });

  test('coalesces a synchronous burst into one notification', () async {
    var calls = 0;
    void listener() => calls++;
    DebugLog.instance.addListener(listener);
    for (var i = 0; i < 200; i++) {
      DebugLog.instance.log('line $i');
    }
    expect(calls, 0, reason: 'notification is deferred to a microtask');
    await Future<void>.delayed(Duration.zero); // drain microtasks
    expect(calls, 1, reason: '200 logs -> a single rebuild');
    DebugLog.instance.removeListener(listener);
  });

  test('buffer stays bounded under a large burst', () {
    DebugLog.instance.maxEntries = 500;
    for (var i = 0; i < 10000; i++) {
      DebugLog.instance.log('x$i');
    }
    expect(DebugLog.instance.entries.length, lessThanOrEqualTo(500 + 256));
    // Newest entries are retained.
    expect(DebugLog.instance.entries.last.message, 'x9999');
  });
}
