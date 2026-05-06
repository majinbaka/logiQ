import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/core/validation/validators.dart';

void main() {
  test('throws on invalid percent and score ranges', () {
    expect(
      () => DataValidator.requirePercentRange(110, 'pnl'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => DataValidator.requireScoreRange(-1, 'score'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('throws when start date is after end date', () {
    expect(
      () => DataValidator.requireDateOrder(
        DateTime(2026, 5, 2),
        DateTime(2026, 5, 1),
        'start',
        'end',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
