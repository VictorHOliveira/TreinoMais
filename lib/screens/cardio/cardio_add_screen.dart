import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/cardio_session.dart';
import '../../providers/cardio_provider.dart';
import '../../providers/providers.dart';

class CardioAddScreen extends ConsumerStatefulWidget {
  const CardioAddScreen({super.key});

  @override
  ConsumerState<CardioAddScreen> createState() => _CardioAddScreenState();
}

class _CardioAddScreenState extends ConsumerState<CardioAddScreen> {
  String _tipo = CardioTypes.all.first;
  final _duracaoCtrl = TextEditingController();
  final _distanciaCtrl = TextEditingController();
  final _caloriasCtrl = TextEditingController();
  final _fcCtrl = TextEditingController();
  int? _esforco;
  final _formKey = GlobalKey<FormState>();
  DateTime _data = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _duracaoCtrl.dispose();
    _distanciaCtrl.dispose();
    _caloriasCtrl.dispose();
    _fcCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;

    final session = CardioSession(
      id: const Uuid().v4(),
      userId: user.id,
      data: _data,
      tipo: _tipo,
      duracaoMinutos: int.parse(_duracaoCtrl.text),
      distanciaKm: _distanciaCtrl.text.isNotEmpty
          ? double.tryParse(_distanciaCtrl.text.replaceAll(',', '.'))
          : null,
      calorias: _caloriasCtrl.text.isNotEmpty ? int.tryParse(_caloriasCtrl.text) : null,
      frequenciaCardiacaMedia:
          _fcCtrl.text.isNotEmpty ? int.tryParse(_fcCtrl.text) : null,
      percepcaoEsforco: _esforco,
    );

    final error = await ref.read(cardioProvider.notifier).add(session);
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
      appBar: AppBar(title: const Text('Novo Cardio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.directions_run),
                ),
                items: CardioTypes.all
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v ?? _tipo),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(Formatters.date(_data)),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _data = date);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _duracaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duração (minutos)',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Duração obrigatória';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanciaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Distância (km) (opcional)',
                  prefixIcon: Icon(Icons.straighten),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Calorias (opcional)',
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fcCtrl,
                decoration: const InputDecoration(
                  labelText: 'FC Média (bpm) (opcional)',
                  prefixIcon: Icon(Icons.favorite),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                initialValue: _esforco,
                decoration: const InputDecoration(
                  labelText: 'Percepção de Esforço (1-10)',
                  prefixIcon: Icon(Icons.speed),
                ),
                items: List.generate(10, (i) => i + 1)
                    .map((v) => DropdownMenuItem(value: v, child: Text('$v/10')))
                    .toList(),
                onChanged: (v) => setState(() => _esforco = v),
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
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
