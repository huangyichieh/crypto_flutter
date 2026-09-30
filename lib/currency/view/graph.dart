import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'chart.dart';
import '../model/currency_stats.dart';
import '../controller/currency_graph_controller.dart';

class CurrencyGraph extends StatelessWidget {
  CurrencyGraph({super.key});

  final CurrencyGraphController controller =
      Get.find<CurrencyGraphController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSymbolDropdown(),
          const SizedBox(height: 12),
          if (controller.loading.value && controller.data.value == null)
            const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.data.value == null)
            const SizedBox(height: 240, child: Center(child: Text('No data')))
          else
            InteractiveGraph(data: controller.data.value!),
          if (controller.data.value case final graph?) ...[
            const SizedBox(height: 12),
            _StatsRow(data: graph),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIntervalControls(context),
                    const SizedBox(height: 16),
                    _buildCandleControls(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildIntervalControls(context)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCandleControls()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolDropdown() {
    final favorites = controller.favorites.toSet();
    final favoritesRows = controller.topMarkets.where(
      (row) => favorites.contains(row.symbol),
    );
    final others = controller.topMarkets.where(
      (row) => !favorites.contains(row.symbol),
    );
    final items = [...favoritesRows, ...others];
    return DropdownButtonFormField<String>(
      initialValue: controller.selectedSymbol.value.isEmpty
          ? null
          : controller.selectedSymbol.value,
      decoration: const InputDecoration(
        labelText: 'Symbol',
        border: OutlineInputBorder(),
      ),
      items: items
          .map(
            (row) => DropdownMenuItem<String>(
              value: row.symbol,
              child: Text(
                favorites.contains(row.symbol) ? '★ ${row.name}' : row.name,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.setSymbol(value);
        }
      },
    );
  }

  Widget _buildIntervalControls(BuildContext context) {
    final interval = controller.interval.value;
    final isCustom = interval == CurrencyGraphInterval.custom;
    final customLabel = _customRangeLabel();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Range'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: CurrencyGraphInterval.values.map((item) {
            final isSelected = interval == item;
            final label = item == CurrencyGraphInterval.custom
                ? (isCustom ? customLabel : 'Custom')
                : item.label();
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                if (item == CurrencyGraphInterval.custom) {
                  _pickCustomRange(context);
                } else {
                  controller.setInterval(item);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCandleControls() {
    final rangeDuration = controller.endInterval.value.difference(
      controller.startInterval.value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Candle'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: CurrencyGraphCandle.values.map((item) {
            final isDisabled = item.toDuration() >= rangeDuration;
            return ChoiceChip(
              label: Text(item.label()),
              selected: controller.candle.value == item,
              onSelected: isDisabled ? null : (_) => controller.setCandle(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _customRangeLabel() {
    final formatter = DateFormat('yyyy/MM/dd');
    final start = formatter.format(controller.startInterval.value);
    final end = formatter.format(controller.endInterval.value);
    return '$start to $end';
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final dates = await showCalendarDatePicker2Dialog(
      context: context,
      dialogSize: const Size(360, 430),
      dialogBackgroundColor: const Color(0xFF2A3A50),
      borderRadius: BorderRadius.circular(16),
      barrierColor: Colors.black.withValues(alpha: 0.72),
      value: [controller.startInterval.value, controller.endInterval.value],
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(2015, 8, 7),
        lastDate: DateTime.now(),
        selectedDayHighlightColor: const Color(0xFF38BDF8),
        selectedRangeHighlightColor: const Color(0xFF334E68),
        selectedDayTextStyle: const TextStyle(
          color: Color(0xFF0B1220),
          fontWeight: FontWeight.w700,
        ),
        dayTextStyle: const TextStyle(color: Color(0xFFE5E7EB)),
        weekdayLabelTextStyle: const TextStyle(color: Color(0xFF94A3B8)),
        controlsTextStyle: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontWeight: FontWeight.w600,
        ),
        okButtonTextStyle: const TextStyle(color: Color(0xFF38BDF8)),
        cancelButtonTextStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
    if (dates != null && dates.length == 2) {
      final start = dates[0];
      final end = dates[1];
      if (start != null && end != null) {
        controller.setCustomRange(start, end);
      }
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});
  final CurrencyGraphData data;

  @override
  Widget build(BuildContext context) {
    final last = data.currency.last;
    final previous = data.currency.length > 1
        ? data.currency[data.currency.length - 2]
        : last;
    final change = previous == 0 ? 0.0 : (last - previous) / previous * 100;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _Stat(label: 'Last', value: last.toStringAsPrecision(7)),
        _Stat(label: 'Previous', value: previous.toStringAsPrecision(7)),
        _Stat(label: 'Change', value: '${change.toStringAsFixed(2)}%'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    ),
  );
}
