import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../models/water_log.dart';

class WaterProgressChart extends StatelessWidget {
  final List<WaterLog> logs;

  const WaterProgressChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Text('Sem dados', style: TextStyle(color: AppColors.textHint)),
      );
    }

    final today = DateTime.now();
    final last7Days = List.generate(7, (i) {
      return DateTime(today.year, today.month, today.day - (6 - i));
    });

    final dailyTotal = <DateTime, int>{};
    for (final d in last7Days) {
      dailyTotal[d] = 0;
    }
    for (final log in logs) {
      final day = DateTime(log.data.year, log.data.month, log.data.day);
      if (dailyTotal.containsKey(day)) {
        dailyTotal[day] = (dailyTotal[day] ?? 0) + log.quantidadeMl;
      }
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < last7Days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'][last7Days[idx].weekday - 1],
                      style: const TextStyle(fontSize: 9, color: AppColors.textHint),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: last7Days.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (dailyTotal[entry.value] ?? 0).toDouble(),
                color: AppColors.waterBlue,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
