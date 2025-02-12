import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_support/helpers/helper_functions/is_same_day.dart';
import 'package:mental_health_support/models/mood.dart';

class MoodTimeline extends StatelessWidget {
  final List<MoodEntry> moods;

  const MoodTimeline({super.key, required this.moods});

  @override
  @override
  Widget build(BuildContext context) {
    if (moods.isEmpty) {
      return Center(
        child: Text(
          'No moods recorded for the past week.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final List<FlSpot> spots = _generateMoodPoints();
    final double maxY =
        spots.isNotEmpty
            ? spots.map((spot) => spot.y).reduce(math.max) + 1
            : 1.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 200, // Fixed height for chart container
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: maxY,
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isCurved: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30, // Add reserved space for bottom titles
                  getTitlesWidget: (value, meta) {
                    if (!value.isFinite || value < 0 || value > 6) {
                      return const SizedBox.shrink();
                    }
                    final date = DateTime.now().subtract(
                      Duration(days: 7 - value.toInt()),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('d MMM').format(date),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30, // Maintain reserved space
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateMoodPoints() {
    final DateTime now = DateTime.now();
    return List.generate(7, (index) {
      final DateTime date = now.subtract(Duration(days: 6 - index));
      final int count = moods.where((m) => isSameDay(m.date, date)).length;
      return FlSpot(index.toDouble(), count.toDouble());
    });
  }
}
