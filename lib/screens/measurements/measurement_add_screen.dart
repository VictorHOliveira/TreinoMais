import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/body_measurement.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/providers.dart';

class MeasurementAddScreen extends ConsumerStatefulWidget {
  const MeasurementAddScreen({super.key});

  @override
  ConsumerState<MeasurementAddScreen> createState() => _MeasurementAddScreenState();
}

class _MeasurementAddScreenState extends ConsumerState<MeasurementAddScreen> {
  final _pesoCtl = TextEditingController();
  final _gorduraCtl = TextEditingController();
  final _musculoCtl = TextEditingController();
  final _cinturaCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _data = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _pesoCtl.dispose();
    _gorduraCtl.dispose();
    _musculoCtl.dispose();
    _cinturaCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;

    final measurement = BodyMeasurement(
      id: const Uuid().v4(),
      userId: user.id,
      pesoKg: double.parse(_pesoCtl.text.replaceAll(',', '.')),
      gorduraPercent: _gorduraCtl.text.isNotEmpty
          ? double.tryParse(_gorduraCtl.text.replaceAll(',', '.'))
          : null,
      massaMuscularKg: _musculoCtl.text.isNotEmpty
          ? double.tryParse(_musculoCtl.text.replaceAll(',', '.'))
          : null,
      circunferenciaCintura: _cinturaCtl.text.isNotEmpty
          ? double.tryParse(_cinturaCtl.text.replaceAll(',', '.'))
          : null,
      data: _data,
    );

    final error = await ref.read(measurementProvider.notifier).add(measurement);
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
      appBar: AppBar(title: const Text('Nova Medida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                controller: _pesoCtl,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Peso obrigatório';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gorduraCtl,
                decoration: const InputDecoration(
                  labelText: '% Gordura (opcional)',
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _musculoCtl,
                decoration: const InputDecoration(
                  labelText: 'Massa Muscular (kg) (opcional)',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cinturaCtl,
                decoration: const InputDecoration(
                  labelText: 'Cintura (cm) (opcional)',
                  prefixIcon: Icon(Icons.straighten),
                ),
                keyboardType: TextInputType.number,
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
