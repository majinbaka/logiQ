import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:trading_journal/features/trades/domain/trade_entry.dart';

class TradeJournalManager extends ChangeNotifier {
  final List<TradeEntry> _entries = <TradeEntry>[];
  int _idSeed = 0;

  UnmodifiableListView<TradeEntry> get entries =>
      UnmodifiableListView(_entries);

  TradeEntry addTrade({
    required String symbol,
    required TradeSide side,
    required TradeStatus status,
    required DateTime tradeDate,
    required int quantity,
    required double entryPrice,
    required double? stopLoss,
    required double? targetPrice,
    required double fee,
    required double riskPercent,
    required TradeTimeFrame timeFrame,
    required String strategy,
    required String reason,
    required String marketContext,
    required String triggerCondition,
    required String managementPlan,
    required String emotion,
    required double confidence,
    required List<String> tags,
    required Set<TradeChecklistItem> checklist,
    String? notes,
  }) {
    final String normalizedSymbol = symbol.trim().toUpperCase();
    final String trimmedStrategy = strategy.trim();
    final String trimmedReason = reason.trim();
    final String trimmedMarketContext = marketContext.trim();
    final String trimmedTrigger = triggerCondition.trim();
    final String trimmedManagementPlan = managementPlan.trim();
    final String trimmedEmotion = emotion.trim();
    final String? trimmedNotes = notes?.trim();

    _validateSymbol(normalizedSymbol);
    _validatePositiveInt(quantity, label: 'Khối lượng');
    _validatePositiveMoney(entryPrice, label: 'Giá vào lệnh');
    _validateOptionalPositiveMoney(stopLoss, label: 'Giá cắt lỗ');
    _validateOptionalPositiveMoney(targetPrice, label: 'Giá chốt lời');
    _validateNonNegativeMoney(fee, label: 'Phí và thuế');
    _validateRiskPercent(riskPercent);
    _validateConfidence(confidence);
    _validateRequiredText(trimmedStrategy, label: 'Chiến thuật');
    _validateRequiredText(trimmedReason, label: 'Lý do vào/thoát lệnh');

    final TradeEntry entry = TradeEntry(
      id: _nextId(),
      symbol: normalizedSymbol,
      side: side,
      status: status,
      tradeDate: tradeDate,
      quantity: quantity,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      targetPrice: targetPrice,
      fee: fee,
      riskPercent: riskPercent,
      timeFrame: timeFrame,
      strategy: trimmedStrategy,
      reason: trimmedReason,
      marketContext: trimmedMarketContext,
      triggerCondition: trimmedTrigger,
      managementPlan: trimmedManagementPlan,
      emotion: trimmedEmotion,
      confidence: confidence,
      tags: List<String>.unmodifiable(_normalizeTags(tags)),
      checklist: Set<TradeChecklistItem>.unmodifiable(checklist),
      notes: trimmedNotes == null || trimmedNotes.isEmpty ? null : trimmedNotes,
      createdAt: DateTime.now(),
    );

    _entries.insert(0, entry);
    notifyListeners();
    return entry;
  }

  void deleteTrade(String entryId) {
    final int removedCount = _entries.length;
    _entries.removeWhere((entry) => entry.id == entryId);
    if (_entries.length != removedCount) {
      notifyListeners();
    }
  }

  String _nextId() {
    _idSeed += 1;
    return 'trade_$_idSeed';
  }

  List<String> _normalizeTags(List<String> rawTags) {
    final Set<String> seen = <String>{};
    final List<String> tags = <String>[];

    for (final String rawTag in rawTags) {
      final String tag = rawTag.trim();
      if (tag.isEmpty || seen.contains(tag.toLowerCase())) {
        continue;
      }
      seen.add(tag.toLowerCase());
      tags.add(tag);
    }

    return tags;
  }

  void _validateSymbol(String symbol) {
    if (symbol.isEmpty) {
      throw ArgumentError('Mã chứng khoán không được để trống.');
    }
    if (!RegExp(r'^[A-Z0-9.]{1,12}$').hasMatch(symbol)) {
      throw ArgumentError('Mã chứng khoán chỉ gồm chữ cái, số hoặc dấu chấm.');
    }
  }

  void _validateRequiredText(String value, {required String label}) {
    if (value.isEmpty) {
      throw ArgumentError('$label không được để trống.');
    }
  }

  void _validatePositiveInt(int value, {required String label}) {
    if (value <= 0) {
      throw ArgumentError('$label phải lớn hơn 0.');
    }
  }

  void _validatePositiveMoney(double value, {required String label}) {
    if (value.isNaN || value.isInfinite || value <= 0) {
      throw ArgumentError('$label phải lớn hơn 0.');
    }
  }

  void _validateOptionalPositiveMoney(double? value, {required String label}) {
    if (value == null) {
      return;
    }
    _validatePositiveMoney(value, label: label);
  }

  void _validateNonNegativeMoney(double value, {required String label}) {
    if (value.isNaN || value.isInfinite || value < 0) {
      throw ArgumentError('$label phải là số không âm.');
    }
  }

  void _validateRiskPercent(double value) {
    if (value.isNaN || value.isInfinite || value < 0 || value > 100) {
      throw ArgumentError('Rủi ro vốn phải nằm trong khoảng 0-100%.');
    }
  }

  void _validateConfidence(double value) {
    if (value.isNaN || value.isInfinite || value < 0 || value > 5) {
      throw ArgumentError('Điểm tự tin phải nằm trong khoảng 0-5.');
    }
  }
}
