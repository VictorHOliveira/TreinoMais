import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/exercise_provider.dart';
import '../progress/exercise_progress_chart.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final int exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exerciseListProvider);
    final exercise = exercises.valueOrNull?.where((e) => e.id == exerciseId).firstOrNull;

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercício')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(exercise.nome)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (exercise.imagemUrl != null)
              Container(
                height: 250,
                color: AppColors.background,
                child: CachedNetworkImage(
                  imageUrl: exercise.imagemUrl!,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported, size: 48, color: AppColors.textHint),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoChip(label: exercise.musculoPrincipal, icon: Icons.fitness_center),
                      if (exercise.equipamento != null)
                        _InfoChip(label: '${exercise.equipamento}', icon: Icons.build),
                    ],
                  ),
                  if (exercise.musculosSecundarios.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Músculos secundários:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: exercise.musculosSecundarios
                          .map((m) => Chip(label: Text(m, style: const TextStyle(fontSize: 12))))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Descrição', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    exercise.descricao.isNotEmpty
                        ? exercise.descricao
                        : 'Sem descrição disponível.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Text('Progressão', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: ExerciseProgressChart(exerciseId: exercise.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.primary)),
        ],
      ),
    );
  }
}
