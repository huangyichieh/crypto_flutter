enum CurrencyGraphInterval {
  custom,
  interval_30m,
  interval_1h,
  interval_12h,
  interval_1d,
  interval_1w,
  interval_1M,
  interval_3M,
  interval_1Y,
}

enum CurrencyGraphCandle {
  candles_1m,
  candles_3m,
  candles_5m,
  candles_15m,
  candles_30m,
  candles_1h,
  candles_8h,
  candles_12h,
  candles_1d,
  candles_1w,
  candles_1M,
}

const Map<CurrencyGraphInterval, CurrencyGraphCandle> defaultCandles = {
  CurrencyGraphInterval.interval_30m: CurrencyGraphCandle.candles_1m,
  CurrencyGraphInterval.interval_1h: CurrencyGraphCandle.candles_3m,
  CurrencyGraphInterval.interval_12h: CurrencyGraphCandle.candles_5m,
  CurrencyGraphInterval.interval_1d: CurrencyGraphCandle.candles_15m,
  CurrencyGraphInterval.interval_1w: CurrencyGraphCandle.candles_1h,
  CurrencyGraphInterval.interval_1M: CurrencyGraphCandle.candles_8h,
  CurrencyGraphInterval.interval_3M: CurrencyGraphCandle.candles_12h,
  CurrencyGraphInterval.interval_1Y: CurrencyGraphCandle.candles_1d,
  CurrencyGraphInterval.custom: CurrencyGraphCandle.candles_1h,
};

class CurrencyGraphData {
  CurrencyGraphData({
    required this.candle,
    required List<DateTime> date,
    required List<double> currency,
  }) : date = List.unmodifiable(date),
       currency = List.unmodifiable(currency),
       startInterval = date.isNotEmpty
           ? date.first
           : DateTime.fromMillisecondsSinceEpoch(0),
       endInterval = date.isNotEmpty
           ? date.last
           : DateTime.fromMillisecondsSinceEpoch(0) {
    if (date.isEmpty) {
      throw ArgumentError('date must not be empty');
    }
    if (date.length != currency.length) {
      throw ArgumentError('date and currency must have the same length');
    }
    for (var i = 1; i < date.length; i++) {
      if (!date[i].isAfter(date[i - 1])) {
        throw ArgumentError('date entries must be strictly increasing');
      }
    }
  }

  final DateTime startInterval;
  final DateTime endInterval;
  final CurrencyGraphCandle candle;
  final List<DateTime> date;
  final List<double> currency;
}

class CurrencyTableData {
  const CurrencyTableData({
    required this.symbol,
    required this.name,
    required this.lastPrice,
    required this.percentage24h,
    required this.quoteVolume,
  });

  final String symbol;
  final String name;
  final double lastPrice;
  final double percentage24h;
  final double quoteVolume;
}

extension CurrencyGraphIntervalX on CurrencyGraphInterval {
  Duration toDuration() {
    switch (this) {
      case CurrencyGraphInterval.interval_30m:
        return const Duration(minutes: 30);
      case CurrencyGraphInterval.interval_1h:
        return const Duration(hours: 1);
      case CurrencyGraphInterval.interval_12h:
        return const Duration(hours: 12);
      case CurrencyGraphInterval.interval_1d:
        return const Duration(days: 1);
      case CurrencyGraphInterval.interval_1w:
        return const Duration(days: 7);
      case CurrencyGraphInterval.interval_1M:
        return const Duration(days: 30);
      case CurrencyGraphInterval.interval_3M:
        return const Duration(days: 90);
      case CurrencyGraphInterval.interval_1Y:
        return const Duration(days: 365);
      case CurrencyGraphInterval.custom:
        return const Duration(hours: 1);
    }
  }

  String label() {
    switch (this) {
      case CurrencyGraphInterval.custom:
        return 'Custom';
      case CurrencyGraphInterval.interval_30m:
        return '30m';
      case CurrencyGraphInterval.interval_1h:
        return '1h';
      case CurrencyGraphInterval.interval_12h:
        return '12h';
      case CurrencyGraphInterval.interval_1d:
        return '1d';
      case CurrencyGraphInterval.interval_1w:
        return '1w';
      case CurrencyGraphInterval.interval_1M:
        return '1M';
      case CurrencyGraphInterval.interval_3M:
        return '3M';
      case CurrencyGraphInterval.interval_1Y:
        return '1Y';
    }
  }
}

extension CurrencyGraphCandleX on CurrencyGraphCandle {
  Duration toDuration() {
    switch (this) {
      case CurrencyGraphCandle.candles_1m:
        return const Duration(minutes: 1);
      case CurrencyGraphCandle.candles_3m:
        return const Duration(minutes: 3);
      case CurrencyGraphCandle.candles_5m:
        return const Duration(minutes: 5);
      case CurrencyGraphCandle.candles_15m:
        return const Duration(minutes: 15);
      case CurrencyGraphCandle.candles_30m:
        return const Duration(minutes: 30);
      case CurrencyGraphCandle.candles_1h:
        return const Duration(hours: 1);
      case CurrencyGraphCandle.candles_8h:
        return const Duration(hours: 8);
      case CurrencyGraphCandle.candles_12h:
        return const Duration(hours: 12);
      case CurrencyGraphCandle.candles_1d:
        return const Duration(days: 1);
      case CurrencyGraphCandle.candles_1w:
        return const Duration(days: 7);
      case CurrencyGraphCandle.candles_1M:
        return const Duration(days: 30);
    }
  }

  String binanceInterval() {
    switch (this) {
      case CurrencyGraphCandle.candles_1m:
        return '1m';
      case CurrencyGraphCandle.candles_3m:
        return '3m';
      case CurrencyGraphCandle.candles_5m:
        return '5m';
      case CurrencyGraphCandle.candles_15m:
        return '15m';
      case CurrencyGraphCandle.candles_30m:
        return '30m';
      case CurrencyGraphCandle.candles_1h:
        return '1h';
      case CurrencyGraphCandle.candles_8h:
        return '8h';
      case CurrencyGraphCandle.candles_12h:
        return '12h';
      case CurrencyGraphCandle.candles_1d:
        return '1d';
      case CurrencyGraphCandle.candles_1w:
        return '1w';
      case CurrencyGraphCandle.candles_1M:
        return '1M';
    }
  }

  String label() {
    switch (this) {
      case CurrencyGraphCandle.candles_1m:
        return '1m';
      case CurrencyGraphCandle.candles_3m:
        return '3m';
      case CurrencyGraphCandle.candles_5m:
        return '5m';
      case CurrencyGraphCandle.candles_15m:
        return '15m';
      case CurrencyGraphCandle.candles_30m:
        return '30m';
      case CurrencyGraphCandle.candles_1h:
        return '1h';
      case CurrencyGraphCandle.candles_8h:
        return '8h';
      case CurrencyGraphCandle.candles_12h:
        return '12h';
      case CurrencyGraphCandle.candles_1d:
        return '1d';
      case CurrencyGraphCandle.candles_1w:
        return '1w';
      case CurrencyGraphCandle.candles_1M:
        return '1M';
    }
  }
}
