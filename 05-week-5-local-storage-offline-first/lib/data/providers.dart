import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    await ref.read(prefsRepositoryProvider).markOpenedNow();
    return _repository.fetchNotes();
  }

  Future<void> add({required String title, required String body}) async {
    final current = state.value ?? const [];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final note = await _repository.addNote(title: title, body: body);
      return [note, ...current];
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateNote(id: id, title: title, body: body);
      return _repository.fetchNotes();
    });
  }

  Future<void> remove(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteNote(id);
      return _repository.fetchNotes();
    });
  }

  Future<int> sync() async {
    final dirtyCount = await _repository.countDirty();
    if (dirtyCount == 0) return 0;
    await Future<void>.delayed(const Duration(seconds: 1));
    await _repository.markAllSynced();
    state = AsyncData(await _repository.fetchNotes());
    return dirtyCount;
  }

  Future<int> dirtyCount() => _repository.countDirty();
}
