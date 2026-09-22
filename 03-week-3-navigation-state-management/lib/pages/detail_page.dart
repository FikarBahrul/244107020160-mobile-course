import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';

class DetailPage extends ConsumerWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(todoListProvider).firstWhere(
      (item) => item.id == id || item.title == id,
      orElse: () => throw Exception('Tugas tidak ditemukan'),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Detail ${todo.title}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID tugas: $id',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              todo.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Status selesai'),
              value: todo.done,
              onChanged: (_) {
                ref.read(todoListProvider.notifier).toggle(
                  ref.read(todoListProvider).indexOf(todo),
                );
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}