import 'package:flutter_test/flutter_test.dart';
import 'package:trading_diary/app/app.dart';

void main() {
  testWidgets('app shell switches between feature overview screens', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Trading Journal'), findsOneWidget);
    expect(find.text('Capture and review your executed trades.'), findsOneWidget);

    await tester.tap(find.text('Portfolio').last);
    await tester.pumpAndSettle();
    expect(find.text('Portfolio Overview'), findsOneWidget);

    await tester.tap(find.text('Strategy').last);
    await tester.pumpAndSettle();
    expect(find.text('Strategy and Risk'), findsOneWidget);

    await tester.tap(find.text('Journal').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily Journal'), findsOneWidget);

    await tester.tap(find.text('Psychology').last);
    await tester.pumpAndSettle();
    expect(find.text('Trading Psychology'), findsOneWidget);

    await tester.tap(find.text('Insights').last);
    await tester.pumpAndSettle();
    expect(find.text('Analytics and Insights'), findsOneWidget);
  });
}
