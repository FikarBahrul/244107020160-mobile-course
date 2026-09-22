class Todo {
  final String id;
  final String title;
  final bool done;

  const Todo({
    this.id = '',
    required this.title,
    this.done = false,
  });

  bool get isDone => done;

  Todo copyWith({
    String? id,
    String? title,
    bool? done,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }
}