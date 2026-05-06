enum CashMovementType {
  deposit('deposit'),
  withdrawal('withdrawal'),
  dividend('dividend'),
  fee('fee'),
  tax('tax'),
  adjustment('adjustment');

  const CashMovementType(this.value);
  final String value;

  static CashMovementType? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    for (final item in CashMovementType.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }
}

enum PriceQuoteType {
  last('last'),
  close('close'),
  bid('bid'),
  ask('ask'),
  mark('mark');

  const PriceQuoteType(this.value);
  final String value;

  static PriceQuoteType? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    for (final item in PriceQuoteType.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }
}
