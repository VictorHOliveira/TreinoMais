import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../models/body_measurement.dart';

class BodyMeasurementChart extends StatelessWidget {
  final List<BodyMeasurement> measurements;

  const BodyMeasurementChart({super.key, required this.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(child: Text('Sem dados'));
    }

    final sorted = [...measurements]
      ..sort((a, b) => a.data.compareTo(b.data));

    final weightSpots = <FlSpot>[];
    final fatSpots = <FlSpot>[];
    bool hasFat = false;

    for (int i = 0; i < sorted.length; i++) {
      final m = sorted[i];
      weightSpots.add(FlSpot(i.toDouble(), m.pesoKg));
      if (m.gorduraPercent != null) {
        fatSpots.add(FlSpot(i.toDouble(), m.gorduraPercent!));
        hasFat = true;
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.textHint.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: sorted.length > 5 ? (sorted.length / 4).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < sorted.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${sorted[idx].data.day}/${sorted[idx].data.month}',
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
        lineBarsData: [
          LineChartBarData(
            spots: weightSpots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          if (hasFat)
            LineChartBarData(
              spots: fatSpots,
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.secondary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.asMap().entries.map((entry) {
              final isWeight = entry.key == 0;
              return LineTooltipItem(
                isWeight ? '${entry.value.y.toStringAsFixed(1)} kg' : '${entry.value.y.toStringAsFixed(1)}%',
                TextStyle(
                  color: isWeight ? AppColors.primary : AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
