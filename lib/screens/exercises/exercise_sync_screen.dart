import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/exercise_provider.dart';

class ExerciseSyncScreen extends ConsumerStatefulWidget {
  const ExerciseSyncScreen({super.key});

  @override
  ConsumerState<ExerciseSyncScreen> createState() => _ExerciseSyncScreenState();
}

class _ExerciseSyncScreenState extends ConsumerState<ExerciseSyncScreen> {
  SyncStatus _status = SyncStatus.idle;
  String _message = '';
  int? _total;

  Future<void> _startSync() async {
    setState(() {
      _status = SyncStatus.syncing;
      _message = 'Buscando exercícios...';
    });

    final syncService = ref.read(syncServiceProvider);
    final result = await syncService.syncAll();

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _status = SyncStatus.done;
        _message = '${result.imported} exercícios sincronizados!';
        _total = result.total;
      });
      ref.read(exerciseListProvider.notifier).refresh();
      ref.invalidate(hasExercisesProvider);
    } else {
      setState(() {
        _status = SyncStatus.error;
        _message = result.error ?? 'Erro desconhecido';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronizar Exercícios')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_status == SyncStatus.syncing) ...[
                const SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
                const SizedBox(height: 24),
                Text(_message, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Buscando dados da Wger API...',
                    style: TextStyle(color: AppColors.textSecondary)),
              ] else if (_status == SyncStatus.done) ...[
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 24),
                Text(_message, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$_total exercícios processados no total',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Concluído'),
                ),
              ] else if (_status == SyncStatus.error) ...[
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 24),
                Text(_message, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startSync,
                  child: const Text('Tentar novamente'),
                ),
              ] else ...[
                Icon(Icons.cloud_download_outlined, size: 64, color: AppColors.primary),
                const SizedBox(height: 24),
                Text('Sincronizar Exercícios',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Baixe todos os exercícios da Wger API para o seu banco de dados.\n'
                  'Feito uma vez, as consultas serão locais e mais rápidas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _startSync,
                  icon: const Icon(Icons.download),
                  label: const Text('Iniciar Sincronização'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum SyncStatus { idle, syncing, done, error }
