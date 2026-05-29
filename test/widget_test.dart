import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_journal/main.dart';

void main() {
  testWidgets('renders trade journal home screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    expect(find.text('Nhật ký lệnh chứng khoán'), findsOneWidget);
    expect(find.text('Nhập thông tin lệnh'), findsOneWidget);
    expect(find.text('Tóm tắt rủi ro'), findsOneWidget);
  });
}
