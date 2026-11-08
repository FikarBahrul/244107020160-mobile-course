import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/sync_notes.dart';

// Satu-satunya tempat wiring dependensi fitur notes.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.watch(noteRepositoryProvider)),
);

final syncNotesProvider = Provider<SyncNotes>(
  (ref) => SyncNotes(ref.watch(noteRepositoryProvider)),
);

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

final searchNotesProvider = Provider<SearchNotes>((ref) => const SearchNotes());

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String value) => state = value;
}

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final search = ref.watch(searchNotesProvider);
  final query = ref.watch(searchQueryProvider);
  return ref.watch(notesProvider).whenData((notes) => search(notes, query));
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  // CRUD satu-baris langsung ke repository (use case hanya untuk operasi
  // berlogika seperti GetNotes dan SyncNotes).
  Future<void> add({required String title, required String body}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.addNote(title: title, body: body);
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return (await ref.read(getNotesProvider).call()).notes;
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.updateNote(
        id: id,
        title: title,
        body: body,
      );
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return (await ref.read(getNotesProvider).call()).notes;
    });
  }

  Future<void> remove(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.deleteNote(id);
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return (await ref.read(getNotesProvider).call()).notes;
    });
  }

  Future<int> sync() async {
    final result = await ref.read(syncNotesProvider).call();
    state = AsyncData((await ref.read(getNotesProvider).call()).notes);
    return result.synced;
  }

  Future<int> dirtyCount() async {
    final counted = await _repository.countDirty();
    return counted.count;
  }
}
