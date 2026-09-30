import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../model/currency_stats.dart';

const _baseUrl = 'https://api.binance.com';

Future<CurrencyGraphData> getCurrencyGraphData({
  required String symbol,
  required DateTime startInterval,
  required DateTime endInterval,
  required CurrencyGraphCandle candle,
}) async {
  if (endInterval.isBefore(startInterval)) {
    throw ArgumentError('endInterval must be after startInterval');
  }
  final candleDuration = candle.toDuration();
  final diffMs = endInterval.difference(startInterval).inMilliseconds;
  final candleMs = candleDuration.inMilliseconds;
  if (candleMs <= 0) {
    throw ArgumentError('candle duration must be positive');
  }
  var effectiveEnd = endInterval;
  final remainder = diffMs % candleMs;
  if (remainder != 0) {
    effectiveEnd = endInterval.subtract(Duration(milliseconds: remainder));
  }
  if (!effectiveEnd.isAfter(startInterval)) {
    effectiveEnd = startInterval.add(candleDuration);
  }
  final limit = min(
    1000,
    max(
      1,
      ((effectiveEnd.difference(startInterval).inMilliseconds) / candleMs)
          .ceil(),
    ),
  );
  final uri = Uri.parse('$_baseUrl/api/v3/klines').replace(
    queryParameters: {
      'symbol': symbol,
      'interval': candle.binanceInterval(),
      'startTime': startInterval.millisecondsSinceEpoch.toString(),
      'endTime': effectiveEnd.millisecondsSinceEpoch.toString(),
      'limit': limit.toString(),
    },
  );
  final resp = await http.get(uri);
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch klines: ${resp.statusCode}');
  }
  final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
  final date = <DateTime>[];
  final currency = <double>[];
  for (final row in raw) {
    if (row is List && row.length >= 5) {
      final openTime = row[0];
      final close = row[4];
      if (openTime is int || openTime is num) {
        date.add(
          DateTime.fromMillisecondsSinceEpoch(
            (openTime as num).toInt(),
            isUtc: true,
          ),
        );
      }
      if (close is String) {
        currency.add(double.tryParse(close) ?? 0);
      } else if (close is num) {
        currency.add(close.toDouble());
      }
    }
  }
  return CurrencyGraphData(candle: candle, date: date, currency: currency);
}

Future<List<CurrencyTableData>> getCurrencyTopXTable([int x = 100]) async {
  if (x <= 0) {
    throw ArgumentError('x must be greater than 0');
  }
  final uri = Uri.parse('$_baseUrl/api/v3/ticker/24hr');
  final resp = await http.get(uri);
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch ticker data: ${resp.statusCode}');
  }
  final List<dynamic> raw = jsonDecode(resp.body) as List<dynamic>;
  final rows = <CurrencyTableData>[];
  for (final row in raw) {
    if (row is Map<String, dynamic>) {
      final symbol = row['symbol'] as String?;
      if (symbol == null || !symbol.endsWith('USDT')) {
        continue;
      }
      final lastPrice =
          double.tryParse(row['lastPrice']?.toString() ?? '') ?? 0;
      final percent24h =
          double.tryParse(row['priceChangePercent']?.toString() ?? '') ?? 0;
      final quoteVolume =
          double.tryParse(row['quoteVolume']?.toString() ?? '') ?? 0;
      rows.add(
        CurrencyTableData(
          symbol: symbol,
          name: symbol.replaceAll('USDT', ''),
          lastPrice: lastPrice,
          percentage24h: percent24h,
          quoteVolume: quoteVolume,
        ),
      );
    }
  }
  rows.sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));
  if (x >= rows.length) {
    return rows;
  }
  return rows.sublist(0, x);
}
