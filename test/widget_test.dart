import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_journal/main.dart';

void main() {
  testWidgets('renders account management screen and creates account', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Quản lý tài khoản tiền'), findsOneWidget);
    expect(find.text('Tài khoản chứng khoán'), findsOneWidget);

    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Ví chính');
    await tester.enterText(find.byType(TextFormField).at(1), '1000');
    await tester.tap(find.text('Tạo'));
    await tester.pumpAndSettle();

    expect(find.text('Ví chính'), findsOneWidget);
    expect(find.text('1.000 đ'), findsWidgets);
  });
}
