import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/constants.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/providers.dart';
import 'exercise_sync_screen.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedMuscle;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseListProvider);
    final hasExercises = ref.watch(hasExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExerciseSyncScreen()),
            ),
            tooltip: 'Sincronizar exercícios',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Buscar exercícios...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (v) {
                    if (v.length >= 2) {
                      ref.read(exerciseListProvider.notifier).search(v);
                    } else if (v.isEmpty) {
                      ref.read(exerciseListProvider.notifier).load(muscle: _selectedMuscle);
                    }
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Todos',
                        selected: _selectedMuscle == null,
                        onTap: () {
                          setState(() => _selectedMuscle = null);
                          ref.read(exerciseListProvider.notifier).load();
                        },
                      ),
                      ...MuscleGroups.all.map((m) => _FilterChip(
                            label: m,
                            selected: _selectedMuscle == m,
                            onTap: () {
                              setState(() => _selectedMuscle = m);
                              ref.read(exerciseListProvider.notifier).load(muscle: m);
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: exercises.when(
        data: (list) {
          if (list.isEmpty) {
            return hasExercises.when(
              data: (exists) {
                if (exists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: AppColors.textHint),
                        const SizedBox(height: 8),
                        Text('Nenhum exercício encontrado',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_download_outlined, size: 64, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text('Nenhum exercício no banco',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Clique em sincronizar para baixar os exercícios\nda Wger API para seu banco de dados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ExerciseSyncScreen()),
                        ),
                        icon: const Icon(Icons.download),
                        label: const Text('Sincronizar'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: CircularProgressIndicator()),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _ExerciseCard(
              exercise: list.elementAt(i),
              onFavorite: () {
                final user = ref.read(supabaseServiceProvider).currentUser;
                if (user != null) {
                  ref.read(exerciseListProvider.notifier).toggleFavorite(
                        user.id,
                        list.elementAt(i).id,
                      );
                }
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 8),
              Text('Erro ao carregar: $e',
                  style: TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(exerciseListProvider.notifier).load(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textHint,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onFavorite;

  const _ExerciseCard({
    required this.exercise,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/exercises/${exercise.id}', extra: exercise),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: exercise.imagemUrl != null
                      ? CachedNetworkImage(
                          imageUrl: exercise.imagemUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.background,
                            child: const Icon(Icons.image, color: AppColors.textHint),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.background,
                            child: const Icon(Icons.image, color: AppColors.textHint),
                          ),
                        )
                      : Container(
                          color: AppColors.background,
                          child: const Icon(Icons.fitness_center, color: AppColors.textHint),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.nome,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            exercise.musculoPrincipal,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (exercise.equipamento != null) ...[
                          const SizedBox(width: 8),
                          Text(exercise.equipamento!,
                              style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  exercise.isFavorito ? Icons.favorite : Icons.favorite_border,
                  color: exercise.isFavorito ? AppColors.secondary : AppColors.textHint,
                  size: 20,
                ),
                onPressed: onFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
