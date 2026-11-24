import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/core/failures.dart';
import 'package:week12_testing_quality_assurance/features/notes/domain/entities/note.dart';
import 'package:week12_testing_quality_assurance/features/notes/domain/repositories/note_repository.dart';
import 'package:week12_testing_quality_assurance/features/notes/domain/usecases/sync_notes.dart';

class FakeSyncRepository implements NoteRepository {
  FakeSyncRepository({this.dirty = 0, this.countFailure, this.markFailure});

  final int dirty;
  final Failure? countFailure;
  final Failure? markFailure;
  bool marked = false;

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: dirty, failure: countFailure);
  }

  @override
  Future<({bool ok, Failure? failure})> markAllSynced() async {
    if (markFailure != null) {
      return (ok: false, failure: markFailure);
    }
    marked = true;
    return (ok: true, failure: null);
  }

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() {
    throw UnimplementedError();
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
}

void main() {
  test('SyncNotes menandai catatan dirty sebagai tersinkron', () async {
    final repository = FakeSyncRepository(dirty: 3);
    final result = await SyncNotes(repository).call();

    expect(result.failure, isNull);
    expect(result.synced, 3);
    expect(repository.marked, isTrue);
  });

  test('SyncNotes tidak memproses apa pun saat antrean kosong', () async {
    final repository = FakeSyncRepository(dirty: 0);
    final result = await SyncNotes(repository).call();

    expect(result.synced, 0);
    expect(result.failure, isNull);
    expect(repository.marked, isFalse);
  });

  test('SyncNotes meneruskan kegagalan hitung tanpa menandai', () async {
    final repository = FakeSyncRepository(
      countFailure: const LocalFailure('db terkunci'),
    );
    final result = await SyncNotes(repository).call();

    expect(result.failure, isA<LocalFailure>());
    expect(result.failure!.message, 'db terkunci');
    expect(repository.marked, isFalse);
  });
}
