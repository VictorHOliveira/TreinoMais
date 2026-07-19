import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  Set<DateTime> _workoutDays = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;

    final sessions = await ref.read(supabaseServiceProvider).getSessions(user.id);
    final days = sessions.map((s) {
      final d = DateTime.parse(s['data'] as String);
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    setState(() => _workoutDays = days);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2024),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _format,
            onFormatChanged: (format) => setState(() => _format = format),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            eventLoader: (day) {
              return _workoutDays.contains(DateTime(day.year, day.month, day.day))
                  ? [true]
                  : [];
            },
          ),
          const Divider(),
          Expanded(
            child: _DaySessionsList(day: _selectedDay),
          ),
        ],
      ),
    );
  }
}

class _DaySessionsList extends ConsumerWidget {
  final DateTime day;

  const _DaySessionsList({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadSessions(ref),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 48, color: AppColors.textHint),
                const SizedBox(height: 8),
                Text('Nenhum treino neste dia',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (_, i) {
            final s = sessions[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.fitness_center, color: AppColors.primary),
                ),
                title: Text(Formatters.dateTime(DateTime.parse(s['data'] as String))),
                subtitle: s['duracao_minutos'] != null
                    ? Text('Duração: ${Formatters.duration(s['duracao_minutos'] as int)}')
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadSessions(WidgetRef ref) async {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return [];

    final all = await ref.read(supabaseServiceProvider).getSessions(user.id);
    return all.where((s) {
      final d = DateTime.parse(s['data'] as String);
      return isSameDay(d, day);
    }).toList();
  }
}
