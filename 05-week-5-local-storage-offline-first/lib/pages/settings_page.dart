import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          darkMode.when(
            loading: () => const ListTile(
              title: Text('Tema gelap'),
              trailing: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => ListTile(
              title: const Text('Tema gelap'),
              subtitle: Text(error.toString()),
            ),
            data: (value) => SwitchListTile(
              title: const Text('Tema gelap'),
              subtitle: const Text('Disimpan dengan SharedPreferences'),
              value: value,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          FutureBuilder<String?>(
            future: ref.read(prefsRepositoryProvider).getLastOpened(),
            builder: (context, snapshot) {
              final value = snapshot.data;
              return ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Terakhir dibuka'),
                subtitle: Text(value ?? 'Belum tersedia'),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Penyimpanan'),
            subtitle: Text('SharedPreferences + SQLite melalui repository'),
          ),
        ],
      ),
    );
  }
}
