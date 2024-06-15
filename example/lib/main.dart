import 'dart:async';
import 'dart:math';

import 'package:ecg_chart/ecg_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<List<double>> _stream() async* {
    for (var i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 16));
      yield List.generate(1, (index) => Random().nextDouble() * 100 + 150);
    }
  }

  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECGChart example app',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xff36cfc9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff36cfc9),
          error: const Color(0xfff759ab),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xff1765ad),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xff1765ad),
          error: const Color(0xffa61d24),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ECGChart example app'),
        ),
        body: Builder(builder: (context) {
          return Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                height: 300,
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<List<double>>(
                  stream: _stream(),
                  initialData: const [],
                  builder: (context, snapshot) {
                    return ECGChartTheme(
                      data: ECGChartThemeData(
                        lineColor: Theme.of(context).primaryColor,
                        lineWidth: 4.0,
                        indicatorColor: Theme.of(context).colorScheme.error,
                      ),
                      child: ECGChart(values: snapshot.data ?? []),
                    );
                  },
                ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() => isDarkMode = !isDarkMode);
          },
          child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
    );
  }
}
