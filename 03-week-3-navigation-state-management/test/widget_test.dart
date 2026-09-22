import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week3_navigation/providers/todo_provider.dart';

void main() {
  test(
    'TodoNotifier dapat menambah tugas',
        () {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      expect(
        container.read(todoListProvider),
        isEmpty,
      );

      container
          .read(todoListProvider.notifier)
          .add('Kerjakan PR minggu 3');

      final todos = container.read(todoListProvider);

      expect(todos.length, 1);
      expect(
        todos.first.title,
        'Kerjakan PR minggu 3',
      );
      expect(
        todos.first.done,
        false,
      );
    },
  );

  test(
    'Filter hanya menampilkan tugas yang belum selesai',
        () {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final notifier =
      container.read(todoListProvider.notifier);

      notifier.add('Tugas belum selesai');
      notifier.add('Tugas selesai');

      notifier.toggle(1);

      final unfinished =
      container.read(unfinishedTodoProvider);

      expect(unfinished.length, 1);
      expect(
        unfinished.first.title,
        'Tugas belum selesai',
      );
    },
  );
}