import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/instrument_model.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';

class InstrumentSelectorField extends StatelessWidget {
  const InstrumentSelectorField({
    super.key,
    required this.value,
    required this.instruments,
    required this.labelText,
    required this.requiredValidationMessage,
    required this.searchActionLabel,
    required this.createActionLabel,
    required this.onChanged,
    required this.onPick,
    required this.onCreate,
    this.pickButtonKey,
    this.createButtonKey,
  });

  final String? value;
  final List<InstrumentModel> instruments;
  final String labelText;
  final String requiredValidationMessage;
  final String searchActionLabel;
  final String createActionLabel;
  final ValueChanged<String?> onChanged;
  final VoidCallback onPick;
  final VoidCallback onCreate;
  final Key? pickButtonKey;
  final Key? createButtonKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          items: instruments
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: Text(item.symbol),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          validator: (selected) {
            if (selected == null || selected.trim().isEmpty) {
              return requiredValidationMessage;
            }
            return null;
          },
          decoration: InputDecoration(labelText: labelText),
        ),
        const SizedBox(height: TradingUiSpacing.xs),
        Row(
          children: [
            TextButton.icon(
              key: pickButtonKey,
              onPressed: onPick,
              icon: const Icon(Icons.search),
              label: Text(searchActionLabel),
            ),
            const SizedBox(width: TradingUiSpacing.xs),
            TextButton.icon(
              key: createButtonKey,
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(createActionLabel),
            ),
          ],
        ),
      ],
    );
  }
}
