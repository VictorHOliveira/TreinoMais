import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cardio_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/charts/cardio_volume_chart.dart';

class CardioListScreen extends ConsumerStatefulWidget {
  const CardioListScreen({super.key});

  @override
  ConsumerState<CardioListScreen> createState() => _CardioListScreenState();
}

class _CardioListScreenState extends ConsumerState<CardioListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(supabaseServiceProvider).currentUser;
      if (user != null) ref.read(cardioProvider.notifier).load(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardio = ref.watch(cardioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cardio')),
      body: cardio.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_run, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Nenhum cardio registrado',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Registre sua primeira sessão!',
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
                  height: 200,
                  child: CardioVolumeChart(sessions: list),
                ),
                const SizedBox(height: 16),
                ...list.map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.cardioOrange.withValues(alpha: 0.1),
                      child: const Icon(Icons.directions_run, color: AppColors.cardioOrange),
                    ),
                    title: Text(s.tipo),
                    subtitle: Text(
                      '${Formatters.duration(s.duracaoMinutos)}${s.distanciaKm != null ? ' - ${Formatters.distance(s.distanciaKm)}' : ''}${s.calorias != null ? ' - ${Formatters.calories(s.calorias)}' : ''}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.date(s.data), style: const TextStyle(fontSize: 12)),
                        if (s.percepcaoEsforco != null)
                          Text('Esforço: ${s.percepcaoEsforco}/10',
                              style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/cardio/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
