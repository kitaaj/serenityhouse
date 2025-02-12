import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/enums/mood_type.dart';
import 'package:mental_health_support/models/mood.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/moodbloc/mood_state.dart';

class MoodStatistics extends StatelessWidget {
  const MoodStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 260,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Mood Distribution',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: BlocBuilder<MoodBloc, MoodState>(
                      builder: (context, state) {
                        if (state is MoodLoadingState) {
                          return const Center(child: CircularProgressIndicator());
                        }
      
                        if (state is MoodErrorState) {
                          return Center(
                            child: Text(
                              'Failed to load mood data',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          );
                        }
      
                        final moods =
                            state is MoodLoadedState
                                ? state.moods
                                : <MoodEntry>[];
                        final moodCounts = _calculateMoodCounts(moods);
      
                        return moods.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 40,
                                    color: colorScheme.onSurface,
                                  ),
                                  Text(
                                    'No mood data available',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : BarChart(
                              duration: const Duration(milliseconds: 300),
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY:
                                    moodCounts.isNotEmpty
                                        ? max(
                                          moodCounts.reduce(max).toDouble(),
                                          1.0,
                                        )
                                        : 1.0,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem:
                                        (
                                          group,
                                          groupIndex,
                                          rod,
                                          rodIndex,
                                        ) => BarTooltipItem(
                                          '${MoodType.values[group.x.toInt()].label}\n${rod.toY} entries',
                                          TextStyle(color: colorScheme.onSurface),
                                        ),
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                          ),
                                          child: Text(
                                            MoodType.values[value.toInt()].label,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(),
                                  topTitles: const AxisTitles(),
                                  rightTitles: const AxisTitles(),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine:
                                      (value) => FlLine(
                                        color: Colors.grey.shade300,
                                        strokeWidth: 0.5,
                                      ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1,
                                    ),
                                    left: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                barGroups:
                                    MoodType.values.map((mood) {
                                      final index = MoodType.values.indexOf(mood);
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY:
                                                moodCounts.isNotEmpty
                                                    ? moodCounts[index].toDouble()
                                                    : 0.0,
                                            color: mood.color,
                                            width: 20,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<int> _calculateMoodCounts(List<MoodEntry> moods) {
    return MoodType.values.map((mood) {
      return moods
          .where(
            (entry) => entry.label.toLowerCase() == mood.label.toLowerCase(),
          )
          .length;
    }).toList();
  }
}
