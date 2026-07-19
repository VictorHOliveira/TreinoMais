import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise_set.dart';

class LoadProgressionChart extends StatelessWidget {
  final List<ExerciseSet> sets;
  final List<DateTime> dates;

  const LoadProgressionChart({
    super.key,
    required this.sets,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) {
      return Center(
        child: Text('Sem dados', style: TextStyle(color: AppColors.textHint)),
      );
    }

    final maxWeight = sets
        .map((s) => s.pesoKg ?? 0)
        .reduce((a, b) => a > b ? a : b);

    final weightSpots = <FlSpot>[];
    final volumeSpots = <FlSpot>[];
    final rmSpots = <FlSpot>[];

    for (int i = 0; i < sets.length; i++) {
      final s = sets[i];
      if (s.pesoKg != null) {
        weightSpots.add(FlSpot(i.toDouble(), s.pesoKg!));
      }
      if (s.volume != null) {
        volumeSpots.add(FlSpot(i.toDouble(), s.volume!));
      }
      if (s.estimated1Rm != null) {
        rmSpots.add(FlSpot(i.toDouble(), s.estimated1Rm!));
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxWeight > 0 ? maxWeight / 4 : 10,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.textHint.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          if (weightSpots.isNotEmpty)
            LineChartBarData(
              spots: weightSpots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          if (volumeSpots.isNotEmpty)
            LineChartBarData(
              spots: volumeSpots,
              isCurved: true,
              color: AppColors.success,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          if (rmSpots.isNotEmpty)
            LineChartBarData(
              spots: rmSpots,
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 2,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }
}
