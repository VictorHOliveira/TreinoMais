import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import '../../providers/providers.dart';

class WorkoutCreateScreen extends ConsumerStatefulWidget {
  const WorkoutCreateScreen({super.key});

  @override
  ConsumerState<WorkoutCreateScreen> createState() => _WorkoutCreateScreenState();
}

class _WorkoutCreateScreenState extends ConsumerState<WorkoutCreateScreen> {
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _diaSemana;
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;

    final workout = Workout(
      id: const Uuid().v4(),
      userId: user.id,
      nome: _nomeCtrl.text.trim(),
      descricao: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      diaSemana: _diaSemana,
    );

    final error = await ref.read(workoutProvider.notifier).create(workout);
    setState(() => _loading = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Treino')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do Treino',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                initialValue: _diaSemana,
                decoration: const InputDecoration(
                  labelText: 'Dia da Semana',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Livre')),
                  DropdownMenuItem(value: 1, child: Text('Segunda-feira')),
                  DropdownMenuItem(value: 2, child: Text('Terça-feira')),
                  DropdownMenuItem(value: 3, child: Text('Quarta-feira')),
                  DropdownMenuItem(value: 4, child: Text('Quinta-feira')),
                  DropdownMenuItem(value: 5, child: Text('Sexta-feira')),
                  DropdownMenuItem(value: 6, child: Text('Sábado')),
                  DropdownMenuItem(value: 7, child: Text('Domingo')),
                ],
                onChanged: (v) => setState(() => _diaSemana = v),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Criar Treino'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
