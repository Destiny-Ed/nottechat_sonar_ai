import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';

Widget buildLineChart(Map<String, int> messagesPerDay, ThemeData theme) {
  if (messagesPerDay.isEmpty) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: Text("No messages", style: theme.textTheme.bodyMedium),
    );
  }

  final spots =
      messagesPerDay.entries
          .map((e) => FlSpot(messagesPerDay.keys.toList().indexOf(e.key).toDouble(), e.value.toDouble()))
          .toList();
  return LineChart(
    LineChartData(
      gridData: FlGridData(
        // showHorizontal: true,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[300]!, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget:
                (value, meta) => Text(
                  messagesPerDay.keys.elementAt(value.toInt()),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget:
                (value, meta) =>
                    Text(value.toInt().toString(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: primaryColor,
          barWidth: 3,
          belowBarData: BarAreaData(show: true, color: primaryColor.withOpacity(0.1)),
        ),
      ],
      minY: 0,
    ),
  );
}

Widget buildBarChart(Map<String, int> wordFreq, ThemeData theme) {
  final topWords = wordFreq.entries.take(5).toList();
  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barGroups:
          topWords
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(toY: e.value.value.toDouble(), color: primaryColor[300 + e.key * 100]!, width: 16),
                  ],
                ),
              )
              .toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget:
                (value, meta) => Text(
                  topWords[value.toInt()].key,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget:
                (value, meta) =>
                    Text(value.toInt().toString(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
      gridData: FlGridData(
        // showHorizontal: true,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[300]!, strokeWidth: 1),
      ),
    ),
  );
}
