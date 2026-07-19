import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../login/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      (profile?.nome ?? profile?.email ?? 'A')[0].toUpperCase(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.nome ?? 'Atleta',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    profile?.email ?? '',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Nome'),
                  subtitle: Text(profile?.nome ?? 'Não definido'),
                  onTap: () => _editName(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Altura'),
                  subtitle: Text(
                    profile?.alturaCm != null ? '${profile!.alturaCm!.toStringAsFixed(0)} cm' : 'Não definida',
                  ),
                  onTap: () => _editHeight(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sair', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await authNotifier.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(authProvider)?.nome ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final profile = ref.read(authProvider);
              if (profile != null) {
                await ref.read(authProvider.notifier).updateProfile(
                  profile.copyWith(nome: controller.text),
                );
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _editHeight(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(authProvider)?.alturaCm?.toStringAsFixed(0) ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Altura'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Altura (cm)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final altura = double.tryParse(controller.text.replaceAll(',', '.'));
              if (altura == null) return;
              final profile = ref.read(authProvider);
              if (profile != null) {
                await ref.read(authProvider.notifier).updateProfile(
                  profile.copyWith(alturaCm: altura),
                );
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
