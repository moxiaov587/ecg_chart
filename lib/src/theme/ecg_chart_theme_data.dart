part of 'ecg_chart_theme.dart';

const double kPointsGap = 12;
const double kSmooth = 0.5;
const Color kLineColor = Colors.blue;
const double kLineWidth = 2.0;
const double kIndicatorRadius = 4.0;
const Color kIndicatorColor = Colors.red;
const MaskFilter kIndicatorMaskFilter = MaskFilter.blur(BlurStyle.solid, 4.0);

@immutable
class ECGChartThemeData {
  const ECGChartThemeData({
    this.pointsGap = kPointsGap,
    this.smooth = kSmooth,
    this.lineColor,
    this.lineWidth,
    this.indicatorRadius,
    this.indicatorColor,
    this.indicatorMaskFilter = kIndicatorMaskFilter,
  })  : assert(
          pointsGap == null || pointsGap > 0,
          'pointsGap($pointsGap) must be larger than 0',
        ),
        assert(
          smooth == null || smooth >= 0.0 && smooth <= 1.0,
          'smooth($smooth) must be between [0-1]',
        );

  final double? pointsGap;
  final double? smooth;
  final Color? lineColor;
  final double? lineWidth;
  final double? indicatorRadius;
  final Color? indicatorColor;
  final MaskFilter? indicatorMaskFilter;

  @override
  bool operator ==(Object other) =>
      other is ECGChartThemeData &&
      other.pointsGap == pointsGap &&
      other.smooth == smooth &&
      other.lineColor == lineColor &&
      other.lineWidth == lineWidth &&
      other.indicatorRadius == indicatorRadius &&
      other.indicatorColor == indicatorColor &&
      other.indicatorMaskFilter == indicatorMaskFilter;

  @override
  int get hashCode => Object.hash(
        pointsGap,
        smooth,
        lineColor,
        lineWidth,
        indicatorRadius,
        indicatorColor,
        indicatorMaskFilter,
      );
}
