import 'package:flutter_test/flutter_test.dart';
import 'package:shop_billing_system/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const ShopBillingApp());
  });
}
