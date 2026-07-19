import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cardio_session.dart';
import '../services/supabase_service.dart';
import 'providers.dart';

final cardioProvider =
    StateNotifierProvider<CardioNotifier, AsyncValue<List<CardioSession>>>(
  (ref) => CardioNotifier(ref.read(supabaseServiceProvider)),
);

class CardioNotifier extends StateNotifier<AsyncValue<List<CardioSession>>> {
  final SupabaseService _supabase;

  CardioNotifier(this._supabase) : super(const AsyncValue.data([]));

  Future<void> load(String userId) async {
    try {
      final data = await _supabase.getCardioSessions(userId);
      state = AsyncValue.data(data.map((e) => CardioSession.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> add(CardioSession session) async {
    try {
      await _supabase.insertCardioSession(session.toMap());
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([session, ...current]);
      return null;
    } catch (e) {
      return 'Erro ao salvar cardio';
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _supabase.deleteCardioSession(id);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(current.where((s) => s.id != id).toList());
      return null;
    } catch (e) {
      return 'Erro ao excluir';
    }
  }

  int get totalMinutosSemana {
    final sessions = state.valueOrNull ?? [];
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return sessions
        .where((s) => s.data.isAfter(weekAgo))
        .fold(0, (sum, s) => sum + s.duracaoMinutos);
  }
}
