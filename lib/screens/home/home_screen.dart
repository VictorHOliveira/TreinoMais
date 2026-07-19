import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../providers/workout_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/cardio_provider.dart';
import '../../providers/water_provider.dart';
import '../workouts/workout_list_screen.dart';
import '../exercises/exercise_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _screens = [
    const _DashboardTab(),
    const WorkoutListScreen(),
    const ExerciseListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: 'Treinos'),
          NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Exercícios'),
          NavigationDestination(icon: Icon(Icons.person_outlined), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab();

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;
    ref.read(measurementProvider.notifier).load(user.id);
    ref.read(workoutProvider.notifier).load(user.id);
    ref.read(cardioProvider.notifier).load(user.id);
    ref.read(waterProvider.notifier).loadToday(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider);
    final measurements = ref.watch(measurementProvider);
    final workouts = ref.watch(workoutProvider);
    final cardio = ref.watch(cardioProvider);
    final water = ref.watch(waterProvider);

    final waterTotal = water.valueOrNull?.fold<int>(0, (s, l) => s + l.quantidadeMl) ?? 0;
    final waterGoalMl = 1600;
    final waterProgress = waterTotal / waterGoalMl;

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${profile?.nome ?? 'Atleta'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.push('/calendar'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StreakCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _WaterCard(progress: waterProgress, total: waterTotal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CardioCard(
                      minutos: cardio.valueOrNull
                              ?.where((s) =>
                                  s.data.isAfter(DateTime.now().subtract(const Duration(days: 7))))
                              .fold<int>(0, (s, c) => s + c.duracaoMinutos) ??
                          0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LastWorkoutCard(workouts: workouts),
              const SizedBox(height: 16),
              _ProgressPreviewCard(measurements: measurements),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_fire_department, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Treino Streak', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Continue assim!',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '0 dias',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  final double progress;
  final int total;

  const _WaterCard({required this.progress, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/water'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 6,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation(AppColors.waterBlue),
                    ),
                  ),
                  Icon(Icons.water_drop, color: AppColors.waterBlue, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(Formatters.water(total), style: Theme.of(context).textTheme.titleMedium),
              Text('Água', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardioCard extends StatelessWidget {
  final int minutos;
  const _CardioCard({required this.minutos});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/cardio'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardioOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_run, color: AppColors.cardioOrange, size: 28),
              ),
              const SizedBox(height: 8),
              Text(Formatters.duration(minutos), style: Theme.of(context).textTheme.titleMedium),
              Text('Cardio/sem', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastWorkoutCard extends ConsumerWidget {
  final AsyncValue<List<dynamic>> workouts;

  const _LastWorkoutCard({required this.workouts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Últimos Treinos', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/workouts'),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            workouts.when(
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center_outlined,
                              size: 40, color: AppColors.textHint),
                          const SizedBox(height: 8),
                          Text('Nenhum treino ainda',
                              style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => context.push('/workouts/new'),
                            child: const Text('Criar Treino'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: list.take(3).map((w) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fitness_center,
                          color: AppColors.primary, size: 20),
                    ),
                    title: Text(w.nome),
                    subtitle: Text(w.diaSemanaLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/workouts/${w.id}'),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text('Erro ao carregar', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPreviewCard extends ConsumerWidget {
  final AsyncValue<List<dynamic>> measurements;

  const _ProgressPreviewCard({required this.measurements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Composição Corporal', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/measurements'),
                  child: const Text('Ver mais'),
                ),
              ],
            ),
            measurements.when(
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.monitor_weight_outlined,
                              size: 40, color: AppColors.textHint),
                          const SizedBox(height: 8),
                          Text('Adicione suas medidas',
                              style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => context.push('/measurements/new'),
                            child: const Text('Adicionar Medida'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final latest = list.first;
                return Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Peso',
                        value: Formatters.weight(latest.pesoKg),
                        icon: Icons.monitor_weight_outlined,
                      ),
                    ),
                    if (latest.gorduraPercent != null)
                      Expanded(
                        child: _MetricCard(
                          label: '% Gordura',
                          value: Formatters.percent(latest.gorduraPercent),
                          icon: Icons.percent_outlined,
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text('Erro', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
