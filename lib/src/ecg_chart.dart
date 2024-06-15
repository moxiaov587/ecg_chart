import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../src/theme/ecg_chart_theme.dart';
import 'ecg_chart_painter.dart';

/// A chart for drawing ECG.
class ECGChart extends StatefulWidget {
  /// Creates a ecg chart.
  ///
  /// Use [ECGChartThemeData] to customize the appearance.
  const ECGChart({
    required this.values,
    this.min = 150,
    this.max = 250,
    Key? key,
  })  : assert(max > min, 'max($max) must be larger than min($min)'),
        super(key: key);

  /// Accepts one or more values ​​to use for drawing.
  ///
  /// When multiple values ​​are passed in, they will not be rendered all at once.
  /// The rendering is controlled by [ECGChartState._ticker] and recorded by
  /// [ECGChartState._currentRenderIndex].
  final List<double> values;

  /// Minimum of [values].
  ///
  /// Must be less than or equal to [max].
  ///
  /// Used to limit the drawing from crossing the boundary.
  final double min;

  /// Maximum of [values].
  ///
  /// Must be greater than or equal to [min].
  ///
  /// Used to limit the drawing from crossing the boundary.
  final double max;

  @override
  State<ECGChart> createState() => ECGChartState();
}

/// State for a [ECGChart].
///
/// Call [ECGChartState.reset] to reset the rendering history.
class ECGChartState extends State<ECGChart> {
  late final List<double> _values = <double>[...widget.values];

  int _currentRenderIndex = 0;

  late final Ticker _ticker = Ticker((_) {
    _currentRenderIndex++;
    if (_currentRenderIndex >= _values.length) {
      _currentRenderIndex--;

      _ticker.stop();
      return;
    }
    setState(() {});
  })
    ..start();

  @override
  void didUpdateWidget(covariant ECGChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    _values.addAll(widget.values);

    if (!_ticker.isActive && _values.length > _currentRenderIndex) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker
      ..stop()
      ..dispose();

    super.dispose();
  }

  double _displayValue2YAxisOffsetValue(
    double displayValue, {
    required double chartHeight,
    required double yAxisDisplayValue2OffsetValueFactor,
  }) =>
      chartHeight -
      (displayValue - widget.min) * yAxisDisplayValue2OffsetValueFactor;

  /// Clear the current rendering history to accept new [ECGChart.values].
  void reset() {
    _values.clear();
    _currentRenderIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final double chartWidth = constraints.maxWidth;
        final double chartHeight = constraints.maxHeight;

        if (chartWidth == 0.0 || chartHeight == 0.0) {
          return const SizedBox.shrink();
        }

        final ECGChartThemeData? themeData = ECGChartTheme.maybeOf(context);

        final double pointsGap = themeData?.pointsGap ?? kPointsGap;

        final int maxRenderCount = chartWidth ~/ pointsGap;

        final Iterable<double> latestPoints;
        final Iterable<double> oldPoints;

        if (_currentRenderIndex > maxRenderCount) {
          final Iterable<double> renderPoints = _values.sublist(
            _currentRenderIndex + 1 - maxRenderCount,
            _currentRenderIndex + 1,
          );
          final int remaining =
              maxRenderCount - _currentRenderIndex % maxRenderCount;

          latestPoints = renderPoints.skip(remaining);
          oldPoints = renderPoints.take(remaining);
        } else {
          latestPoints = _values.take(_currentRenderIndex + 1);
          oldPoints = <double>[];
        }

        final double yAxisDisplayValue2OffsetValueFactor =
            chartHeight / (widget.max - widget.min);

        return CustomPaint(
          size: Size(maxRenderCount * pointsGap, chartHeight),
          isComplex: true,
          painter: ECGChartPainter(
            latestPoints: latestPoints
                .map((double value) => _displayValue2YAxisOffsetValue(
                      value,
                      chartHeight: chartHeight,
                      yAxisDisplayValue2OffsetValueFactor:
                          yAxisDisplayValue2OffsetValueFactor,
                    ))
                .toList(),
            oldPoints: oldPoints
                .map((double value) => _displayValue2YAxisOffsetValue(
                      value,
                      chartHeight: chartHeight,
                      yAxisDisplayValue2OffsetValueFactor:
                          yAxisDisplayValue2OffsetValueFactor,
                    ))
                .toList(),
            themeData: themeData,
          ),
        );
      },
    );
  }
}
