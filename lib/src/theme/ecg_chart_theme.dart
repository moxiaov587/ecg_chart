import 'package:flutter/material.dart';

part 'ecg_chart_theme_data.dart';

class ECGChartTheme extends InheritedWidget {
  const ECGChartTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final ECGChartThemeData data;

  static ECGChartThemeData of(
    BuildContext context,
  ) =>
      context.dependOnInheritedWidgetOfExactType<ECGChartTheme>()!.data;

  static ECGChartThemeData? maybeOf(
    BuildContext context,
  ) =>
      context.dependOnInheritedWidgetOfExactType<ECGChartTheme>()?.data;

  @override
  bool updateShouldNotify(covariant ECGChartTheme oldWidget) =>
      data != oldWidget.data;
}
