import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import 'providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.authState.map((state) => state.session?.user);
});

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier(ref.read(supabaseServiceProvider));
});

class AuthNotifier extends StateNotifier<UserProfile?> {
  final SupabaseService _supabase;

  AuthNotifier(this._supabase) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final user = _supabase.currentUser;
    if (user != null) {
      await _loadProfile(user.id);
    }
  }

  Future<void> _loadProfile(String userId) async {
    final profile = await _supabase.getProfile(userId);
    if (profile != null) {
      state = UserProfile.fromMap({
        ...profile,
        'id': userId,
        'email': _supabase.currentUser?.email ?? '',
      });
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabase.signIn(email, password);
      final user = response.user;
      if (user != null) await _loadProfile(user.id);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro ao fazer login';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await _supabase.signUp(email, password);
      final user = response.user;
      if (user != null) {
        await _supabase.upsertProfile({'id': user.id});
        await _loadProfile(user.id);
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro ao cadastrar: $e';
    }
  }

  Future<void> signOut() async {
    await _supabase.signOut();
    state = null;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _supabase.upsertProfile({
      'id': profile.id,
      ...profile.toMap(),
    });
    state = profile;
  }
}
