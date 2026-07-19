import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/body_measurement.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/charts/body_measurement_chart.dart';

class MeasurementListScreen extends ConsumerStatefulWidget {
  const MeasurementListScreen({super.key});

  @override
  ConsumerState<MeasurementListScreen> createState() => _MeasurementListScreenState();
}

class _MeasurementListScreenState extends ConsumerState<MeasurementListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(supabaseServiceProvider).currentUser;
      if (user != null) ref.read(measurementProvider.notifier).load(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final measurements = ref.watch(measurementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Medidas Corporais')),
      body: measurements.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_weight_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Nenhuma medida registrada',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Adicione sua primeira medida!',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: BodyMeasurementChart(measurements: list),
                ),
                const SizedBox(height: 16),
                ...list.map((m) => _MeasurementCard(measurement: m)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/measurements/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MeasurementCard extends ConsumerWidget {
  final BodyMeasurement measurement;

  const _MeasurementCard({required this.measurement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.monitor_weight, color: AppColors.primary),
        ),
        title: Text(Formatters.weight(measurement.pesoKg)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formatters.date(measurement.data)),
            if (measurement.gorduraPercent != null)
              Text('Gordura: ${Formatters.percent(measurement.gorduraPercent)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () => ref.read(measurementProvider.notifier).delete(measurement.id),
        ),
      ),
    );
  }
}
