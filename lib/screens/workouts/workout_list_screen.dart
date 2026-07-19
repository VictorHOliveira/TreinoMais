import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import '../../providers/providers.dart';

class WorkoutListScreen extends ConsumerWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(supabaseServiceProvider).currentUser;
    final workouts = ref.watch(workoutProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Treinos')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) ref.read(workoutProvider.notifier).load(user.id);
        },
        child: workouts.when(
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center_outlined, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text('Nenhum treino criado',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Crie seu primeiro treino!',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _WorkoutCard(workout: list[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/workouts/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WorkoutCard extends ConsumerWidget {
  final Workout workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/workouts/${workout.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    workout.diaSemanaLabel.substring(0, 3),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.nome,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (workout.descricao != null) ...[
                      const SizedBox(height: 2),
                      Text(workout.descricao!,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
