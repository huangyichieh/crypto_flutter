import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../model/currency_stats.dart';

const _leftPadding = 72.0;
const _rightPadding = 16.0;
const _verticalPadding = 20.0;
const _bottomPadding = 40.0;
const _seriesColors = [
  Color(0xFF38BDF8),
  Color(0xFF22C55E),
  Color(0xFFF59E0B),
  Color(0xFFA78BFA),
  Color(0xFFFB7185),
];

class InteractiveGraph extends StatefulWidget {
  const InteractiveGraph({super.key, required this.data, this.height = 260});
  final CurrencyGraphData data;
  final double height;

  @override
  State<InteractiveGraph> createState() => _InteractiveGraphState();
}

class _InteractiveGraphState extends State<InteractiveGraph> {
  double? _hoverFraction;

  void _updateHover(Offset position, double width) {
    final graphWidth = math.max(1.0, width - _leftPadding - _rightPadding);
    setState(() {
      _hoverFraction = ((position.dx - _leftPadding) / graphWidth).clamp(
        0.0,
        1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final index = _hoverFraction == null
          ? null
          : (_hoverFraction! * (widget.data.currency.length - 1)).round();
      return SizedBox(
        height: widget.height,
        child: MouseRegion(
          cursor: SystemMouseCursors.precise,
          onHover: (event) =>
              _updateHover(event.localPosition, constraints.maxWidth),
          onExit: (_) => setState(() => _hoverFraction = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) =>
                _updateHover(details.localPosition, constraints.maxWidth),
            onPanUpdate: (details) =>
                _updateHover(details.localPosition, constraints.maxWidth),
            onPanEnd: (_) => setState(() => _hoverFraction = null),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GraphPainter(
                      widget.data,
                      hoverFraction: _hoverFraction,
                    ),
                  ),
                ),
                if (index != null)
                  _HoverTooltip(
                    left: _tooltipLeft(
                      constraints.maxWidth,
                      _hoverFraction!,
                      190,
                    ),
                    date: widget.data.date[index],
                    rows: [
                      _TooltipRow(
                        label: 'Price',
                        value: _formatPrice(widget.data.currency[index]),
                        color: _seriesColors.first,
                      ),
                    ],
                    width: 190,
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class MultiSeriesGraph extends StatefulWidget {
  const MultiSeriesGraph({super.key, required this.data, this.height = 320});
  final Map<String, CurrencyGraphData> data;
  final double height;

  @override
  State<MultiSeriesGraph> createState() => _MultiSeriesGraphState();
}

class _MultiSeriesGraphState extends State<MultiSeriesGraph> {
  double? _hoverFraction;

  void _updateHover(Offset position, double width) {
    final graphWidth = math.max(1.0, width - _leftPadding - _rightPadding);
    setState(() {
      _hoverFraction = ((position.dx - _leftPadding) / graphWidth).clamp(
        0.0,
        1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Wrap(
        spacing: 16,
        runSpacing: 6,
        children: widget.data.keys.toList().asMap().entries.map((entry) {
          final color = _seriesColors[entry.key % _seriesColors.length];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 3, color: color),
              const SizedBox(width: 5),
              Text(
                entry.value.replaceAll('USDT', ''),
                style: TextStyle(color: color),
              ),
            ],
          );
        }).toList(),
      ),
      LayoutBuilder(
        builder: (context, constraints) {
          final firstGraph = widget.data.values.first;
          final dateIndex = _hoverFraction == null
              ? null
              : (_hoverFraction! * (firstGraph.date.length - 1)).round();
          return SizedBox(
            height: widget.height,
            child: MouseRegion(
              cursor: SystemMouseCursors.precise,
              onHover: (event) =>
                  _updateHover(event.localPosition, constraints.maxWidth),
              onExit: (_) => setState(() => _hoverFraction = null),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (details) =>
                    _updateHover(details.localPosition, constraints.maxWidth),
                onPanUpdate: (details) =>
                    _updateHover(details.localPosition, constraints.maxWidth),
                onPanEnd: (_) => setState(() => _hoverFraction = null),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MultiSeriesPainter(
                          widget.data,
                          hoverFraction: _hoverFraction,
                        ),
                      ),
                    ),
                    if (dateIndex != null)
                      _HoverTooltip(
                        left: _tooltipLeft(
                          constraints.maxWidth,
                          _hoverFraction!,
                          230,
                        ),
                        date: firstGraph.date[dateIndex],
                        width: 230,
                        rows: widget.data.entries.toList().asMap().entries.map((
                          entry,
                        ) {
                          final graph = entry.value.value;
                          final valueIndex =
                              (_hoverFraction! * (graph.currency.length - 1))
                                  .round();
                          return _TooltipRow(
                            label: entry.value.key.replaceAll('USDT', ''),
                            value: _formatPrice(graph.currency[valueIndex]),
                            color:
                                _seriesColors[entry.key % _seriesColors.length],
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _TooltipRow {
  const _TooltipRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
}

class _HoverTooltip extends StatelessWidget {
  const _HoverTooltip({
    required this.left,
    required this.date,
    required this.rows,
    required this.width,
  });
  final double left;
  final DateTime date;
  final List<_TooltipRow> rows;
  final double width;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    top: 8,
    width: width,
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xEE1E293B),
          border: Border.all(color: const Color(0xFF475569)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy/MM/dd HH:mm').format(date.toLocal()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    children: [
                      Text(
                        '● ${row.label}',
                        style: TextStyle(
                          color: row.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(row.value),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

double _tooltipLeft(
  double availableWidth,
  double fraction,
  double tooltipWidth,
) {
  final pointerX =
      _leftPadding + (availableWidth - _leftPadding - _rightPadding) * fraction;
  final preferred = pointerX + 12;
  return preferred + tooltipWidth <= availableWidth
      ? preferred
      : math.max(0, pointerX - tooltipWidth - 12);
}

String _formatPrice(double value) =>
    value.abs() >= 1 ? value.toStringAsFixed(6) : value.toStringAsPrecision(7);

class _MultiSeriesPainter extends CustomPainter {
  _MultiSeriesPainter(this.data, {this.hoverFraction});
  final Map<String, CurrencyGraphData> data;
  final double? hoverFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _leftPadding,
      _verticalPadding,
      size.width - _leftPadding - _rightPadding,
      size.height - _verticalPadding - _bottomPadding,
    );
    _drawGrid(canvas, rect);
    _drawYAxisLabels(
      canvas,
      rect,
      minValue: 0,
      maxValue: 100,
      formatter: (value) => '${value.round()}%',
    );
    var seriesIndex = 0;
    for (final graph in data.values) {
      if (graph.currency.length < 2) continue;
      final minValue = graph.currency.reduce(math.min);
      final maxValue = graph.currency.reduce(math.max);
      final spread = maxValue == minValue ? 1.0 : maxValue - minValue;
      final path = Path();
      for (var i = 0; i < graph.currency.length; i++) {
        final x = rect.left + rect.width * i / (graph.currency.length - 1);
        final y =
            rect.bottom - rect.height * (graph.currency[i] - minValue) / spread;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      final color = _seriesColors[seriesIndex % _seriesColors.length];
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      _drawExtremaPoints(
        canvas: canvas,
        rect: rect,
        values: graph.currency,
        minValue: minValue,
        spread: spread,
        color: color,
      );
      if (hoverFraction case final fraction?) {
        final index = (fraction * (graph.currency.length - 1)).round();
        final x = rect.left + rect.width * index / (graph.currency.length - 1);
        final y =
            rect.bottom -
            rect.height * (graph.currency[index] - minValue) / spread;
        _drawHoverPoint(
          canvas: canvas,
          point: Offset(x, y),
          color: color,
          isExtrema: _isExtremaIndex(graph.currency, index),
        );
      }
      seriesIndex++;
    }
    _drawHoverLine(canvas, rect, hoverFraction);
    _drawXAxisLabels(canvas, rect, data.values.first.date);
  }

  @override
  bool shouldRepaint(covariant _MultiSeriesPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.hoverFraction != hoverFraction;
}

class _GraphPainter extends CustomPainter {
  _GraphPainter(this.data, {this.hoverFraction});
  final CurrencyGraphData data;
  final double? hoverFraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.currency.isEmpty) return;
    final rect = Rect.fromLTWH(
      _leftPadding,
      _verticalPadding,
      size.width - _leftPadding - _rightPadding,
      size.height - _verticalPadding - _bottomPadding,
    );
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0B1220));
    _drawGrid(canvas, rect);
    final minValue = data.currency.reduce(math.min);
    final maxValue = data.currency.reduce(math.max);
    final spread = maxValue == minValue ? 1.0 : maxValue - minValue;
    _drawYAxisLabels(
      canvas,
      rect,
      minValue: minValue,
      maxValue: maxValue,
      formatter: _formatAxisValue,
    );
    if (data.currency.length == 1) return;
    final path = Path();
    for (var i = 0; i < data.currency.length; i++) {
      final x = rect.left + rect.width * i / (data.currency.length - 1);
      final y =
          rect.bottom - rect.height * (data.currency[i] - minValue) / spread;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _seriesColors.first
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    _drawExtremaPoints(
      canvas: canvas,
      rect: rect,
      values: data.currency,
      minValue: minValue,
      spread: spread,
      color: _seriesColors.first,
    );
    if (hoverFraction case final fraction?) {
      final index = (fraction * (data.currency.length - 1)).round();
      final x = rect.left + rect.width * index / (data.currency.length - 1);
      final y =
          rect.bottom -
          rect.height * (data.currency[index] - minValue) / spread;
      _drawHoverPoint(
        canvas: canvas,
        point: Offset(x, y),
        color: _seriesColors.first,
        isExtrema: _isExtremaIndex(data.currency, index),
      );
    }
    _drawHoverLine(canvas, rect, hoverFraction);
    _drawXAxisLabels(canvas, rect, data.date);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.hoverFraction != hoverFraction;
}

void _drawGrid(Canvas canvas, Rect rect) {
  final paint = Paint()
    ..color = const Color(0xFF1F2937)
    ..strokeWidth = 1;
  for (var i = 0; i <= 4; i++) {
    final y = rect.top + rect.height * i / 4;
    canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
  }
}

void _drawYAxisLabels(
  Canvas canvas,
  Rect rect, {
  required double minValue,
  required double maxValue,
  required String Function(double value) formatter,
}) {
  const style = TextStyle(color: Color(0xFF94A3B8), fontSize: 11);
  for (final (value, y) in [(maxValue, rect.top), (minValue, rect.bottom)]) {
    final painter = TextPainter(
      text: TextSpan(text: formatter(value), style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: _leftPadding - 12);
    final labelY = (y - painter.height / 2).clamp(
      0.0,
      rect.bottom - painter.height,
    );
    painter.paint(canvas, Offset(rect.left - painter.width - 8, labelY));
  }
}

String _formatAxisValue(double value) {
  final absolute = value.abs();
  if (absolute >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (absolute >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (absolute >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  if (absolute >= 100) return value.toStringAsFixed(0);
  if (absolute >= 1) return value.toStringAsFixed(2);
  if (absolute == 0) return '0';
  return value.toStringAsPrecision(3);
}

void _drawHoverLine(Canvas canvas, Rect rect, double? fraction) {
  if (fraction == null) return;
  final x = rect.left + rect.width * fraction;
  canvas.drawLine(
    Offset(x, rect.top),
    Offset(x, rect.bottom),
    Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1,
  );
}

void _drawExtremaPoints({
  required Canvas canvas,
  required Rect rect,
  required List<double> values,
  required double minValue,
  required double spread,
  required Color color,
}) {
  if (values.isEmpty) return;
  var lowestIndex = 0;
  var highestIndex = 0;
  for (var i = 1; i < values.length; i++) {
    if (values[i] < values[lowestIndex]) lowestIndex = i;
    if (values[i] > values[highestIndex]) highestIndex = i;
  }

  void drawPoint(int index) {
    final x = values.length == 1
        ? rect.center.dx
        : rect.left + rect.width * index / (values.length - 1);
    final y = rect.bottom - rect.height * (values[index] - minValue) / spread;
    canvas.drawCircle(Offset(x, y), 5, Paint()..color = color);
    canvas.drawCircle(
      Offset(x, y),
      5,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  drawPoint(lowestIndex);
  if (highestIndex != lowestIndex) drawPoint(highestIndex);
}

bool _isExtremaIndex(List<double> values, int index) {
  if (values.isEmpty) return false;
  var lowestIndex = 0;
  var highestIndex = 0;
  for (var i = 1; i < values.length; i++) {
    if (values[i] < values[lowestIndex]) lowestIndex = i;
    if (values[i] > values[highestIndex]) highestIndex = i;
  }
  return index == lowestIndex || index == highestIndex;
}

void _drawHoverPoint({
  required Canvas canvas,
  required Offset point,
  required Color color,
  required bool isExtrema,
}) {
  canvas.drawCircle(point, isExtrema ? 5 : 4, Paint()..color = color);
  if (isExtrema) {
    canvas.drawCircle(
      point,
      5,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }
}

void _drawXAxisLabels(Canvas canvas, Rect rect, List<DateTime> dates) {
  if (dates.isEmpty) return;
  final formatter = DateFormat('MM/dd HH:mm');
  final style = const TextStyle(color: Color(0xFF94A3B8), fontSize: 11);
  final firstPainter = TextPainter(
    text: TextSpan(text: formatter.format(dates.first.toLocal()), style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final lastPainter = TextPainter(
    text: TextSpan(text: formatter.format(dates.last.toLocal()), style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final labelY = rect.bottom + 8;
  firstPainter.paint(canvas, Offset(rect.left, labelY));
  lastPainter.paint(canvas, Offset(rect.right - lastPainter.width, labelY));
}
