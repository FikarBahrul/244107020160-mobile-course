import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/notes/presentation/pages/notes_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'routes.dart';

void main() {
  runApp(const ProviderScope(child: OfflineNotesApp()));
}

class OfflineNotesApp extends ConsumerStatefulWidget {
  const OfflineNotesApp({super.key});

  @override
  ConsumerState<OfflineNotesApp> createState() => _OfflineNotesAppState();
}

class _OfflineNotesAppState extends ConsumerState<OfflineNotesApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(markOpenedProvider).call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp(
      title: 'Offline Notes',
      debugShowCheckedModeBanner: false,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.notes,
      routes: {
        AppRoutes.notes: (_) => const NotesPage(),
        AppRoutes.settings: (_) => const SettingsPage(),
      },
    );
  }
}
