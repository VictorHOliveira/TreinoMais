import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
import '../models/workout_session.dart';
import '../services/supabase_service.dart';
import 'providers.dart';

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, AsyncValue<List<Workout>>>(
  (ref) => WorkoutNotifier(ref.read(supabaseServiceProvider)),
);

class WorkoutNotifier extends StateNotifier<AsyncValue<List<Workout>>> {
  final SupabaseService _supabase;

  WorkoutNotifier(this._supabase) : super(const AsyncValue.loading());

  Future<void> load(String userId) async {
    try {
      final data = await _supabase.getWorkouts(userId);
      state = AsyncValue.data(data.map((e) => Workout.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> create(Workout workout) async {
    try {
      await _supabase.insertWorkout(workout.toMap());
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, workout]);
      return null;
    } catch (e) {
      return 'Erro ao criar treino';
    }
  }

  Future<String?> update(String id, Workout workout) async {
    try {
      await _supabase.updateWorkout(id, workout.toMap());
      await load(workout.userId);
      return null;
    } catch (e) {
      return 'Erro ao atualizar';
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _supabase.deleteWorkout(id);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(current.where((w) => w.id != id).toList());
      return null;
    } catch (e) {
      return 'Erro ao excluir';
    }
  }
}

final workoutExercisesProvider =
    FutureProvider.family<List<WorkoutExercise>, String>((ref, workoutId) async {
  final supabase = ref.read(supabaseServiceProvider);
  final data = await supabase.getWorkoutExercises(workoutId);
  return data.map((e) => WorkoutExercise.fromMap(e)).toList();
});

final workoutSessionsProvider =
    StateNotifierProvider<WorkoutSessionNotifier, AsyncValue<List<WorkoutSession>>>(
  (ref) => WorkoutSessionNotifier(ref.read(supabaseServiceProvider)),
);

class WorkoutSessionNotifier extends StateNotifier<AsyncValue<List<WorkoutSession>>> {
  final SupabaseService _supabase;

  WorkoutSessionNotifier(this._supabase) : super(const AsyncValue.loading());

  Future<void> load(String userId) async {
    try {
      final data = await _supabase.getSessions(userId);
      state = AsyncValue.data(data.map((e) => WorkoutSession.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String> startSession(Map<String, dynamic> data) async {
    final result = await _supabase.insertSession(data);
    return result['id'] as String;
  }
}
