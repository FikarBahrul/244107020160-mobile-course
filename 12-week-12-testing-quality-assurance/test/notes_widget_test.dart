import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/core/failures.dart';
import 'package:week12_testing_quality_assurance/features/notes/domain/entities/note.dart';
import 'package:week12_testing_quality_assurance/features/notes/domain/repositories/note_repository.dart';
import 'package:week12_testing_quality_assurance/features/notes/presentation/pages/notes_page.dart';
import 'package:week12_testing_quality_assurance/features/notes/presentation/providers/notes_providers.dart';

class FakeNotesRepository implements NoteRepository {
  final List<Note> items = [];
  int _nextId = 1;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: List<Note>.unmodifiable(items), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 11, 24),
      dirty: true,
    );
    items.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> updateNote({
    required int id,
    required String title,
    required String body,
  }) async {
    return (ok: true, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> deleteNote(int id) async {
    items.removeWhere((note) => note.id == id);
    return (ok: true, failure: null);
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: items.where((note) => note.dirty).length, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> markAllSynced() async {
    return (ok: true, failure: null);
  }
}

Widget buildNotesPage(NoteRepository repository) {
  return ProviderScope(
    overrides: [noteRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: NotesPage()),
  );
}

void main() {
  testWidgets('menampilkan keadaan kosong saat belum ada catatan', (
    tester,
  ) async {
    await tester.pumpWidget(buildNotesPage(FakeNotesRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Offline Notes'), findsOneWidget);
    expect(find.text('Belum ada catatan'), findsOneWidget);
  });

  testWidgets('menampilkan pesan error saat judul tidak valid', (tester) async {
    await tester.pumpWidget(buildNotesPage(FakeNotesRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-note-fab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('note-title-field')), '   ');
    await tester.tap(find.byKey(const Key('save-note-button')));
    await tester.pumpAndSettle();

    expect(find.text('Judul catatan tidak boleh kosong.'), findsOneWidget);
    expect(find.text('Catatan baru'), findsOneWidget);
  });

  testWidgets('menambahkan catatan lewat dialog dan menampilkannya', (
    tester,
  ) async {
    final repository = FakeNotesRepository();
    await tester.pumpWidget(buildNotesPage(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-note-fab')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('note-title-field')),
      'Baca materi',
    );
    await tester.tap(find.byKey(const Key('save-note-button')));
    await tester.pumpAndSettle();

    expect(find.text('Baca materi'), findsOneWidget);
    expect(repository.items, hasLength(1));
  });
}
