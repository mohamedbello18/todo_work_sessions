// lib/features/settings/presentation/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light: return 'Clair';
      case ThemeMode.dark: return 'Sombre';
      case ThemeMode.system: return 'Système';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(title: const Text('Clair'), onTap: () => _setThemeAndPop(context, ref, ThemeMode.light)),
            ListTile(title: const Text('Sombre'), onTap: () => _setThemeAndPop(context, ref, ThemeMode.dark)),
            ListTile(title: const Text('Thème du système'), onTap: () => _setThemeAndPop(context, ref, ThemeMode.system)),
          ],
        );
      },
    );
  }

  void _setThemeAndPop(BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    ref.read(themeNotifierProvider.notifier).setTheme(themeMode);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _SectionTitle(title: 'Compte'),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Se connecter'),
            subtitle: const Text('Synchronisez vos données avec votre compte Google.'),
            onTap: () {},
          ),
          const Divider(),
          _SectionTitle(title: 'Apparence'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Thème'),
            subtitle: Text(_themeModeToString(currentThemeMode)),
            onTap: () => _showThemePicker(context, ref),
          ),
          const Divider(),
          _SectionTitle(title: 'À Propos'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'), // Version statique
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
