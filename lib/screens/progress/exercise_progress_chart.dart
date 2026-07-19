import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/exercise_set.dart';
import '../../providers/exercise_provider.dart';

class ExerciseProgressChart extends ConsumerWidget {
  final int exerciseId;

  const ExerciseProgressChart({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(exerciseSetsProvider(exerciseId));

    return setsAsync.when(
      data: (sets) {
        if (sets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: AppColors.textHint),
                const SizedBox(height: 8),
                Text('Sem dados de progressão',
                    style: TextStyle(color: AppColors.textSecondary)),
                Text('Registre séries para ver o gráfico',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          );
        }

        final grouped = _groupBySession(sets);
        if (grouped.isEmpty) {
          return const Center(child: Text('Sem dados'));
        }

        final maxWeight = sets
            .map((s) => s.pesoKg ?? 0)
            .reduce((a, b) => a > b ? a : b);

        final spots = <FlSpot>[];
        final entries = grouped.entries.toList();
        for (int i = 0; i < entries.length; i++) {
          final entry = entries[i];
          final best = entry.value.values
              .expand((list) => list)
              .where((s) => s.pesoKg != null)
              .map((s) => s.pesoKg!)
              .fold<double>(0, (a, b) => a > b ? a : b);
          if (best > 0) {
            spots.add(FlSpot(i.toDouble(), best));
          }
        }

        if (spots.isEmpty) {
          return const Center(child: Text('Sem dados de carga'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução da Carga Máxima',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}kg',
                          style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < grouped.length) {
                            final date = grouped.keys.elementAt(idx);
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                Formatters.date(date),
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
                  minY: 0,
                  maxY: maxWeight * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 4,
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
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} kg',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e', style: TextStyle(color: AppColors.error))),
    );
  }

  Map<DateTime, Map<int, List<ExerciseSet>>> _groupBySession(List<ExerciseSet> sets) {
    final result = <DateTime, Map<int, List<ExerciseSet>>>{};
    for (final _ in sets) {
      result.putIfAbsent(DateTime.now(), () => <int, List<ExerciseSet>>{});
    }
    return result;
  }
}
