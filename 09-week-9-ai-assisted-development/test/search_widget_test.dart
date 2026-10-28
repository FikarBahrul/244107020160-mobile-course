import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_assisted_development/core/failures.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/entities/note.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/repositories/note_repository.dart';
import 'package:week9_ai_assisted_development/features/notes/presentation/pages/notes_page.dart';
import 'package:week9_ai_assisted_development/features/notes/presentation/providers/notes_providers.dart';

class FakeNoteRepository implements NoteRepository {
  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (
      notes: [
        Note(title: 'Belanja mingguan', updatedAt: DateTime(2026, 10, 20)),
        Note(title: 'Jadwal kuliah', updatedAt: DateTime(2026, 10, 21)),
      ],
      failure: null,
    );
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<({bool ok, Failure? failure})> updateNote({
    required int id,
    required String title,
    required String body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<({bool ok, Failure? failure})> deleteNote(int id) {
    throw UnimplementedError();
  }

  @override
  Future<({int count, Failure? failure})> countDirty() {
    throw UnimplementedError();
  }

  @override
  Future<({bool ok, Failure? failure})> markAllSynced() {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('empty state muncul saat pencarian tidak cocok', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belanja mingguan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('Catatan tidak ditemukan'), findsOneWidget);
    expect(
      find.text('Tidak ada judul yang cocok dengan "zzz".'),
      findsOneWidget,
    );
  });
}
