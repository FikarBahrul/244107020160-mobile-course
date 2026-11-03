import 'package:week10_ai_feature_integration/ai/ai_service.dart';
import 'package:week10_ai_feature_integration/core/failures.dart';
import 'package:week10_ai_feature_integration/features/notes/domain/entities/note.dart';
import 'package:week10_ai_feature_integration/features/notes/domain/repositories/note_repository.dart';

class FakeAiClient implements AiClient {
  FakeAiClient({
    this.hasKey = true,
    this.chunks = const ['Jawaban ', 'uji.'],
    this.error,
  });

  bool hasKey;
  final List<String> chunks;
  final AiException? error;
  final List<String> asked = [];

  @override
  Future<bool> hasApiKey() async => hasKey;

  @override
  Future<void> saveApiKey(String key) async {
    hasKey = key.trim().isNotEmpty;
  }

  @override
  Future<void> deleteApiKey() async {
    hasKey = false;
  }

  @override
  Stream<String> askStream(String question) async* {
    asked.add(question);
    if (error != null) throw error!;
    for (final chunk in chunks) {
      yield chunk;
    }
  }
}

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const []});

  final List<Note> items;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: items, failure: null);
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
