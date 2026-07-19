import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_log.dart';
import '../services/supabase_service.dart';
import 'providers.dart';

final waterProvider =
    StateNotifierProvider<WaterNotifier, AsyncValue<List<WaterLog>>>(
  (ref) => WaterNotifier(ref.read(supabaseServiceProvider)),
);

class WaterNotifier extends StateNotifier<AsyncValue<List<WaterLog>>> {
  final SupabaseService _supabase;

  WaterNotifier(this._supabase) : super(const AsyncValue.data([]));

  Future<void> loadToday(String userId) async {
    try {
      final data = await _supabase.getWaterLogs(userId, DateTime.now());
      state = AsyncValue.data(data.map((e) => WaterLog.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(String userId, {int ml = 200}) async {
    final log = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      data: DateTime.now(),
      quantidadeMl: ml,
    );
    try {
      await _supabase.insertWaterLog(log.toMap());
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, log]);
    } catch (e) {
      rethrow;
    }
  }

  int get totalMl {
    final logs = state.valueOrNull ?? [];
    return logs.fold(0, (sum, log) => sum + log.quantidadeMl);
  }

  int get totalCopos {
    return totalMl ~/ 200;
  }

  // Meta diária
  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('water_goal') ?? 8;
  }

  static Future<void> setDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_goal', goal);
  }

  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('water_reminder_enabled') ?? true;
  }

  static Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_reminder_enabled', enabled);
  }
}
