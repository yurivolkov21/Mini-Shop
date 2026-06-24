// Basic smoke test for MiniShop.
//
// The full app pumps AuthGate -> Firebase / SharedPreferences, which need
// platform channels not available in a plain widget test. So here we only
// assert the root widget is constructable. Real auth flow is verified on device.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mini_shop/main.dart';

void main() {
  test('MiniShopApp is a Widget', () {
    expect(const MiniShopApp(), isA<Widget>());
  });
}
