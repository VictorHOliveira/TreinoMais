import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
    );
  }

  // Auth
  Future<AuthResponse> signUp(String email, String password) async {
    return client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authState => client.auth.onAuthStateChange;

  // Profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final result = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return result;
  }

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    await client.from('profiles').upsert(data, onConflict: 'id');
  }

  // Body Measurements
  Future<List<Map<String, dynamic>>> getMeasurements(String userId) async {
    final result = await client
        .from('body_measurements')
        .select()
        .eq('user_id', userId)
        .order('data', ascending: false);
    return result;
  }

  Future<void> insertMeasurement(Map<String, dynamic> data) async {
    await client.from('body_measurements').insert(data);
  }

  Future<void> deleteMeasurement(String id) async {
    await client.from('body_measurements').delete().eq('id', id);
  }

  // Workouts
  Future<List<Map<String, dynamic>>> getWorkouts(String userId) async {
    final result = await client
        .from('workouts')
        .select()
        .eq('user_id', userId)
        .order('dia_semana', ascending: true);
    return result;
  }

  Future<void> insertWorkout(Map<String, dynamic> data) async {
    await client.from('workouts').insert(data);
  }

  Future<void> updateWorkout(String id, Map<String, dynamic> data) async {
    await client.from('workouts').update(data).eq('id', id);
  }

  Future<void> deleteWorkout(String id) async {
    await client.from('workouts').delete().eq('id', id);
  }

  // Workout Exercises
  Future<List<Map<String, dynamic>>> getWorkoutExercises(String workoutId) async {
    final result = await client
        .from('workout_exercises')
        .select()
        .eq('workout_id', workoutId)
        .order('ordem', ascending: true);
    return result;
  }

  Future<void> insertWorkoutExercise(Map<String, dynamic> data) async {
    await client.from('workout_exercises').insert(data);
  }

  Future<void> deleteWorkoutExercise(String id) async {
    await client.from('workout_exercises').delete().eq('id', id);
  }

  // Workout Sessions
  Future<List<Map<String, dynamic>>> getSessions(String userId, {String? workoutId}) async {
    final result = await client
        .from('workout_sessions')
        .select()
        .match({
          'user_id': userId,
          if (workoutId != null) 'workout_id': workoutId,
        })
        .order('data', ascending: false);
    return result;
  }

  Future<Map<String, dynamic>> insertSession(Map<String, dynamic> data) async {
    final result = await client.from('workout_sessions').insert(data).select().single();
    return result;
  }

  // Exercise Sets
  Future<List<Map<String, dynamic>>> getSets(String sessionId) async {
    final result = await client
        .from('exercise_sets')
        .select()
        .eq('session_id', sessionId)
        .order('set_numero', ascending: true);
    return result;
  }

  Future<List<Map<String, dynamic>>> getSetsByExercise(int exerciseId, String userId) async {
    final result = await client
        .from('exercise_sets')
        .select(''', ''')
        .eq('exercise_id', exerciseId)
        .order('session_id', ascending: false);
    return result;
  }

  Future<void> insertSet(Map<String, dynamic> data) async {
    await client.from('exercise_sets').insert(data);
  }

  Future<void> insertSets(List<Map<String, dynamic>> dataList) async {
    await client.from('exercise_sets').insert(dataList);
  }

  // Cardio Sessions
  Future<List<Map<String, dynamic>>> getCardioSessions(String userId) async {
    final result = await client
        .from('cardio_sessions')
        .select()
        .eq('user_id', userId)
        .order('data', ascending: false);
    return result;
  }

  Future<void> insertCardioSession(Map<String, dynamic> data) async {
    await client.from('cardio_sessions').insert(data);
  }

  Future<void> deleteCardioSession(String id) async {
    await client.from('cardio_sessions').delete().eq('id', id);
  }

  // Water Log
  Future<List<Map<String, dynamic>>> getWaterLogs(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    final result = await client
        .from('water_log')
        .select()
        .eq('user_id', userId)
        .eq('data', dateStr);
    return result;
  }

  Future<List<Map<String, dynamic>>> getWaterLogsRange(
      String userId, DateTime start, DateTime end) async {
    final result = await client
        .from('water_log')
        .select()
        .eq('user_id', userId)
        .gte('data', start.toIso8601String().substring(0, 10))
        .lte('data', end.toIso8601String().substring(0, 10))
        .order('data', ascending: true);
    return result;
  }

  Future<void> insertWaterLog(Map<String, dynamic> data) async {
    await client.from('water_log').insert(data);
  }

  // Exercises (cache)
  Future<void> cacheExercises(List<Map<String, dynamic>> exercises) async {
    await client.from('exercises').upsert(exercises, onConflict: 'id');
  }

  Future<int> getExerciseCount() async {
    final result = await client.from('exercises').select('id');
    return result.length;
  }

  Future<List<Map<String, dynamic>>> getCachedExercises({String? muscle}) async {
    if (muscle != null && muscle != 'Todos') {
      final result = await client
          .from('exercises')
          .select()
          .or('musculo_principal.eq.$muscle,musculos_secundarios.cs.{$muscle}')
          .order('nome', ascending: true);
      return result;
    }
    final result = await client
        .from('exercises')
        .select()
        .order('nome', ascending: true);
    return result;
  }

  Future<List<Map<String, dynamic>>> searchExercises(String query, {String? muscle}) async {
    if (muscle != null && muscle != 'Todos') {
      final result = await client
          .from('exercises')
          .select()
          .ilike('nome', '%$query%')
          .or('musculo_principal.eq.$muscle,musculos_secundarios.cs.{$muscle}')
          .order('nome', ascending: true);
      return result;
    }
    final result = await client
        .from('exercises')
        .select()
        .ilike('nome', '%$query%')
        .order('nome', ascending: true);
    return result;
  }

  // Favorites
  Future<void> toggleFavorite(String userId, int exerciseId) async {
    final existing = await client
        .from('favorite_exercises')
        .select()
        .eq('user_id', userId)
        .eq('exercise_id', exerciseId)
        .maybeSingle();

    if (existing != null) {
      await client
          .from('favorite_exercises')
          .delete()
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId);
    } else {
      await client.from('favorite_exercises').insert({
        'user_id': userId,
        'exercise_id': exerciseId,
      });
    }
  }

  Future<Set<int>> getFavorites(String userId) async {
    final result = await client
        .from('favorite_exercises')
        .select('exercise_id')
        .eq('user_id', userId);
    return result.map((e) => e['exercise_id'] as int).toSet();
  }
}
