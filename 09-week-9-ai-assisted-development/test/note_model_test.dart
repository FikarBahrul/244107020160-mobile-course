import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_assisted_development/core/format.dart';
import 'package:week9_ai_assisted_development/features/notes/data/models/note_model.dart';

void main() {
  test('NoteModel.fromMap aman terhadap field yang hilang', () {
    final model = NoteModel.fromMap({'title': 'Belanja'});
    expect(model.title, 'Belanja');
    expect(model.body, '');
    expect(model.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi model', () {
    final model = NoteModel(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = NoteModel.fromMap(model.toMap());
    expect(restored.dirty, isTrue);
  });

  test('formatDateTime menampilkan tanggal yang dapat diprediksi', () {
    expect(formatDateTime(DateTime(2026, 9, 7, 5, 3)), '2026-09-07 05:03');
  });
}
