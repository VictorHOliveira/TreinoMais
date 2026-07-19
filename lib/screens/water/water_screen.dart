import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/water_provider.dart';
import '../../providers/providers.dart';
import '../../services/notification_service.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});

  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen> {
  int _goal = 8;
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(supabaseServiceProvider).currentUser;
      if (user != null) ref.read(waterProvider.notifier).loadToday(user.id);
    });
  }

  Future<void> _loadSettings() async {
    _goal = await WaterNotifier.getDailyGoal();
    _reminderEnabled = await WaterNotifier.isReminderEnabled();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final water = ref.watch(waterProvider);
    final totalMl = water.valueOrNull?.fold<int>(0, (s, l) => s + l.quantidadeMl) ?? 0;
    final totalCopos = totalMl ~/ 200;
    final progress = _goal > 0 ? (totalCopos / _goal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Água')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: AppColors.background,
                            valueColor: const AlwaysStoppedAnimation(AppColors.waterBlue),
                          ),
                        ),
                        Column(
                          children: [
                            Icon(Icons.water_drop, size: 36, color: AppColors.waterBlue),
                            Text(
                              '$totalCopos',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: AppColors.waterBlue,
                                  ),
                            ),
                            Text(
                              'de $_goal copos',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      Formatters.water(totalMl),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final user = ref.read(supabaseServiceProvider).currentUser;
                        if (user != null) {
                          await ref.read(waterProvider.notifier).add(user.id, ml: 200);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('+ 200ml'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.waterBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configurações', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('Meta diária'),
                      subtitle: Text('$_goal copos (${Formatters.water(_goal * 200)})'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () async {
                              if (_goal > 1) {
                                setState(() => _goal--);
                                await WaterNotifier.setDailyGoal(_goal);
                              }
                            },
                          ),
                          Text('$_goal'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              setState(() => _goal++);
                              await WaterNotifier.setDailyGoal(_goal);
                            },
                          ),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Lembrete a cada 1h'),
                      subtitle: const Text('Notificações para beber água'),
                      value: _reminderEnabled,
                      onChanged: (v) async {
                        setState(() => _reminderEnabled = v);
                        await WaterNotifier.setReminderEnabled(v);
                        if (v) {
                          await NotificationService().scheduleWaterReminders();
                        } else {
                          await NotificationService().cancelWaterReminders();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
