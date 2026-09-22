import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return [];
  }

  void add(String title) {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty) {
      return;
    }

    state = [
      ...state,
      Todo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: trimmedTitle,
      ),
    ];
  }

  void toggle(dynamic value) {
    if (value is int) {
      final todos = [...state];
      todos[value] = todos[value].copyWith(
        done: !todos[value].done,
      );
      state = todos;
      return;
    }

    final targetId = value.toString();
    state = [
      for (final todo in state)
        todo.id == targetId ? todo.copyWith(done: !todo.done) : todo,
    ];
  }

  void remove(dynamic value) {
    if (value is int) {
      final todos = [...state];
      todos.removeAt(value);
      state = todos;
      return;
    }

    final targetId = value.toString();
    state = state.where((todo) => todo.id != targetId).toList();
  }
}

final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

final unfinishedTodoProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);

  return todos.where((todo) => !todo.done).toList();
});