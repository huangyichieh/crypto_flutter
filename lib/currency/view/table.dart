import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chart.dart';
import '../model/currency_stats.dart';
import '../controller/currency_graph_controller.dart';

class CurrencyMarketTable extends StatelessWidget {
  const CurrencyMarketTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrencyGraphController>();
    return Obx(() {
      if (controller.loading.value && controller.topMarkets.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Text('Favorites', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (controller.favoriteRows.isEmpty)
            const Text('Tap a star in the market list to add favorites.')
          else
            _MarketRows(rows: controller.favoriteRows, controller: controller),
          const SizedBox(height: 22),
          Text('Top markets', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: 10,
                  max: 100,
                  divisions: 90,
                  value: controller.topCount.value.toDouble(),
                  label: '${controller.topCount.value}',
                  onChanged: controller.setTopCount,
                ),
              ),
              SizedBox(width: 44, child: Text('${controller.topCount.value}')),
            ],
          ),
          _MarketRows(rows: controller.visibleMarkets, controller: controller),
        ],
      );
    });
  }
}

class _MarketRows extends StatelessWidget {
  const _MarketRows({required this.rows, required this.controller});
  final List<CurrencyTableData> rows;
  final CurrencyGraphController controller;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 420),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    ),
    child: SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('?')),
            DataColumn(label: Text('Symbol')),
            DataColumn(label: Text('Last Price'), numeric: true),
            DataColumn(label: Text('24h %'), numeric: true),
            DataColumn(label: Text('Quote Vol'), numeric: true),
          ],
          rows: rows.map((row) {
            final favorite = controller.favorites.contains(row.symbol);
            final positive = row.percentage24h >= 0;
            return DataRow(
              onSelectChanged: (_) => controller.setSymbol(row.symbol),
              cells: [
                DataCell(
                  IconButton(
                    icon: Icon(
                      favorite ? Icons.star : Icons.star_border,
                      color: favorite ? Colors.amber : null,
                    ),
                    onPressed: () => controller.toggleFavorite(row.symbol),
                  ),
                ),
                DataCell(Text(row.name)),
                DataCell(Text(_price(row.lastPrice))),
                DataCell(
                  Text(
                    '${row.percentage24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: positive ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ),
                DataCell(Text(_compact(row.quoteVolume))),
              ],
            );
          }).toList(),
        ),
      ),
    ),
  );
}

class CurrencyCompareView extends StatelessWidget {
  const CurrencyCompareView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrencyGraphController>();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.favorites.isEmpty)
            const Text(
              'Add favorite markets above to compare their normalized performance.',
            )
          else
            Wrap(
              spacing: 8,
              children: controller.favorites
                  .map(
                    (symbol) => FilterChip(
                      label: Text(symbol.replaceAll('USDT', '')),
                      selected: controller.compareSymbols.contains(symbol),
                      onSelected: (_) => controller.toggleCompare(symbol),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 16),
          if (controller.compareLoading.value)
            const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.compareData.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(child: Text('Select favorites to compare')),
            )
          else
            MultiSeriesGraph(data: controller.compareData, height: 320),
        ],
      ),
    );
  }
}

String _price(double value) =>
    value >= 1 ? value.toStringAsFixed(4) : value.toStringAsPrecision(6);
String _compact(double value) {
  if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(2)}B';
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(2)}K';
  return value.toStringAsFixed(0);
}
