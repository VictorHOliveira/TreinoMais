import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/providers.dart';

class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const WorkoutPlayerScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen> {
  String? _sessionId;
  int _currentExerciseIndex = 0;
  final Map<String, List<_SetData>> _sets = {};
  final _weightControllers = <String, TextEditingController>{};
  final _repControllers = <String, TextEditingController>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  Future<void> _startSession() async {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;

    final sessionId = const Uuid().v4();
    _sessionId = sessionId;

    final data = {
      'id': sessionId,
      'user_id': user.id,
      'workout_id': widget.workoutId,
      'data': DateTime.now().toIso8601String(),
    };

    try {
      await ref.read(supabaseServiceProvider).insertSession(data);
    } catch (_) {}
  }

  Future<void> _saveAndFinish() async {
    setState(() => _saving = true);

    try {
      for (final entry in _sets.entries) {
        for (final setData in entry.value) {
          if (setData.peso != null || setData.reps != null) {
            await ref.read(supabaseServiceProvider).insertSet({
              'id': const Uuid().v4(),
              'session_id': _sessionId,
              'exercise_id': int.parse(entry.key),
              'set_numero': setData.numero,
              'peso_kg': setData.peso,
              'reps': setData.reps,
              'rpe': setData.rpe,
            });
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino salvo com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    for (final c in _repControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutExercises = ref.watch(workoutExercisesProvider(widget.workoutId));
    final exercises = ref.watch(exerciseListProvider);
    final exerciseList = exercises.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinando'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveAndFinish,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Finalizar'),
          ),
        ],
      ),
      body: workoutExercises.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Nenhum exercício neste treino'));
          }

          final we = list[_currentExerciseIndex];
          final ex = exerciseList.where((e) => e.id == we.exerciseId).firstOrNull;
          final sets = _sets.putIfAbsent(
            we.exerciseId.toString(),
            () => List.generate(
              we.seriesPadrao ?? 4,
              (i) => _SetData(numero: i + 1),
            ),
          );

          for (final s in sets) {
            final key = '${we.exerciseId}_${s.numero}';
            _weightControllers.putIfAbsent(key, () => TextEditingController());
            _repControllers.putIfAbsent(key, () => TextEditingController());
          }

          return Column(
            children: [
              _ExerciseHeader(
                exercise: ex,
                current: _currentExerciseIndex + 1,
                total: list.length,
                nome: ex?.nome ?? 'Exercício #${we.exerciseId}',
              ),
              if (ex != null && ex.imagemUrl != null)
                Container(
                  height: 150,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(ex.imagemUrl!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sets.length,
                  itemBuilder: (_, i) => _SetInputCard(
                    set: sets[i],
                    weightCtrl: _weightControllers['${we.exerciseId}_${sets[i].numero}']!,
                    repCtrl: _repControllers['${we.exerciseId}_${sets[i].numero}']!,
                    onChanged: (peso, reps) {
                      sets[i].peso = peso;
                      sets[i].reps = reps;
                    },
                  ),
                ),
              ),
              _NavigationBar(
                hasPrevious: _currentExerciseIndex > 0,
                hasNext: _currentExerciseIndex < list.length - 1,
                onPrevious: () {
                  if (_currentExerciseIndex > 0) {
                    setState(() => _currentExerciseIndex--);
                  }
                },
                onNext: () {
                  if (_currentExerciseIndex < list.length - 1) {
                    setState(() => _currentExerciseIndex++);
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}

class _SetData {
  final int numero;
  double? peso;
  int? reps;
  double? rpe;

  _SetData({required this.numero});
}

class _ExerciseHeader extends StatelessWidget {
  final Exercise? exercise;
  final int current;
  final int total;
  final String nome;

  const _ExerciseHeader({
    this.exercise,
    required this.current,
    required this.total,
    required this.nome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: Column(
        children: [
          Text(
            'Exercício $current de $total',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            nome,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (exercise != null) ...[
            const SizedBox(height: 4),
            Text(
              exercise!.musculoPrincipal,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SetInputCard extends StatelessWidget {
  final _SetData set;
  final TextEditingController weightCtrl;
  final TextEditingController repCtrl;
  final Function(double? peso, int? reps) onChanged;

  const _SetInputCard({
    required this.set,
    required this.weightCtrl,
    required this.repCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('${set.numero}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: weightCtrl,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final peso = double.tryParse(v.replaceAll(',', '.'));
                  onChanged(peso, set.reps);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repCtrl,
                decoration: const InputDecoration(
                  labelText: 'Repetições',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final reps = int.tryParse(v);
                  onChanged(set.peso, reps);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationBar({
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (hasPrevious)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
            ),
          if (hasPrevious && hasNext) const SizedBox(width: 16),
          if (hasNext)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Próximo'),
              ),
            ),
        ],
      ),
    );
  }
}
