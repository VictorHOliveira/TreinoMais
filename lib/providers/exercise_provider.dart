import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../services/supabase_service.dart';
import '../services/exercise_sync_service.dart';
import 'providers.dart';

final syncServiceProvider = Provider<ExerciseSyncService>((ref) {
  return ExerciseSyncService(ref.read(supabaseServiceProvider));
});

final exerciseListProvider =
    StateNotifierProvider<ExerciseListNotifier, AsyncValue<List<Exercise>>>(
  (ref) => ExerciseListNotifier(ref.read(supabaseServiceProvider)),
);

final hasExercisesProvider = FutureProvider<bool>((ref) async {
  final count = await ref.read(supabaseServiceProvider).getExerciseCount();
  return count > 0;
});

class ExerciseListNotifier extends StateNotifier<AsyncValue<List<Exercise>>> {
  final SupabaseService _supabase;
  String? _currentMuscle;

  ExerciseListNotifier(this._supabase) : super(const AsyncValue.data([]));

  Future<void> load({String? muscle}) async {
    _currentMuscle = muscle;
    state = const AsyncValue.loading();
    try {
      final data = await _supabase.getCachedExercises(muscle: muscle);
      final enriched = await _enrichFavorites(
        data.map((e) => Exercise.fromMap(e)).toList(),
      );
      state = AsyncValue.data(enriched);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase.searchExercises(query, muscle: _currentMuscle);
      state = AsyncValue.data(data.map((e) => Exercise.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await load(muscle: _currentMuscle);
  }

  Future<List<Exercise>> _enrichFavorites(List<Exercise> exercises) async {
    final user = _supabase.currentUser;
    if (user == null) return exercises;
    try {
      final favIds = await _supabase.getFavorites(user.id);
      return exercises.map((e) => e.copyWith(isFavorito: favIds.contains(e.id))).toList();
    } catch (_) {
      return exercises;
    }
  }

  Future<void> toggleFavorite(String userId, int exerciseId) async {
    await _supabase.toggleFavorite(userId, exerciseId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((e) {
        if (e.id == exerciseId) return e.copyWith(isFavorito: !e.isFavorito);
        return e;
      }).toList(),
    );
  }
}

final exerciseSetsProvider =
    FutureProvider.family<List<ExerciseSet>, int>((ref, exerciseId) async {
  final supabase = ref.read(supabaseServiceProvider);
  final user = supabase.currentUser;
  if (user == null) return [];

  final data = await supabase.getSetsByExercise(exerciseId, user.id);
  return data.map((e) => ExerciseSet.fromMap(e)).toList();
});
