import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/providers.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutProvider);
    final workout = workouts.valueOrNull?.firstWhere(
      (w) => w.id == workoutId,
      orElse: () => throw Exception('Treino não encontrado'),
    );

    final exercises = ref.watch(workoutExercisesProvider(workoutId));
    final exerciseList = ref.watch(exerciseListProvider);
    final exercisesData = exerciseList.valueOrNull ?? [];

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Treino')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_filled, color: AppColors.primary),
            onPressed: () => context.push(
              '/workouts/$workoutId/start',
            ),
          ),
        ],
      ),
      body: exercises.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Nenhum exercício adicionado',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Adicione exercícios ao treino',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final we = list[i];
              final ex = exercisesData.where((e) => e.id == we.exerciseId).firstOrNull;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text('${we.ordem}', style: TextStyle(color: AppColors.primary)),
                  ),
                  title: Text(ex?.nome ?? 'Exercício #${we.exerciseId}'),
                  subtitle: Text(
                    '${we.seriesPadrao ?? '-'} séries x ${we.repsPadrao ?? '-'} reps',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => ref.read(workoutProvider.notifier).delete(we.id),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExercise(context, ref, workoutId),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Exercício'),
      ),
    );
  }

  void _addExercise(BuildContext context, WidgetRef ref, String workoutId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ExercisePickerSheet(workoutId: workoutId),
    );
  }
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  final String workoutId;

  const _ExercisePickerSheet({required this.workoutId});

  @override
  ConsumerState<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  final _searchCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController(text: '4');
  final _repsCtrl = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseListProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Adicionar Exercício',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Buscar exercício...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) {
              if (v.length >= 2) {
                ref.read(exerciseListProvider.notifier).search(v);
              }
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _seriesCtrl,
                  decoration: const InputDecoration(labelText: 'Séries'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _repsCtrl,
                  decoration: const InputDecoration(labelText: 'Repetições'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 300,
            child: exercises.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final ex = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        ex.musculoPrincipal.substring(0, 2),
                        style: const TextStyle(fontSize: 10, color: AppColors.primary),
                      ),
                    ),
                    title: Text(ex.nome, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(ex.musculoPrincipal,
                        style: const TextStyle(fontSize: 12)),
                    onTap: () async {
                      final supabase = ref.read(supabaseServiceProvider);
                      final exerciseId = ex.id;
                      final series = int.tryParse(_seriesCtrl.text) ?? 4;
                      final reps = int.tryParse(_repsCtrl.text) ?? 10;

                      final we = {
                        'id': '${widget.workoutId}_$exerciseId',
                        'workout_id': widget.workoutId,
                        'exercise_id': exerciseId,
                        'ordem': list.length + 1,
                        'series_padrao': series,
                        'reps_padrao': reps,
                      };

                      await supabase.insertWorkoutExercise(we);
                      ref.invalidate(workoutExercisesProvider(widget.workoutId));
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
