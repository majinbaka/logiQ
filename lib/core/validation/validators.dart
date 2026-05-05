class DataValidator {
  const DataValidator._();

  static void requireId(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
  }

  static void requireSymbol(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
  }

  static void requireDateOrder(
    DateTime? start,
    DateTime? end,
    String startField,
    String endField,
  ) {
    if (start != null && end != null && start.isAfter(end)) {
      throw ArgumentError('$startField must be before or equal to $endField');
    }
  }

  static void requirePercentRange(num? value, String field) {
    if (value == null) {
      return;
    }
    if (value < 0 || value > 100) {
      throw ArgumentError.value(value, field, 'must be in [0, 100]');
    }
  }

  static void requireScoreRange(int? value, String field) {
    if (value == null) {
      return;
    }
    if (value < 0 || value > 100) {
      throw ArgumentError.value(value, field, 'must be in [0, 100]');
    }
  }

  static void requireNonNegative(num? value, String field) {
    if (value == null) {
      return;
    }
    if (value < 0) {
      throw ArgumentError.value(value, field, 'must be non-negative');
    }
  }
}
