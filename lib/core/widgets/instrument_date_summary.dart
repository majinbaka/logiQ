import 'package:flutter/material.dart';

class InstrumentDateSummary extends StatelessWidget {
  const InstrumentDateSummary({
    super.key,
    required this.instrumentValue,
    required this.dateValue,
    this.instrumentLabel,
    this.dateLabel,
    this.textStyle,
  });

  final String instrumentValue;
  final String dateValue;
  final String? instrumentLabel;
  final String? dateLabel;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.bodyMedium;
    final instrumentText = (instrumentValue).trim().isEmpty
        ? '-'
        : instrumentValue.trim();
    final dateText = (dateValue).trim().isEmpty ? '-' : dateValue.trim();
    final instrumentPrefix = instrumentLabel == null ? '' : '$instrumentLabel: ';
    final datePrefix = dateLabel == null ? '' : '$dateLabel: ';
    return Text(
      '$instrumentPrefix$instrumentText • $datePrefix$dateText',
      style: style,
    );
  }
}
