// Integration test exercising the Pigeon native bridge end-to-end on a real
// device/emulator. Verifies that device metadata round-trips from native code.

import 'package:carp_debug_flutter/carp_debug_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native device info round-trips', (tester) async {
    final info = await NativeBridge().deviceInfo();

    expect(info, isNotNull);
    expect(info!.platform, anyOf('iOS', 'Android'));
    expect(info.packageName, isNotNull);
    expect(info.appVersion, isNotNull);
  });
}
