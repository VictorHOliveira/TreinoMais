import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/body_measurement.dart';
import '../services/supabase_service.dart';
import 'providers.dart';

final measurementProvider =
    StateNotifierProvider<MeasurementNotifier, AsyncValue<List<BodyMeasurement>>>(
  (ref) => MeasurementNotifier(ref.read(supabaseServiceProvider)),
);

class MeasurementNotifier extends StateNotifier<AsyncValue<List<BodyMeasurement>>> {
  final SupabaseService _supabase;

  MeasurementNotifier(this._supabase) : super(const AsyncValue.loading());

  Future<void> load(String userId) async {
    try {
      final data = await _supabase.getMeasurements(userId);
      state = AsyncValue.data(data.map((e) => BodyMeasurement.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> add(BodyMeasurement measurement) async {
    try {
      await _supabase.insertMeasurement(measurement.toMap());
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([measurement, ...current]);
      return null;
    } catch (e) {
      return 'Erro ao salvar medição';
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _supabase.deleteMeasurement(id);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(current.where((m) => m.id != id).toList());
      return null;
    } catch (e) {
      return 'Erro ao excluir';
    }
  }
}
