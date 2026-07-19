import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workouts/workout_create_screen.dart';
import 'screens/workouts/workout_detail_screen.dart';
import 'screens/workouts/workout_player_screen.dart';
import 'screens/exercises/exercise_detail_screen.dart';
import 'screens/measurements/measurement_add_screen.dart';
import 'screens/measurements/measurement_list_screen.dart';
import 'screens/cardio/cardio_add_screen.dart';
import 'screens/cardio/cardio_list_screen.dart';
import 'screens/water/water_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/progress/progress_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = authState.value != null;
      final onLogin = state.matchedLocation == '/login';

      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
      GoRoute(path: '/workouts', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/workouts/new',
        builder: (_, __) => const WorkoutCreateScreen(),
      ),
      GoRoute(
        path: '/workouts/:id',
        builder: (_, state) => WorkoutDetailScreen(
          workoutId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/workouts/:id/start',
        builder: (_, state) => WorkoutPlayerScreen(
          workoutId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/exercises/:id',
        builder: (_, state) => ExerciseDetailScreen(
          exerciseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/measurements', builder: (_, __) => const MeasurementListScreen()),
      GoRoute(path: '/measurements/new', builder: (_, __) => const MeasurementAddScreen()),
      GoRoute(path: '/cardio', builder: (_, __) => const CardioListScreen()),
      GoRoute(path: '/cardio/new', builder: (_, __) => const CardioAddScreen()),
      GoRoute(path: '/water', builder: (_, __) => const WaterScreen()),
      GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
    ],
  );
});

class FitTrackApp extends ConsumerWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FitTrack',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
