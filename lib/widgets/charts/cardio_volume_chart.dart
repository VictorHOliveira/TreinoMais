import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cardio_session.dart';

class CardioVolumeChart extends StatelessWidget {
  final List<CardioSession> sessions;

  const CardioVolumeChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text('Sem dados', style: TextStyle(color: AppColors.textHint)),
      );
    }

    final today = DateTime.now();
    final last4Weeks = List.generate(4, (i) {
      final start = DateTime(today.year, today.month, today.day - (today.weekday - 1) - (3 - i) * 7);
      final end = start.add(const Duration(days: 7));
      return (start: start, end: end);
    });

    final weeklyMinutes = <int>[];
    for (final week in last4Weeks) {
      final total = sessions
          .where((s) => s.data.isAfter(week.start) && s.data.isBefore(week.end))
          .fold<int>(0, (sum, s) => sum + s.duracaoMinutos);
      weeklyMinutes.add(total);
    }

    final maxMin = weeklyMinutes.fold<int>(0, (a, b) => a > b ? a : b);

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
                if (idx >= 0 && idx < 4) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'S${idx + 1}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textHint),
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
        barGroups: weeklyMinutes.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: AppColors.cardioOrange,
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        maxY: maxMin > 0 ? maxMin * 1.2 : 100,
      ),
    );
  }
}
