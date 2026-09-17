import 'package:get/get.dart';

import '../../api/binance.dart';
import '../../firebase/favorite_list.dart';
import '../../model/currency_stats.dart';

class CurrencyGraphController extends GetxController {
  CurrencyGraphController({FavoriteListService? favoriteListService})
    : _favoriteListService =
          favoriteListService ?? FavoriteListService.instance;

  final FavoriteListService _favoriteListService;
  final data = Rx<CurrencyGraphData?>(null);
  final topMarkets = <CurrencyTableData>[].obs;
  final favorites = <String>[].obs;
  final compareSymbols = <String>[].obs;
  final compareData = <String, CurrencyGraphData>{}.obs;
  final selectedSymbol = ''.obs;
  final topCount = 30.obs;
  final startInterval = DateTime.now().subtract(const Duration(days: 1)).obs;
  final endInterval = DateTime.now().obs;
  final candle = CurrencyGraphCandle.candles_15m.obs;
  final interval = CurrencyGraphInterval.interval_1d.obs;
  final loading = false.obs;
  final compareLoading = false.obs;
  final errorMessage = ''.obs;

  List<CurrencyTableData> get visibleMarkets =>
      topMarkets.take(topCount.value).toList();
  List<CurrencyTableData> get favoriteRows {
    final set = favorites.toSet();
    return topMarkets.where((row) => set.contains(row.symbol)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    loading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        getCurrencyTopXTable(100),
        _favoriteListService.getFavoriteList(userId: 'local'),
      ]);
      topMarkets.assignAll(results[0] as List<CurrencyTableData>);
      favorites.assignAll(results[1] as List<String>);
      _ensureSelection();
      await refreshGraph();
      if (compareSymbols.isNotEmpty) await refreshComparison();
    } catch (_) {
      errorMessage.value =
          'Unable to load Binance market data. Check your connection.';
    } finally {
      loading.value = false;
    }
  }

  void _ensureSelection() {
    if (selectedSymbol.isNotEmpty) return;
    if (favorites.isNotEmpty) {
      selectedSymbol.value = favorites.first;
    } else if (topMarkets.isNotEmpty) {
      selectedSymbol.value = topMarkets.first.symbol;
    }
  }

  Future<void> toggleFavorite(String symbol) async {
    favorites.contains(symbol)
        ? favorites.remove(symbol)
        : favorites.add(symbol);
    compareSymbols.removeWhere((item) => !favorites.contains(item));
    await _favoriteListService.writeFavoriteList(
      userId: 'local',
      favorites: favorites.toList(),
    );
    await refreshComparison();
  }

  void setTopCount(double value) => topCount.value = value.round();

  void setInterval(CurrencyGraphInterval next) {
    interval.value = next;
    if (next != CurrencyGraphInterval.custom) {
      endInterval.value = DateTime.now();
      startInterval.value = endInterval.value.subtract(next.toDuration());
      candle.value = defaultCandles[next] ?? candle.value;
    }
    _ensureCandleValid();
    refreshGraph();
    refreshComparison();
  }

  void setCustomRange(DateTime start, DateTime end) {
    interval.value = CurrencyGraphInterval.custom;
    startInterval.value = start;
    endInterval.value = end.add(const Duration(days: 1));
    _ensureCandleValid();
    refreshGraph();
    refreshComparison();
  }

  void setCandle(CurrencyGraphCandle next) {
    candle.value = next;
    refreshGraph();
    refreshComparison();
  }

  void setSymbol(String symbol) {
    selectedSymbol.value = symbol;
    refreshGraph();
  }

  Future<void> refreshGraph() async {
    if (selectedSymbol.isEmpty) return;
    loading.value = true;
    errorMessage.value = '';
    try {
      data.value = await _loadGraph(selectedSymbol.value);
    } catch (_) {
      data.value = null;
      errorMessage.value =
          'No price history was returned for ${selectedSymbol.value}.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> toggleCompare(String symbol) async {
    compareSymbols.contains(symbol)
        ? compareSymbols.remove(symbol)
        : compareSymbols.add(symbol);
    await refreshComparison();
  }

  Future<void> refreshComparison() async {
    if (compareSymbols.isEmpty) {
      compareData.clear();
      return;
    }
    compareLoading.value = true;
    try {
      final entries = await Future.wait(
        compareSymbols.map((symbol) async {
          return MapEntry(symbol, await _loadGraph(symbol));
        }),
      );
      compareData.assignAll(Map.fromEntries(entries));
    } catch (_) {
      compareData.clear();
    } finally {
      compareLoading.value = false;
    }
  }

  Future<CurrencyGraphData> _loadGraph(String symbol) => getCurrencyGraphData(
    symbol: symbol,
    startInterval: startInterval.value,
    endInterval: endInterval.value,
    candle: candle.value,
  );

  void _ensureCandleValid() {
    final range = endInterval.value.difference(startInterval.value);
    if (candle.value.toDuration() < range) return;
    candle.value = CurrencyGraphCandle.values.firstWhere(
      (option) => option.toDuration() < range,
      orElse: () => CurrencyGraphCandle.candles_1m,
    );
  }
}
