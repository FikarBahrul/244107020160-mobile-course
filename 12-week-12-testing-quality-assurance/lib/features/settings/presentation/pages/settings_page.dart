import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import '../widgets/ai_key_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);
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
          lastOpened.when(
            loading: () => const ListTile(
              leading: Icon(Icons.history),
              title: Text('Terakhir dibuka'),
              subtitle: Text('Memuat...'),
            ),
            error: (error, stackTrace) => ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Terakhir dibuka'),
              subtitle: Text(error.toString()),
            ),
            data: (value) => ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Terakhir dibuka'),
              subtitle: Text(value ?? 'Belum tersedia'),
            ),
          ),
          const Divider(),
          const AiKeyTile(),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privasi data'),
            subtitle: Text(
              'NIK, nomor telepon, dan alamat tidak dikirim ke AI API.',
            ),
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
